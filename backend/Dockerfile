# Stage 1: install dependencies
FROM python:3.12-slim-trixie AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: run the app
FROM python:3.12-slim-trixie
LABEL maintainer="KenanRicky <kaburaricky@gmail.com>"
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app ./app
RUN useradd --system app
USER app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
