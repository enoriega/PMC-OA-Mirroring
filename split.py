# /// script
# requires-python = ">=3.12"
# dependencies = ["tqdm"]
# ///

# Create a client to the local redis server
# Enumerate all the files in the input directory and filter them such that only files that aren't registred in the database are returned
# Divide the number of files by the batch size to compute the number of batches
# Create the directories 

import os
import argparse
from tqdm import tqdm

# Set up argument parsing
argument_parser = argparse.ArgumentParser(description="Split files into batches.")
argument_parser.add_argument("--output-dir", type=str, required=True, help="Directory to save output batches.")
argument_parser.add_argument("--prefix-path", type=str, required=True, help="Prefix path to build the symbolic links.")
argument_parser.add_argument("--batch-size", type=int, required=True, help="Number of files per batch.")
args = argument_parser.parse_args()

job_ix = 0
file_ix = 0

# Enumrate all the files in the input directory
with open(os.path.join(args.output_dir, "sorted_files.txt"), "r") as f:
    for file_ix, file_path in tqdm(enumerate(f), desc="Enumerating files", unit="file"):
        
        # Compute the directory index for the current batch base on the file index and batch size
        if file_ix % args.batch_size == 0:
            job_ix += 1
            dir_path = os.path.join(args.output_dir, f"xml_{job_ix}")
            if not os.path.exists(dir_path):
                os.makedirs(dir_path)

        base_name = os.path.basename(file_path.strip())
        # Just continue if the entry is a file, ignore directories

        file_ix += 1
        # Create a symbolic link to the file in the job's directory
        symlink_path = os.path.join(dir_path, base_name)
        source_path = os.path.join(args.prefix_path, base_name)
        if not os.path.islink(symlink_path):
            os.symlink(source_path, symlink_path)
