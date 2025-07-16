FROM ghcr.io/astral-sh/uv:python3.12-alpine

ENV BATCH_SIZE=1000

WORKDIR /app
COPY split.sh .
COPY split.py .

RUN uv lock --script split.py
CMD [ "sh", "/app/split.sh" ]