# /// script
# requires-python = ">=3.12"
# dependencies = ["redis", "tqdm"]
# ///

# Create a client to the local redis server
# Enumerate all the files in the input directory and filter them such that only files that aren't registred in the database are returned
# Divide the number of files by the batch size to compute the number of batches
# Create the directories 

import os
import shutil
import argparse
import redis
from dataclasses import dataclass
from tqdm import tqdm

@dataclass
class Job:
    dir_name: str
    file_names: list[str]

# Set up argument parsing
argument_parser = argparse.ArgumentParser(description="Split files into batches.")
argument_parser.add_argument("--input-dir", type=str, required=True, help="Directory containing input files.")
argument_parser.add_argument("--output-dir", type=str, required=True, help="Directory to save output batches.")
argument_parser.add_argument("--batch-size", type=int, required=True, help="Number of files per batch.")
args = argument_parser.parse_args()

# Redis client
r = redis.Redis(host='localhost', port=6379, db=0)

job_ix = 0
file_ix = 0
job = None
jobs = []

# Enumrate all the files in the input directory
with os.scandir(args.input_dir) as entries:
    for entry in tqdm(entries, desc="Enumerating files", unit="file"):
        # Compute the directory index for the current batch base on the file index and batch size
        if file_ix % args.batch_size == 0:
            if job:
                jobs.append(job)
            job_ix += 1
            job = Job(dir_name=os.path.join(args.output_dir, f"xml_{job_ix}"), file_names=list())

        # Just continue if the entry is a file, ignore directories
        if entry.is_file():
            file_ix += 1
            # Only add the file if it is not registered in the database
            if not r.exists(entry.name):
                job.file_names.append(entry.path)
            # print(entry.name)

def execute_job(job: Job):
    """Simulate the execution of a job by saving the file names to Redis."""

    # Create the directory if it does not exist
    if not os.path.exists(job.dir_name):
        os.makedirs(job.dir_name)

    for file_name in job.file_names:
        shutil.copy(file_name, job.dir_name)  # Copy the file to the job's directory

    # Register the files in Redis
    for file_name in job.file_names:
        r.set(file_name.split("/")[-1], "")


for job in tqdm(jobs, desc="Copying batches", unit="batch"):
    execute_job(job)  # Run each batch's "job"

# Save the state of Redis to disk before exiting
r.save()
