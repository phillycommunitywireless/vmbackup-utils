#!/bin/bash

# Restores backups created by vmbackup using vmrestore. Restored files are stored in a mounted docker volume called "restore"
# View the data by running a VictoriaMetrics container with a bind mount to the restored contents from vmrestore
# docker run -d -p 8428:8428 -v restore:/victoria-metrics-data victoriametrics/victoria-metrics -storageDataPath=/victoria-metrics-data

source /etc/vmbackup-utils/.env

# Check if a volume called "restore" already exists
RESTORE_EXIST_CHECK_OUTPUT=$(docker volume inspect restore)
RESTORE_EXIST_STATUS=$?

# why use this patter over checking docker inspect ... exit status? 
# if any output, return 1 > the volume already exists! 
# if no output from cmd, create the volume 

if docker volume inspect "restore" > /dev/null 2>&1; then 
        echo "volume called restore already exists"      
        exit 1   
else 
        echo "restore does not exist. creating now..."
        docker volume create restore
fi

BUCKET_PATH="s3://$VMRESTORE_BUCKET/$VMRESTORE_BUCKET_DIR"
echo "Restoring VictoriaMetrics DB from $BUCKET_PATH ..."

DOCKER_OUTPUT=$(docker run --rm \
        -v restore:$VMRESTORE_STORAGE_DATA_PATH \
        victoriametrics/vmrestore:latest \
        -storageDataPath=$VMRESTORE_STORAGE_DATA_PATH \
        # env vars work here, text doesnt. very annoying. 
        -customS3Endpoint=$S3_ENDPOINT \
        -src=$BUCKET_PATH)
        # debug 
        # -src=$BUCKET_PATH 2>&1)

DOCKER_EXIT_STATUS=$?

if [ $DOCKER_EXIT_STATUS -eq 0 ]; then
        echo "db restored successfully"
        # MESSAGE="✅ vmbackup ($BACKUP_TYPE) ran successfully at $(date -Iseconds)"
else
        echo "something went wrong!"
        # MESSAGE="‼️ vmbackup ($BACKUP_TYPE) failed with status ${DOCKER_EXIT_STATUS} at $(date -Iseconds) \`\`\`${DOCKER_OUTPUT}\`\`\`"
fi
