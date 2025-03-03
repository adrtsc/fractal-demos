#!/bin/bash

PORT=8010

# Create an empty db
rm -fr db
mkdir db
export SQLITE_PATH=db/fractal_server.db
fractalctl set-db

# Remove old stuff
rm -fr FRACTAL_TASKS_DIR
# Move what cannot be removed easily to some trash folder
TIMESTAMP=$(date +%s)
mkdir -p OLD
mv artifacts OLD/artifacts_$TIMESTAMP

# Set environment variables
FRACTAL_TASKS_DIR=`pwd`/FRACTAL_TASKS_DIR
echo -e "\
DEPLOYMENT_TYPE=testing
JWT_SECRET_KEY=secret
SQLITE_PATH=db/fractal_server.db
FRACTAL_TASKS_DIR=${FRACTAL_TASKS_DIR}
FRACTAL_LOGGING_LEVEL=10
FRACTAL_RUNNER_BACKEND=process
FRACTAL_RUNNER_WORKING_BASE_DIR=artifacts
FRACTAL_SLURM_CONFIG_FILE=config_uzh.json
" > .fractal_server.env


# Start the server
fractalctl start --port $PORT
