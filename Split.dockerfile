FROM ghcr.io/astral-sh/uv:python3.12-alpine

RUN apk --no-cache update
RUN apk --no-cache add redis


ENV BATCH_SIZE=1000

WORKDIR /app
COPY split.sh .
COPY split.py .

RUN uv lock --script split.py
CMD [ "sh", "/app/split.sh" ]