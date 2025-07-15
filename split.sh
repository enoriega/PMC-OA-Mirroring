#!/bin/bash

REDIS_PREFIX="pmc_split"
DEST_BASE="/app/output"
SRC_DIR="/app/input"

# redis-server --dir "${DEST_BASE}" --dbfilename splits.rdb --save "60 1" &

# sleep 1

# Generate a sorted list of files in the source directory
echo "Generating sorted list of files in $SRC_DIR"
find "$SRC_DIR" -maxdepth 1 -type f > /app/unsorted_files.txt
sort /app/unsorted_files.txt -o /app/sorted_files.txt
echo "Sorted files generated."

uv run --script /app/split.py --output-dir "$DEST_BASE" --batch-size "$BATCH_SIZE" --prefix-path "$HOST_INPUT_DIR"

# Erase temporary files
echo
rm /app/unsorted_files.txt
rm /app/sorted_files.txt

# # Initialize or get current index and directory
# current_index=$(redis-cli GET "$REDIS_PREFIX:file_index")
# current_dir=$(redis-cli GET "$REDIS_PREFIX:current_dir")

# current_index=${current_index:-0}
# current_dir=${current_dir:-1}

# mkdir -p "$DEST_BASE/xml_$current_dir"

# find "$SRC_DIR" -maxdepth 1 -type f | while read -r filepath; do
#     filename=$(basename "$filepath")

#     # Check if file is already recorded in Redis
#     if [ "$(redis-cli EXISTS "$REDIS_PREFIX:file:$filename")" = "1" ]; then
#         echo "Skipping $filename (already copied)"
#         continue
#     fi

#     # Copy file
#     cp "$filepath" "$DEST_BASE/xml_$current_dir/"
#     echo "Copied $filename to xml_$current_dir"

#     # Record in Redis
#     redis-cli SET "$REDIS_PREFIX:file:$filename" "xml_$current_dir"

#     # Increment file index
#     current_index=$((current_index + 1))
#     redis-cli SET "$REDIS_PREFIX:file_index" "$current_index"

#     # If we've reached the batch size, move to next directory
#     if [ "$current_index" -ge "$BATCH_SIZE" ]; then
#         current_dir=$((current_dir + 1))
#         mkdir -p "$DEST_BASE/xml_$current_dir"
#         current_index=0
#         redis-cli SET "$REDIS_PREFIX:current_dir" "$current_dir"
#         redis-cli SET "$REDIS_PREFIX:file_index" "0"
#     fi
# done

# # Force Redis to persist to disk
# redis-cli SAVE