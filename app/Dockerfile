# Stage 1: Build
FROM python:3.11-slim as builder
WORKDIR /hydrosat
COPY hydrosat/requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /hydrosat
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY hydrosat .
ENV PYTHONUNBUFFERED=1
RUN export PYTHONPATH="$PYTHONPATH:/hydrosat"
EXPOSE 80
CMD ["dagster", "api", "grpc", "--python-file", "your_pipeline.py", "--host", "0.0.0.0"]
