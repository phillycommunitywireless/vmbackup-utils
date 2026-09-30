#!/bin/bash

# Restores the database by cloning the filesystem to a docker mounted volume 

source /etc/vmbackup-utils/.env

echo "..."

exec 9>/etc/vmbackup-utils/vmbackup_lockfile
if ! flock -n 9; then
        echo "Could not acquire lock on vmbackup_lockfile, exiting..."
        exit 1
fi

DOCKER_OUTPUT=$(docker run --rm \
        --env-file /etc/vmbackup-utils/.env \
        -v $VMRESTORE_PATH:$/restore \
        -storageDataPath=$VMRESTORE_STORAGE_DATA_PATH \
        -customS3Endpoint=$S3_ENDPOINT \
        -src=s3://$VMRESTORE_BUCKET \ 
        -storageDataPath=/restore 
        2>&1)

DOCKER_EXIT_STATUS=$?

if [ $DOCKER_EXIT_STATUS -eq 0 ]; then
        MESSAGE="✅ vmbackup ($BACKUP_TYPE) ran successfully at $(date -Iseconds)"
else
        MESSAGE="‼️ vmbackup ($BACKUP_TYPE) failed with status ${DOCKER_EXIT_STATUS} at $(date -Iseconds) \`\`\`${DOCKER_OUTPUT}\`\`\`"
fi

F_MESSAGE=$(jq -n --arg m "$MESSAGE" '{"blocks": [{"type": "section", "text": {"text": $m, "type": "mrkdwn"}}]}')

# curl -X POST -H 'Content-type: application/json' --data "$F_MESSAGE" "$SLACK_WEBHOOK"

echo "$BACKUP_TYPE backup attempt concluded..."
