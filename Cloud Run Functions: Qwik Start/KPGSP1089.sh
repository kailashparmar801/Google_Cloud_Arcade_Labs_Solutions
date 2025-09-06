#!/bin/bash
# Enhanced Color Definitions
COLOR_BLACK=$'\033[0;30m'
COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[0;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_MAGENTA=$'\033[0;35m'
COLOR_CYAN=$'\033[0;36m'
COLOR_WHITE=$'\033[0;37m'
COLOR_RESET=$'\033[0m'

# Text Formatting
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
BLINK=$'\033[5m'
REVERSE=$'\033[7m'

# Friendly aliases used in echoes
BLUE_TEXT=$COLOR_BLUE
GREEN_TEXT=$COLOR_GREEN
YELLOW_TEXT=$COLOR_YELLOW
RED_TEXT=$COLOR_RED
MAGENTA_TEXT=$COLOR_MAGENTA
CYAN_TEXT=$COLOR_CYAN
WHITE_TEXT=$COLOR_WHITE
BOLD_TEXT=$BOLD
UNDERLINE_TEXT=$UNDERLINE
RESET_FORMAT=$COLOR_RESET

clear
# Welcome banner
echo "${MAGENTA_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT} Welcome to Kailash Parmar Cloud Tutorial — Let's begin! ${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo

# Spinner utilities
_spinner_pid=0
start_spinner() {
  local msg="$1"
  local delay=0.1
  local spinchars=('/' '-' '\' '|')
  printf "${CYAN_TEXT}${BOLD_TEXT}%s... ${RESET_FORMAT}" "$msg"
  (
    i=0
    while true; do
      printf "%s" "${spinchars[i%4]}"
      sleep $delay
      printf "\b"
      i=$((i+1))
    done
  ) &
  _spinner_pid=$!
  disown
}

stop_spinner() {
  if [ "$_spinner_pid" -ne 0 ]; then
    kill "$_spinner_pid" >/dev/null 2>&1 || true
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=0
    printf " ${GREEN_TEXT}${BOLD_TEXT}done${RESET_FORMAT}\n"
  fi
}

# Enable GCP Services
start_spinner "Enabling Required GCP Services"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  osconfig.googleapis.com \
  pubsub.googleapis.com
stop_spinner

echo
# Set Project Variables
export PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$PROJECT_ID" --format='value(project_number)')
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/region $REGION

# Configure IAM
start_spinner "Configuring IAM bindings"
SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
  --role roles/eventarc.eventReceiver
stop_spinner

# Update IAM Policy
gcloud projects get-iam-policy $PROJECT_ID > policy.yaml
cat <<'EOF' >> policy.yaml
auditConfigs:
- auditLogConfigs:
  - logType: ADMIN_READ
  - logType: DATA_READ
  - logType: DATA_WRITE
  service: compute.googleapis.com
EOF
start_spinner "Updating IAM policy"
gcloud projects set-iam-policy $PROJECT_ID policy.yaml
stop_spinner

# Improved deploy_with_retry uses spinner during each attempt
deploy_with_retry() {
  local function_name=$1
  shift
  local attempts=0
  local max_attempts=5
  while [ $attempts -lt $max_attempts ]; do
    attempts=$((attempts+1))
    echo "${YELLOW_TEXT}${BOLD_TEXT}Attempt $attempts: Deploying $function_name...${RESET_FORMAT}"
    start_spinner "Deploying $function_name (attempt $attempts)"
    if gcloud functions deploy $function_name "$@"; then
      stop_spinner
      echo "${GREEN_TEXT}${BOLD_TEXT}$function_name deployed successfully!${RESET_FORMAT}"
      return 0
    else
      stop_spinner
      echo "${RED_TEXT}${BOLD_TEXT}Deployment failed for $function_name on attempt $attempts${RESET_FORMAT}"
      if [ $attempts -lt $max_attempts ]; then
        echo "${YELLOW_TEXT}Retrying in 30 seconds...${RESET_FORMAT}"
        sleep 30
      fi
    fi
  done
  echo "${RED_TEXT}${BOLD_TEXT}Failed to deploy $function_name after $max_attempts attempts${RESET_FORMAT}"
  return 1
}

# Deploy HTTP Function
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying HTTP Trigger Function...${RESET_FORMAT}"
echo
mkdir -p ~/hello-http && cd ~/hello-http
cat <<'EOF' > index.js
const functions = require('@google-cloud/functions-framework');
functions.http('helloWorld', (req, res) => {
  res.status(200).send('HTTP with Node.js 22 in GCF 2nd gen!');
});
EOF
cat <<'EOF' > package.json
{
  "name": "nodejs-http-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

deploy_with_retry nodejs-http-function \
  --gen2 \
  --runtime nodejs22 \
  --entry-point helloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --timeout 600s \
  --max-instances 1 \
  --allow-unauthenticated

# Test HTTP Function
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Testing HTTP Function...${RESET_FORMAT}"
gcloud functions call nodejs-http-function --gen2 --region $REGION || true

# Deploy Storage Function
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying Storage Trigger Function...${RESET_FORMAT}"
echo
mkdir -p ~/hello-storage && cd ~/hello-storage
cat <<'EOF' > index.js
const functions = require('@google-cloud/functions-framework');
functions.cloudEvent('helloStorage', (cloudevent) => {
  console.log('Cloud Storage event with Node.js 22 in GCF 2nd gen!');
  console.log(cloudevent);
});
EOF
cat <<'EOF' > package.json
{
  "name": "nodejs-storage-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

BUCKET="gs://gcf-gen2-storage-$PROJECT_ID"
start_spinner "Creating bucket $BUCKET"
gsutil mb -l $REGION $BUCKET || true
stop_spinner

deploy_with_retry nodejs-storage-function \
  --gen2 \
  --runtime nodejs22 \
  --entry-point helloStorage \
  --source . \
  --region $REGION \
  --trigger-bucket $BUCKET \
  --trigger-location $REGION \
  --max-instances 1

# Test Storage Function
echo "Hello World" > random.txt
gsutil cp random.txt $BUCKET/random.txt || true
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Checking Storage Function Logs...${RESET_FORMAT}"
gcloud functions logs read nodejs-storage-function \
  --region $REGION --gen2 --limit=100 --format "value(log)" || true

# Deploy VM Labeler Function
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying VM Labeler Function...${RESET_FORMAT}"
echo
cd ~
if [ ! -d "~/eventarc-samples" ]; then
  start_spinner "Cloning eventarc-samples"
  git clone https://github.com/GoogleCloudPlatform/eventarc-samples.git || true
  stop_spinner
fi
cd ~/eventarc-samples/gce-vm-labeler/gcf/nodejs || true

deploy_with_retry gce-vm-labeler \
  --gen2 \
  --runtime nodejs22 \
  --entry-point labelVmCreation \
  --source . \
  --region $REGION \
  --trigger-event-filters="type=google.cloud.audit.log.v1.written,serviceName=compute.googleapis.com,methodName=beta.compute.instances.insert" \
  --trigger-location $REGION \
  --max-instances 1

# Create Test VM
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Creating Test VM Instance...${RESET_FORMAT}"
start_spinner "Creating VM instance-1"
gcloud compute instances create instance-1 --project=$PROJECT_ID --zone=$ZONE --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --metadata=enable-osconfig=TRUE,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud --reservation-affinity=any || true
stop_spinner

# Describe VM
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Checking VM Details...${RESET_FORMAT}"
gcloud compute instances describe instance-1 --zone $ZONE || true

# Deploy Colored Function (Python) — use python311 and ensure requirements.txt exists
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying Colored Hello World Function...${RESET_FORMAT}"
echo
mkdir -p ~/hello-world-colored && cd ~/hello-world-colored
echo "" > requirements.txt
cat <<'EOF' > main.py
import os

def hello_world(request):
    color = os.environ.get('COLOR', 'white')
    return f'<body style="background-color:{color}"><h1>Hello World!</h1></body>'
EOF

deploy_with_retry hello-world-colored \
  --gen2 \
  --runtime python311 \
  --entry-point hello_world \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --update-env-vars COLOR=yellow \
  --max-instances 1

# Deploy Slow Go Function (use quoted heredoc so `time.Sleep` is not interpreted by Bash)
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying Slow Go Function...${RESET_FORMAT}"
echo
mkdir -p ~/min-instances && cd ~/min-instances
cat <<'EOF' > main.go
package p
import (
        "fmt"
        "net/http"
        "time"
)
func init() {
        time.Sleep(10 * time.Second)
}
func HelloWorld(w http.ResponseWriter, r *http.Request) {
        fmt.Fprint(w, "Slow HTTP Go in GCF 2nd gen!")
}
EOF
echo "module example.com/mod" > go.mod

deploy_with_retry slow-function \
  --gen2 \
  --runtime go123 \
  --entry-point HelloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --max-instances 4

# Test Slow Function
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Testing Slow Function...${RESET_FORMAT}"
gcloud functions call slow-function --gen2 --region $REGION || true

# Deploy as Cloud Run Service (if needed)
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying as Cloud Run Service...${RESET_FORMAT}"

# Progress Check
function check_progress {
    while true; do
        echo
        echo "${CYAN_TEXT}${BOLD_TEXT} ------ PLEASE COMPLETE MANUAL STEP AND VERIFY YOUR PROGRESS UP TO TASK 6 ${RESET_FORMAT}"
        echo
        read -p "${BLUE_TEXT}${BOLD_TEXT}Have you completed Task 6? (Y/N): ${RESET_FORMAT}" user_input

        case $user_input in
            [Yy]*)
                echo
                echo "${GREEN_TEXT}${BOLD_TEXT}Proceeding to next steps...${RESET_FORMAT}"
                echo
                break
                ;;
            [Nn]*)
                echo
                echo "${RED_TEXT}${BOLD_TEXT}Please complete Task 6 first${RESET_FORMAT}"
                ;;
            *)
                echo
                echo "Invalid input. Please enter Y or N."
                ;;
        esac
    done
}
check_progress

# Cleanup (delete previous Cloud Run service if exists)
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Cleaning Up Previous Deployment...${RESET_FORMAT}"
start_spinner "Deleting previous Cloud Run service slow-function"
gcloud run services delete slow-function --region $REGION --quiet || true
stop_spinner

# Deploy Concurrent Function
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Deploying Concurrent Function...${RESET_FORMAT}"
deploy_with_retry slow-concurrent-function \
  --gen2 \
  --runtime go123 \
  --entry-point HelloWorld \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 4

echo "${CYAN_TEXT}${BOLD_TEXT} ------ PLEASE COMPLETE MANUAL STEP AND VERIFY YOUR PROGRESS OF TASK 7 ${RESET_FORMAT}"

# Final message ()
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${UNDERLINE_TEXT}${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@kailash_parmar/videos${RESET_FORMAT}"
echo
