#!/bin/sh
# vim:sw=4:ts=4:et

# Collect static files
python manage.py collectstatic --noinput

# Check if a user exists
USER_EXISTS=$(python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.exists())")

# Create superuser if no user exists
if [ "$USER_EXISTS" = "False" ]; then
  # Ensure that this command can run without interactive input
  python manage.py createsuperuser --noinput
fi

# Check for the debug flag
if [ "$1" = "--debug" ]; then
  # Django development server
  exec python manage.py runserver "0.0.0.0:${DJANGO_DEV_SERVER_PORT:-8000}"
else
  # Gunicorn server
  exec gunicorn "$PROJECT_NAME.wsgi:application" \
    --bind "0.0.0.0:${GUNICORN_PORT:-8000}" \
    --workers "${GUNICORN_WORKERS:-3}" \
    --timeout "${GUNICORN_TIMEOUT:-30}" \
    --log-level "${GUNICORN_LOG_LEVEL:-info}"
fi
