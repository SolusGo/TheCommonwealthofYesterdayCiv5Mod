"""Validate Commonwealth packaging, database definitions and Friend lifecycle.

The Civ V cache is opened read-only and copied to memory before any SQL runs.
Use --database and --cp-root when the default Documents locations differ.
"""
from __future__ import annotations

import argparse
import re
import sqlite3
from pathlib import Path
from xml.etree import ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "CommonwealthOfYesterday.civ5proj"
MANIFEST = ROOT / "The Commonwealth of Yesterday (v 1).modinfo"
NS = {"m": "http://schemas.microsoft.com/developer/msbuild/2003"}
CP_ID = "d1b6328c-ff44-4b0d-aad7-c657f83610cd"
REQUIRED_OPTIONS = {
    "EVENTS_BATTLES", "EVENTS_UNIT_CONVERTS", "EVENTS_UNIT_CREATED",
    "EVENTS_UNIT_PREKILL", "EVENTS_UNIT_UPGRADES",
}


def project_data():
    tree = ET.parse(PROJECT)
    props = tree.find("m:PropertyGroup", NS)
    assert props is not None
    files = []
    for node in tree.findall("m:ItemGroup/m:Content", NS):
        name = node.attrib["Include"].replace("\\", "/")
        imported = node.findtext("m:ImportIntoVFS", "False", NS) == "True"
        files.append((name, imported))
    return props, files


def check_packaging() -> None:
    props, project_files = project_data()
    project_map = dict(project_files)
    assert len(project_map) == len(project_files), "duplicate project Content entry"
    assert all((ROOT / name).is_file() for name in project_map), "project contains a missing file"

    # PNG files are editable art sources; Civ V runtime content uses DDS.
    package_suffixes = {".dds", ".xml", ".lua", ".sql"}
    actual = {
        path.relative_to(ROOT).as_posix()
        for folder in ("Art", "Data", "Lua", "SQL", "UI")
        for path in (ROOT / folder).rglob("*")
        if path.is_file() and path.suffix.lower() in package_suffixes
    }
    actual |= {"README.md", "PATCH_NOTES.md"}
    assert actual == set(project_map), f"project/source mismatch: {sorted(actual ^ set(project_map))}"
    assert not any(name.startswith("UI/FrontEnd/") for name in project_map), "global front-end override returned"

    manifest_root = ET.parse(MANIFEST).getroot()
    manifest_map = {
        node.text.replace("\\", "/"): node.get("import") == "1"
        for node in manifest_root.findall("Files/File")
    }
    assert manifest_map == project_map, "checked-in .modinfo and .civ5proj file lists differ"

    project_actions = [
        node.text.replace("\\", "/")
        for node in props.findall("m:ModActions/m:Action/m:FileName", NS)
    ]
    manifest_actions = [
        node.text.replace("\\", "/")
        for node in manifest_root.findall("Actions/OnModActivated/UpdateDatabase")
    ]
    assert project_actions == manifest_actions, "database actions differ between project and manifest"
    project_entries = [node.text.replace("\\", "/") for node in props.findall("m:ModContent/m:Content/m:FileName", NS)]
    manifest_entries = [node.get("file").replace("\\", "/") for node in manifest_root.findall("EntryPoints/EntryPoint")]
    assert project_entries == manifest_entries, "entry points differ between project and manifest"

    project_dependencies = {node.text for node in props.findall("m:ModDependencies/m:Association/m:Id", NS)}
    manifest_dependencies = {node.get("id") for node in manifest_root.findall("Dependencies/Mod")}
    assert CP_ID in project_dependencies == manifest_dependencies, "Community Patch dependency is missing or unsynchronized"
    project_cp = next(node for node in props.findall("m:ModDependencies/m:Association", NS)
                      if node.findtext("m:Id", "", NS) == CP_ID)
    manifest_cp = next(node for node in manifest_root.findall("Dependencies/Mod") if node.get("id") == CP_ID)
    assert project_cp.findtext("m:MinVersion", "", NS) == manifest_cp.get("minversion") == "151"

    assert not (ROOT / "PATCHNOTES.md").exists(), "duplicate patch-notes file returned"
    print(f"PASS packaging: {len(project_map)} synchronized project/manifest files and CP dependency")


def check_xml_and_lua() -> None:
    for path in sorted(ROOT.rglob("*.xml")) + [PROJECT, MANIFEST]:
        ET.parse(path)

    try:
        from lupa.lua51 import LuaRuntime
    except ImportError as error:
        raise RuntimeError("install requirements-dev.txt to run Lua 5.1 validation") from error

    lua = LuaRuntime(unpack_returned_tuples=True)
    compile_lua = lua.eval("function(source,name) local f,e=loadstring(source,name); return f~=nil,e end")
    for path in sorted(ROOT.rglob("*.lua")):
        passed, message = compile_lua(path.read_text(encoding="utf-8-sig"), str(path))
        assert passed, message

    panel_xml = ET.parse(ROOT / "UI/CommonwealthPanel.xml")
    controls = {node.get("ID") for node in panel_xml.iter() if node.get("ID")}
    panel_source = (ROOT / "UI/CommonwealthPanel.lua").read_text(encoding="utf-8-sig")
    references = set(re.findall(r"Controls\.([A-Za-z0-9_]+)", panel_source))
    assert references <= controls, f"UI Lua references missing controls: {sorted(references - controls)}"
    assert "local selectedID=selectedFriend and selectedFriend.id or nil" in panel_source
    assert "if row.id==selectedID then selectedFriend=row" in panel_source

    test_lua = LuaRuntime(unpack_returned_tuples=True)
    for relative in (
        "tools/tests/commonwealth_mock.lua", "Lua/CommonwealthCore.lua",
        "Lua/CommonwealthFriends.lua", "tools/tests/commonwealth_assertions.lua",
    ):
        test_lua.execute((ROOT / relative).read_text(encoding="utf-8-sig"))
    print("PASS XML, UI controls, Lua 5.1 syntax and deterministic lifecycle regressions")


def quote(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def apply_cp_schema(database: sqlite3.Connection, cp_root: Path) -> None:
    assert cp_root.is_dir(), f"Community Patch folder not found: {cp_root}"
    changes = (
        "Database Changes/City/Buildings/BuildingTableChanges.sql",
        "Database Changes/UnitPromotions/PromotionTableChanges.sql",
        "Database Changes/Units/UnitTableChanges.sql",
        "Database Changes/AI/LeaderTableChanges.sql",
        "Database Changes/Civilizations/CivilizationTableChanges.sql",
    )
    for relative in changes:
        source = (cp_root / relative).read_text(encoding="utf-8-sig")
        for statement in re.findall(r"ALTER\s+TABLE\s+[^;]+?\s+ADD\s+.*?;", source, re.I | re.S):
            try:
                database.execute(statement)
            except sqlite3.OperationalError as error:
                if "duplicate column name" not in str(error).lower():
                    raise

    # Current CP recreates Leaders rather than ALTERing it, while older cache
    # backups still have the otherwise-compatible BNW table. Add the two CP
    # fields to this disposable clone without rewriting the user's cache.
    leader_columns = {row[1] for row in database.execute("PRAGMA table_info(Leaders)")}
    for column in ("PrimaryVictoryPursuit", "SecondaryVictoryPursuit"):
        if column not in leader_columns:
            database.execute(f"ALTER TABLE Leaders ADD {column} TEXT")

    database.execute(
        "CREATE TABLE IF NOT EXISTS CustomModOptions "
        "(Name TEXT, Value INTEGER, Class INTEGER, DbUpdates INTEGER)"
    )
    options = ET.parse(cp_root / "Database Changes/NewCustomModOptions.xml")
    for row in options.findall(".//Row"):
        name = row.get("Name")
        if not name:
            continue
        database.execute("DELETE FROM CustomModOptions WHERE Name=?", (name,))
        database.execute(
            "INSERT INTO CustomModOptions(Name,Value,Class,DbUpdates) VALUES(?,?,?,?)",
            (name, int(row.get("Value", 0)), int(row.get("Class", 0)), int(row.get("DbUpdates", 0))),
        )

    for xml_path in sorted((cp_root / "Database Changes").rglob("*.xml")):
        try:
            root = ET.parse(xml_path).getroot()
        except ET.ParseError:
            continue
        for table in root.findall("Table"):
            name = table.get("name")
            if not name or not (name.startswith("Building_") or name.startswith("Unit_")):
                continue
            columns = []
            for column in table.findall("Column"):
                default = column.get("default")
                default_sql = "" if default is None else " DEFAULT '" + default.replace("'", "''") + "'"
                columns.append(quote(column.get("name")) + " " + column.get("type", "text") + default_sql)
            if columns:
                database.execute(f"CREATE TABLE IF NOT EXISTS {quote(name)}({','.join(columns)})")


def clear_old_rows(database: sqlite3.Connection) -> None:
    tables = [row[0] for row in database.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    )]
    for table in tables:
        columns = [row[1] for row in database.execute(f"PRAGMA table_info({quote(table)})")]
        predicate = " OR ".join(
            f"CAST({quote(column)} AS TEXT) LIKE '%COMMONWEALTH%' "
            f"OR CAST({quote(column)} AS TEXT) LIKE '%CHILD_WE_WERE%'"
            for column in columns
        )
        if predicate:
            try:
                database.execute(f"DELETE FROM {quote(table)} WHERE {predicate}")
            except sqlite3.OperationalError:
                pass
    database.execute("DROP TABLE IF EXISTS Commonwealth_Conversations")


def apply_game_data_xml(database: sqlite3.Connection, path: Path) -> None:
    root = ET.parse(path).getroot()
    for definition in root.findall("Table"):
        columns = []
        constraints = []
        for column in definition.findall("Column"):
            fragment = f"{quote(column.get('name'))} {column.get('type', 'text')}"
            if column.get("notnull") == "true":
                fragment += " NOT NULL"
            if column.get("primarykey") == "true":
                fragment += " PRIMARY KEY"
            columns.append(fragment)
        database.execute(f"CREATE TABLE {quote(definition.get('name'))}({','.join(columns + constraints)})")
    for group in root:
        if group.tag == "Table":
            continue
        for row in group.findall("Row"):
            values = {child.tag: child.text for child in row}
            columns = ",".join(quote(name) for name in values)
            placeholders = ",".join("?" for _ in values)
            database.execute(
                f"INSERT INTO {quote(group.tag)}({columns}) VALUES({placeholders})",
                tuple(values.values()),
            )


def base_inheritance_notice(database: sqlite3.Connection, table: str, base_type: str,
                            copied: set[str], ignored: set[str]) -> list[str]:
    row = database.execute(f"SELECT * FROM {quote(table)} WHERE Type=?", (base_type,)).fetchone()
    defaults = {item[1]: item[4] for item in database.execute(f"PRAGMA table_info({quote(table)})")}
    notices = []
    for column in row.keys():
        if column in copied or column in ignored:
            continue
        default = defaults[column]
        if isinstance(default, str) and len(default) >= 2 and default[0] == default[-1] == "'":
            default = default[1:-1]
        value = row[column]
        if str(value if value is not None else "") != str(default if default is not None else ""):
            notices.append(column)
    return notices


def check_database(database_path: Path, cp_root: Path) -> None:
    assert database_path.is_file(), f"Civ V debug database not found: {database_path}"
    source = sqlite3.connect(database_path.resolve().as_uri() + "?mode=ro", uri=True)
    database = sqlite3.connect(":memory:")
    source.backup(database); source.close()
    database.row_factory = sqlite3.Row
    apply_cp_schema(database, cp_root)
    clear_old_rows(database)
    database.execute("CREATE TABLE IF NOT EXISTS Language_en_US (Tag TEXT PRIMARY KEY, Text TEXT)")

    props, _ = project_data()
    actions = [node.text.replace("\\", "/") for node in props.findall("m:ModActions/m:Action/m:FileName", NS)]
    for relative in actions:
        path = ROOT / relative
        if path.suffix.lower() == ".sql":
            database.executescript(path.read_text(encoding="utf-8-sig"))
        else:
            apply_game_data_xml(database, path)

    def one(sql: str, params=()):
        return database.execute(sql, params).fetchone()[0]

    required_tables = {"CustomModOptions", "Building_TechEnhancedYieldChanges", "Unit_ClassUpgrades"}
    existing_tables = {row[0] for row in database.execute("SELECT name FROM sqlite_master WHERE type='table'")}
    assert required_tables <= existing_tables, f"missing CP tables: {sorted(required_tables-existing_tables)}"
    assert "Unhappiness" in {row[1] for row in database.execute("PRAGMA table_info(Buildings)")}
    for option in REQUIRED_OPTIONS:
        assert one("SELECT Value FROM CustomModOptions WHERE Name=?", (option,)) == 1, f"event not enabled: {option}"

    warrior = database.execute("SELECT * FROM Units WHERE Type='UNIT_WARRIOR'").fetchone()
    friend = database.execute("SELECT * FROM Units WHERE Type='UNIT_COMMONWEALTH_OLD_FRIEND'").fetchone()
    assert warrior and friend
    for column in ("Combat", "FaithCost", "Moves", "BaseSightRange", "Class", "CombatClass", "Domain",
                   "DefaultUnitAI", "MilitarySupport", "MilitaryProduction", "Pillage", "PrereqTech",
                   "ObsoleteTech", "GoodyHutUpgradeUnitClass", "HurryCostModifier", "ExtraMaintenanceCost"):
        assert friend[column] == warrior[column], f"Old Friend lost Warrior inheritance: {column}"
    assert friend["Cost"] == 40 and friend["IconAtlas"] == "COMMONWEALTH_OLD_FRIEND_ATLAS"
    assert {row[0] for row in database.execute(
        "SELECT UnitAIType FROM Unit_AITypes WHERE UnitType='UNIT_COMMONWEALTH_OLD_FRIEND'"
    )} == {row[0] for row in database.execute("SELECT UnitAIType FROM Unit_AITypes WHERE UnitType='UNIT_WARRIOR'")}
    assert {row[0] for row in database.execute(
        "SELECT UnitClassType FROM Unit_ClassUpgrades WHERE UnitType='UNIT_COMMONWEALTH_OLD_FRIEND'"
    )} == {row[0] for row in database.execute("SELECT UnitClassType FROM Unit_ClassUpgrades WHERE UnitType='UNIT_WARRIOR'")}

    monument = database.execute("SELECT * FROM Buildings WHERE Type='BUILDING_MONUMENT'").fetchone()
    bedroom = database.execute("SELECT * FROM Buildings WHERE Type='BUILDING_COMMONWEALTH_BEDROOM'").fetchone()
    assert monument and bedroom
    for column in ("FaithCost", "HurryCostModifier", "MinAreaSize", "ConquestProb", "BuildingClass",
                   "ArtDefineTag", "FreeStartEra", "ArtInfoCulturalVariation", "ArtInfoEraVariation",
                   "ArtInfoRandomVariation"):
        assert bedroom[column] == monument[column], f"Childhood Bedroom lost Monument inheritance: {column}"
    assert bedroom["Cost"] == 40 and bedroom["GoldMaintenance"] == 0 and bedroom["Happiness"] == 1
    assert one("SELECT Yield FROM Building_YieldChanges WHERE BuildingType='BUILDING_COMMONWEALTH_BEDROOM' AND YieldType='YIELD_CULTURE'") == 2

    assert one("SELECT COUNT(*) FROM UnitPromotions WHERE Type LIKE 'PROMOTION_COMMONWEALTH_%'") == 10
    assert one("SELECT COUNT(*) FROM Unit_FreePromotions WHERE UnitType='UNIT_COMMONWEALTH_OLD_FRIEND' AND PromotionType='PROMOTION_COMMONWEALTH_SINCE_BEGINNING'") == 1
    assert one("SELECT COUNT(*) FROM Commonwealth_Conversations") == 136
    assert one("SELECT COUNT(DISTINCT ID) FROM Commonwealth_Conversations") == 136
    assert one("SELECT COUNT(*) FROM Commonwealth_Conversations c LEFT JOIN Eras e ON e.Type=c.MinEraType WHERE c.MinEraType IS NOT NULL AND e.Type IS NULL") == 0
    assert one("SELECT COUNT(*) FROM Commonwealth_Conversations c LEFT JOIN Eras e ON e.Type=c.MaxEraType WHERE c.MaxEraType IS NOT NULL AND e.Type IS NULL") == 0

    for table in ("Units", "Buildings", "UnitPromotions", "BuildingClasses", "Civilizations", "Leaders", "Traits"):
        duplicate = database.execute(
            f"SELECT Type,COUNT(*) FROM {quote(table)} WHERE Type LIKE '%COMMONWEALTH%' "
            "OR Type LIKE '%CHILD_WE_WERE%' GROUP BY Type HAVING COUNT(*)<>1"
        ).fetchall()
        assert not duplicate, f"duplicate/missing namespaced Types in {table}: {duplicate}"

    referenced = set()
    for path in list((ROOT / "SQL").glob("*.sql")) + list((ROOT / "Lua").glob("*.lua")):
        referenced.update(re.findall(r"TXT_KEY_[A-Z0-9_]+", path.read_text(encoding="utf-8-sig")))
    localized = {row[0] for row in database.execute("SELECT Tag FROM Language_en_US")}
    assert referenced <= localized, f"missing localization: {sorted(referenced-localized)}"

    unit_copied = {
        "Combat", "FaithCost", "RequiresFaithPurchaseEnabled", "Moves", "BaseSightRange", "Class", "CombatClass",
        "Domain", "DefaultUnitAI", "MilitarySupport", "MilitaryProduction", "Pillage", "PrereqTech", "ObsoleteTech",
        "GoodyHutUpgradeUnitClass", "HurryCostModifier", "ExtraMaintenanceCost", "UnitArtInfo",
        "UnitArtInfoCulturalVariation", "UnitArtInfoEraVariation",
    }
    unit_ignored = {"ID", "Type", "Description", "Civilopedia", "Strategy", "Help", "Cost", "PortraitIndex",
                    "IconAtlas", "UnitFlagIconOffset", "UnitFlagAtlas", "ShowInPedia"}
    building_copied = {"FaithCost", "HurryCostModifier", "MinAreaSize", "ConquestProb", "BuildingClass", "ArtDefineTag",
                       "FreeStartEra", "ArtInfoCulturalVariation", "ArtInfoEraVariation", "ArtInfoRandomVariation"}
    building_ignored = {"ID", "Type", "Description", "Civilopedia", "Strategy", "Help", "Cost", "GoldMaintenance",
                        "Happiness", "UnmoddedHappiness", "PrereqTech", "PortraitIndex", "IconAtlas", "ShowInPedia"}
    unit_notice = base_inheritance_notice(database, "Units", "UNIT_WARRIOR", unit_copied, unit_ignored)
    building_notice = base_inheritance_notice(database, "Buildings", "BUILDING_MONUMENT", building_copied, building_ignored)
    if unit_notice or building_notice:
        print("NOTICE manual inheritance columns requiring future review:",
              "Units=" + ",".join(unit_notice or ["none"]),
              "Buildings=" + ",".join(building_notice or ["none"]))

    assert database.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
    database.close()
    print("PASS database: CP schema/events, inheritance, upgrade paths, references and localization")


def main() -> None:
    user = Path.home() / "Documents/My Games/Sid Meier's Civilization 5"
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=user / "cache_backup/Civ5DebugDatabase.db")
    parser.add_argument("--cp-root", type=Path, default=user / "MODS/(1) Community Patch")
    args = parser.parse_args()
    check_packaging()
    check_xml_and_lua()
    check_database(args.database, args.cp_root)
    print("Commonwealth validation passed. Final visual/gameplay smoke testing remains in Civ V.")


if __name__ == "__main__":
    main()
