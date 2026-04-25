LOG_STEP_IN "- Adding Pet Clustering blobs"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_detector"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/pet_mypetsearch"
LOG_STEP_OUT

LOG_STEP_IN "- Adding V901 ImageTagger blobs"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_detector"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_document_classifier"
ADD_TO_WORK_DIR "$SOURCE_FIRMWARE" "vendor" "saiv/image_understanding/db/aig_classifier"
LOG_STEP_OUT
