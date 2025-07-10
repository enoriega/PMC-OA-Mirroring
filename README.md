# PMC-OA-Mirroring
Utilities to automatically mirror updates to the FTP service of PubMed Central Open Access

## Mirror the repository
First, build the docker container.
```bash
docker build -f Mirror.dockerfile -t pmc-mirror .
```

Then, run a docker container, specifying the path where the files will be mirrored.
```bash
docker run --rm -it -v /host/mirror/path:/app pmc-mirror
```

Optionally, you can specify the number of parallel downloads with the `PARALLEL_TRANSFERS` environment variable (default: 4)
```bash
docker run --rm -it -v /host/mirror/path:/app -e PARALLEL_TRANSFERS="4" pmc-mirror
```

The image is configured to download the "bulk" dataset, but can be used to mirror the historical OCR and author manuscripts datasets too by specifying the corresponding remote directory with the `REMOTE_DIR` environment variable. See https://pmc.ncbi.nlm.nih.gov/tools/ftp/ to find the details of the remote filesystem layout.


The command to run an __apptainer__ container built from this image is:
```bash 
apptainer run --cleanenv --bind /host/mirror/path:/app --env PARALLEL_TRANSFERS=4 pmc-mirror.sif
```
Where `pmc-mirror.sif` is pulled from dockerhub by the apptainer command. This works on HPC environments.

## Uncompress tar archives in mirror
First, build the docker container.
```bash
docker build -f Uncompress.dockerfile -t pmc-uncompress .
```

Then, run a docker container, specifying the path where the mirrored files are and where they are going to be uncompressed.
```bash
docker run --rm -it -v /host/mirror/path:/app/input -v /host/output/path pmc-uncompress
```

Optionally, you can specify the number of parallel extractions with the `PARALLEL_JOBS` environment variable (default: 4)
```bash
docker run --rm -it -v /host/mirror/path:/app/input -v /host/output/path -e PARALLEL_JOBS="10" pmc-uncompress
```


The command to run an __apptainer__ container built from this image is:
```bash 
apptainer run --cleanenv --bind /host/mirror/path:/app/input --bind /host/output/path --env PARALLEL_JOBS=10 pmc-uncompress.sif
```
Where `pmc-mirror.sif` is pulled from dockerhub by the apptainer command. This works on HPC environments.

## Split flattened files into directories

We need to split files into directories with batches to take advantage of array jobs in the HPC. The following container takes a flat directory structure with all the files that need to be split into directories with a batch size (default 1000). Those outpur directories can be used to run an array of jobs with SLURM.

First, build the docker container.
```bash
docker build -f Split.dockerfile -t pmc-split .
```

Then, run a docker container, specifying the path where the mirrored files are and where they are going to be uncompressed.
```bash
docker run --rm -it -v /path/to/flattened/xml:/app/input -v /path/to/splits:/app/output pmc-split
```

Optionally, you can specify the batch size with the `BATCH_SIZE` environment variable (default: 1000)
```bash
docker run --rm -it -v /path/to/flattened/xml:/app/input -v /path/to/splits:/app/output -e BATCH_SIZE=5000 pmc-split
```