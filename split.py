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
from collections import Counter

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

latest_dir_ix = 1
files_per_dir = Counter()
index = {}


if os.path.exists(processed_files_path):
    with open(processed_files_path, "r") as f:
        for l in f:
            pmcid, dir_ix = l.strip().split()
            dir_ix = int(dir_ix)
            index[pmcid] = dir_ix
            files_per_dir[dir_ix] += 1
            if dir_ix > latest_dir_ix:
                latest_dir_ix = dir_ix

print(f"{datetime.now()}: Found {len(index)} existing processed files.")



# Enumrate all the files in the input directory
with open(args.input_file_list, "r") as f, open(processed_files_path, "a") as pf:
    
    for file_path in tqdm(f, desc="Enumerating files", unit="file"):

        base_name = file_path.strip()
        if base_name not in index:  # See if we haven't seen this directory before
            # Compute the directory index for the current batch base on the file index and batch size
            if files_per_dir[latest_dir_ix] >= args.batch_size:    # Remember that a prior run might have had a larger batch size, so guard this way
                latest_dir_ix += 1

            dir_path = os.path.join(args.output_dir, f"xml_{latest_dir_ix}")
            if not os.path.exists(dir_path):
                os.makedirs(dir_path)
                
            # # Create a symbolic link to the file in the job's directory
            symlink_path = os.path.join(dir_path, base_name)
            source_path = os.path.join(args.prefix_path, base_name)
            if not os.path.islink(symlink_path):  
                os.symlink(source_path, symlink_path)
                files_per_dir[latest_dir_ix] += 1
                pf.write(f"{base_name} {latest_dir_ix}\n")

        file_ix += 1
            

