LOG_STEP_IN "- Fix Photo Remaster"
# Fix Photo Remaster
sed -i '0,/"ModelType": "MODEL_TYPE_INSTANCE_CAPTURE"/s//"ModelType": "MODEL_TYPE_OBJ_INSTANCE_CAPTURE"/' "$WORK_DIR/system/system/cameradata/portrait_data/single_bokeh_feature.json"
LOG_STEP_OUT
