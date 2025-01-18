#! /bin/bash

gunicorn --chdir ./src/ --config gunicorn_config.py app:app --timeout 180
# python3 src/app.py