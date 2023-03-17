cp ../../00_user_setup/.fractal.env .fractal.env

# Add custom task to database
MY_TASK_NAME="Custom Napari Workflows Wrapper Adrian"
MY_TASK_COMMAND="`which python3` /data/homes/atschan/PhD/Code/Python/fractal/custom_napari_workflow_wrapper/napari_workflows_wrapper.py"
MY_TASK_SOURCE="new_source_2"
META="/data/homes/atschan/PhD/Code/Python/fractal/custom_napari_workflow_wrapper/meta.json"
DEFAULT_ARGS="/data/homes/atschan/PhD/Code/Python/fractal/custom_napari_workflow_wrapper/default_args.json"
OUTPUT_TYPE="zarr"
INPUT_TYPE="zarr"

fractal task new "$MY_TASK_NAME" "$MY_TASK_COMMAND" "$MY_TASK_SOURCE" --input-type "$INPUT_TYPE" --output-type "$OUTPUT_TYPE" --meta-file "$META" --default-args-file "$DEFAULT_ARGS"


