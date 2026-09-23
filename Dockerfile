# ---- Stage 1: build ----
FROM python:3.13-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --require-hashes --no-cache-dir -r requirements.txt

# ---- Stage 2: runtime ----
FROM python:3.13-slim

RUN useradd --create-home appuser
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app.py .

USER appuser

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]