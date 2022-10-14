#!/bin/bash

PORT=`cat ../PORT`

# Create an empty db
rm fractal_server/migrations/versions/*.py -v
rm -r data
mkdir data
alembic revision --autogenerate
alembic upgrade head

# Remove old stuff
rm -r logs
rm -r runinfo
rm cmd_parsl.slurm.*.*.sh

# Set environment variables
echo -e "DEPLOYMENT_TYPE=testing\nJWT_SECRET_KEY=secret\nDATA_DIR_ROOT=/tmp/\nSQLITE_PATH=./data/fractal_server.db" > .fractal_server.env

# Start the server
fractal-server --port $PORT
