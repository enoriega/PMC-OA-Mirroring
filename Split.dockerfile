FROM alpine:latest

RUN apk --no-cache update
RUN apk --no-cache add redis

ENV BATCH_SIZE=1000

WORKDIR /app
COPY split.sh .

CMD [ "sh", "/app/split.sh" ]