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
