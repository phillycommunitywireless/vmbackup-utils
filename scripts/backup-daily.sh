#!/bin/bash

# Run this 1x a day to backup the DB to bucket daily 

# source /etc/vmbackup-utils/.env

# get the current date 

# -v 1 - the current location of the "latest" db 
# -v 2 - where the data will be restored to 
# -origin - where the data is coming from 
# - dst - where to restore the data to 

TODAY=$(date +%Y%m%d)

$(
    docker run \
    -v /path_to_latest/latest:/path_to_db_latest \
    -v /local_to_restore/$TODAY:/restore/$TODAY \
    victoriametrics/vmbackup \
    -origin=fs:///path_to_db_latest \
    -dst=fs:///restore/$TODAY \
)

# DOCKER_OUTPUT=$(docker run --rm \
#         --env-file /etc/vmbackup-utils/.env \
#         -v $VMBACKUP_VOLUME:$VMBACKUP_STORAGE_DATA_PATH \
#         --network $DOCKER_NETWORK victoriametrics/vmbackup \
#         -storageDataPath=$VMBACKUP_STORAGE_DATA_PATH \
#         -snapshot.createURL=$VMBACKUP_CREATE_URL \
#         -customS3Endpoint=$S3_ENDPOINT \
#         -dst=$S3_DIR/$TYPE_DIR \
#         2>&1)

# DOCKER_EXIT_STATUS=$?

# if [ $DOCKER_EXIT_STATUS -eq 0 ]; then
#         MESSAGE="✅ vmbackup ($BACKUP_TYPE) ran successfully at $(date -Iseconds)"
# else
#         MESSAGE="‼️ vmbackup ($BACKUP_TYPE) failed with status ${DOCKER_EXIT_STATUS} at $(date -Iseconds) \`\`\`${DOCKER_OUTPUT}\`\`\`"
# fi

# F_MESSAGE=$(jq -n --arg m "$MESSAGE" '{"blocks": [{"type": "section", "text": {"text": $m, "type": "mrkdwn"}}]}')

# curl -X POST -H 'Content-type: application/json' --data "$F_MESSAGE" "$SLACK_WEBHOOK"

# echo "$BACKUP_TYPE backup attempt concluded..."


