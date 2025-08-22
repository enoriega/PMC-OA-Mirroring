#!/bin/bash

DEST_BASE="/app/output"
SRC_DIR="/app/input"
HOST_INPUT_FILE_LIST="/app/file_list.txt"

uv run --script /app/split.py --output-dir "$DEST_BASE" --batch-size "$BATCH_SIZE" --prefix-path "$HOST_INPUT_DIR" --input-file-list "$HOST_INPUT_FILE_LIST"


