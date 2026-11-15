FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /srv

# libgomp lo necesita scikit-learn en tiempo de ejecución.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

# Chromium para validar cédulas en el portal de la SEP (services/cedula.py).
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
RUN playwright install --with-deps --only-shell chromium && rm -rf /var/lib/apt/lists/*

COPY alembic.ini .
COPY migrations migrations
COPY certs certs
COPY app app

RUN useradd --system --uid 10001 app && chown -R app /srv
USER app

EXPOSE 8000

# Aplica las migraciones pendientes antes de aceptar tráfico.
CMD ["sh", "-c", "alembic upgrade head && exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 1 --proxy-headers --forwarded-allow-ips '*'"]
