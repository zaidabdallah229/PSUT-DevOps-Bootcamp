#!/bin/sh
set -e
echo "Running media database migrations..."
python manage.py migrate --noinput
echo "Preparing MinIO bucket and public-read policy..."
python -c 'import django; django.setup(); from media.storage import ensure_bucket; ensure_bucket()'
echo "Starting media API..."
exec gunicorn media_service.wsgi:application --bind 0.0.0.0:8000 --workers 2 --timeout 600
