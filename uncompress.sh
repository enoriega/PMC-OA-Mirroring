redis-server --dir "${OUTPUT_DIR}" --dbfilename processed.rdb --save "60 1" &

# Wait a moment to make sure Redis is up
sleep 1

# Create output directories
mkdir -p "${OUTPUT_DIR}/xml"
mkdir -p "${OUTPUT_DIR}/txt"

# Define a function to uncompress a tar.gz file to a given output directory, if it hasn't been done already
# This function will be used with xargs to parallelize the uncompression process
uncompress_tar_gz() {
	local file="$1"
	local out_dir="$2"
	local file_list_dir="$3"
	local base_file
	base_file="$(basename "$file")"

	# Skip if already uncompressed (check Redis key)
	if redis-cli EXISTS "uncompressed:$base_file" | grep -q 1; then
		echo "Skipping already uncompressed: $base_file"
		return
	fi

	echo "Uncompressing: $base_file"

	mkdir -p "${file_list_dir}"
	tar -xvzf "$file" -C "$out_dir" --transform='s|.*/||' > "$file_list_dir/$base_file.files"

	if [ $? -ne 0 ]; then
		echo "Error uncompressing $file"
		# Delete the file if uncompression fails, that way, it will be downloaded again next time by the mirror script
		rm -f "$file"
		echo "Deleted file: $file"
		return 1
	else
		# Mark as processed in Redis
		redis-cli SET "uncompressed:$base_file" 1
	fi
}

# Export the function for use with xargs
export -f uncompress_tar_gz

# Uncompress XML files
find "${INPUT_DIR}" -type f -name "*_xml*.tar.gz" | \
	xargs -P "${PARALLEL_JOBS}" -I {} bash -c 'uncompress_tar_gz "$0" "$1" "$2"' {} "${OUTPUT_DIR}/xml" "${OUTPUT_DIR}/xml_file_lists"

# Concatenate all XML file lists into a single file and sort it
find "${OUTPUT_DIR}/xml_file_lists" -type f -name "*.files" | \
	xargs cat | sed 's#.*/##' | sort -u > "${OUTPUT_DIR}/xml_file_lists/all_files.txt"

# # Uncompress Text files
find "${INPUT_DIR}" -type f -name "*_txt*.tar.gz" | \
 xargs -P "${PARALLEL_JOBS}" -I {} bash -c 'uncompress_tar_gz "$0" "$1" "$2"' {} "${OUTPUT_DIR}/txt" "${OUTPUT_DIR}/txt_file_lists"

# Concatenate all Text file lists into a single file and sort it
find "${OUTPUT_DIR}/txt_file_lists" -type f -name "*.files" | \
	xargs cat | sed 's#.*/##' | sort -u > "${OUTPUT_DIR}/txt_file_lists/all_files.txt"

# Force Redis to persist to disk
redis-cli SAVE