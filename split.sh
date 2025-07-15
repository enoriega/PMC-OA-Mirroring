#!/bin/bash

REDIS_PREFIX="pmc_split"
DEST_BASE="/app/output"
SRC_DIR="/app/input"

# redis-server --dir "${DEST_BASE}" --dbfilename splits.rdb --save "60 1" &

# sleep 1

# Generate a sorted list of files in the source directory
echo " $(date): Enumerating files in $SRC_DIR"
find "$SRC_DIR" -maxdepth 1 -type f > "${DEST_BASE}/unsorted_files.txt"
echo "$(date): Sorting files in $SRC_DIR"
sort "${DEST_BASE}/unsorted_files.txt" -o "${DEST_BASE}/sorted_files.txt"
echo "$(date): Finished sorting files."

uv run --script /app/split.py --output-dir "$DEST_BASE" --batch-size "$BATCH_SIZE" --prefix-path "$HOST_INPUT_DIR"

# Erase temporary files
echo "$(date): Cleaning up temporary files."
rm /app/unsorted_files.txt
rm /app/sorted_files.txt
echo "$(date): Finished job."

