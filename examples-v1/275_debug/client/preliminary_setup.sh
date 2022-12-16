
rm .cache -r

# Register user
PORT=8010
USERNAME="$(whoami)"
echo -e "\
FRACTAL_USER=${USERNAME}@me.com
FRACTAL_PASSWORD=${USERNAME}
SLURM_USER=${USERNAME}
FRACTAL_SERVER=http://localhost:$PORT\
" > .fractal.env
fractal register -p $USERNAME ${USERNAME}@me.com $USERNAME

# Trigger collection of core tasks
#fractal task collect fractal-tasks-core --package-version 0.6.5
fractal task collect `pwd`/package/fractal_tasks_core-0.0.0-py3-none-any.whl

echo "To quickly see whether task collection is complete, issue the command"
echo "fractal task list"

