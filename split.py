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
from datetime import datetime

# Set up argument parsing
argument_parser = argparse.ArgumentParser(description="Split files into batches.")
argument_parser.add_argument("--input-file-list", type=str, required=True, help="File containing list of input files.")
argument_parser.add_argument("--output-dir", type=str, required=True, help="Directory to save output batches.")
argument_parser.add_argument("--prefix-path", type=str, required=True, help="Prefix path to build the symbolic links.")
argument_parser.add_argument("--batch-size", type=int, required=True, help="Number of files per batch.")
args = argument_parser.parse_args()

job_ix = 0
file_ix = 0

# Resolve the output directory
processed_files_path = os.path.join(args.output_dir, "processed_files.txt")

# Read the already processed files to build a set and don't do duplicate work
print(f"{datetime.now()}: Reading existing processed files...")
if os.path.exists(processed_files_path):
    with open(processed_files_path, "r") as f:
        existing = set(f.read().splitlines())
else:
    existing = set()
print(f"{datetime.now()}: Found {len(existing)} existing processed files.")

file_ix = 0
job_ix = 0

# Enumrate all the files in the input directory
with open(args.input_file_list, "r") as f, open(processed_files_path, "a") as pf:
    
    for file_path in tqdm(f, desc="Enumerating files", unit="file"):
        
        # Compute the directory index for the current batch base on the file index and batch size
        if file_ix % args.batch_size == 0:
            job_ix += 1
            dir_path = os.path.join(args.output_dir, f"xml_{job_ix}")
            if not os.path.exists(dir_path):
                os.makedirs(dir_path)

        base_name = file_path.strip()
        if base_name not in existing:
            # # Create a symbolic link to the file in the job's directory
            symlink_path = os.path.join(dir_path, base_name)
            source_path = os.path.join(args.prefix_path, base_name)
            if not os.path.islink(symlink_path):  
                os.symlink(source_path, symlink_path)
                pf.write(base_name + "\n")

        file_ix += 1
            

