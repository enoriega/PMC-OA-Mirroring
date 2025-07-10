FROM alpine:latest

RUN apk --no-cache update
RUN apk --no-cache add bash
RUN apk --no-cache add tar
RUN apk --no-cache add redis
# Set the working directory
WORKDIR /app

# Set the input directory to find archives in
ENV INPUT_DIR="/app/input"
# Set the output directory for uncompressed files
ENV OUTPUT_DIR="/app/output"
# Set the number of parallel uncomrpression jobs
ENV PARALLEL_JOBS=4

# Copy the uncompress script into the container
COPY uncompress.sh .

# Run the uncompress script when the container starts
CMD [ "bash", "/app/uncompress.sh" ]
