LABEL="20230306_apex2_validation_protease_3D_fractal_apoc_25"

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../../00_user_setup/.fractal.env .fractal.env

# Initialization for some environment variables for the worker
# Needed on clusters where users don't have write access to the conda env
BASE_CACHE_DIR=${HOME}/.cache
WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=$BASE_CACHE_DIR/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=$BASE_CACHE_DIR/NUMBA_CACHE_DIR
export NAPARI_CONFIG=$BASE_CACHE_DIR/napari_config.json
export XDG_CONFIG_HOME=$BASE_CACHE_DIR/XDG_CONFIG
export XDG_CACHE_HOME=$BASE_CACHE_DIR/XDG
"

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}  2> /dev/null

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp_${LABEL}
rm -r $PROJ_DIR  2> /dev/null
mkdir $PROJ_DIR

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=/data/active/atschan/20230306_apex2_validation_protease_3D/
OUTPUT_PATH=/data/active/atschan/20230306_apex2_validation_protease_3D/zarr2
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME $PROJ_DIR`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr.json --meta-file Parameters/example_meta.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"
echo "{\"workflow_file\": \"`pwd`/apoc_pixel_classifier_workflow.yaml\", \"input_specs\": {\"intensity_image\": {\"type\": \"image\", \"wavelength_id\": \"A02_C02\"}, \"/data/homes/atschan/fractal-demos/examples/10_apoc_pixel_classifier/PixelClassifier.cl\": {\"type\": \"dataframe\", \"table_name\": \"classifier\"}}, \"output_specs\": {\"Result of Semantic segmentation (apply pretrained, APOC)\": {\"type\": \"label\",\"label_name\": \"nuclear_speckles\"}}}" > Parameters/args_apoc.json
fractal workflow add-task $WF_ID "Custom Napari Workflows Wrapper Adrian" --args-file Parameters/args_apoc.json --meta-file Parameters/example_meta.json

# Look at the current workflows
# fractal workflow show $WF_ID
# echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
