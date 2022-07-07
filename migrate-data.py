import os
import shutil
import glob
import re
from pathlib import Path

tables = glob.glob("./alpha-data/argus/*")
table_names = []
for table_path in tables:
    table = Path(table_path).stem
    match = re.match(r'([\d\w_]+)-', table)
    if match:
        table_names.append(match.group(1))

old_tables = glob.glob("./data/*")
valid_tables = [t for t in old_tables if Path(t).stem.split("-")[0] in table_names]
print(*valid_tables, sep="\n")

for table in valid_tables:
    table_path = Path(table)
    table_name = table_path.stem.split("-")[0]
    snapshots = os.listdir(f"{table}/snapshots")
    latest_snapshot = f"{table}/snapshots/{snapshots[-1]}"
    snapshot_files = glob.glob(f"{latest_snapshot}/*")
    matching_new_table = next(t for t in tables if table_name == Path(t).stem.split("-")[0])
    print(f"Restoring {latest_snapshot} into {matching_new_table}\n")
    shutil.rmtree(matching_new_table)
    os.mkdir(matching_new_table)
    for file in snapshot_files:
        print(f"Copying {file} to {matching_new_table}")
        shutil.copy2(file, matching_new_table)

