FROM alpine:latest

RUN apk add --no-cache lftp

# Set the working directory
WORKDIR /app

# Set the environment variable for the mirror URL
ENV MIRROR_URL="https://ftp.ncbi.nlm.nih.gov/"
# Set the number of parallel transfers
ENV PARALLEL_TRANSFERS=4
# Set the remote directory to mirror
ENV REMOTE_DIR="/pub/pmc/oa_bulk/"

# Run the lftp command to mirror the PMC data
# The command will log the transfer and only download newer files
# It will also delete files in the local mirror that no longer exist on the server
CMD ["sh", "-c", "lftp -e \"set xfer:log 1; set cmd:default-protocol sftp; mirror --verbose --log=mirror_$(date | sed s/\\ /\\_/g).log --parallel=$PARALLEL_TRANSFERS --only-newer --delete $REMOTE_DIR ./mirror; bye\" $MIRROR_URL"]
