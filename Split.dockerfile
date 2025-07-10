FROM alpine:latest

RUN apk --no-cache update
RUN apk --no-cache add redis

ENV DEST_BASE="/app/output"
ENV SRC_DIR="/app/input"
ENV BATCH_SIZE=1000

WORKDIR /app
COPY split.sh .

CMD [ "sh", "split.sh" ]