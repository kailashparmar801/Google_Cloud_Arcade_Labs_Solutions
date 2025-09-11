#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${CYAN}${BOLD}"
echo "  ____  ____   ___   _   _ _____ _   _ ____  _     ___  ____  "
echo " |  _ \|  _ \ / _ \ | | | |_   _| | | |  _ \| |   / _ \|  _ \ "
echo " | | | | |_) | | | || |_| | | | | |_| | | | | |  | | | | |_) |"
echo " | |_| |  _ <| |_| ||  _  | | | |  _  | |_| | |__| |_| |  _ < "
echo " |____/|_| \_\\___/ |_| |_| |_| |_| |_|____/|_____\___/|_| \_\\"
echo "${RESET}"
echo "${MAGENTA}${BOLD}                   DR ABHISHEK CLOUD${RESET}"
echo "${BLUE}${BOLD}--------------------------------------------------------${RESET}"
echo "${YELLOW}${BOLD}        WELCOME TO MY CHANNEL      ${RESET}"
echo "${BLUE}${BOLD}--------------------------------------------------------${RESET}"
echo

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Get Compute Zone & Region
echo "${YELLOW}${BOLD}Fetching Compute Zone & Region...${RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 2: Get IAM Policy and Save to JSON
echo "${BLUE}${BOLD}Retrieving IAM Policy...${RESET}"
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --format=json > policy.json

# Step 3: Update IAM Policy
echo "${GREEN}${BOLD}Updating IAM Policy...${RESET}"
jq '{ 
  "auditConfigs": [ 
    { 
      "service": "cloudresourcemanager.googleapis.com", 
      "auditLogConfigs": [ 
        { 
          "logType": "ADMIN_READ" 
        } 
      ] 
    } 
  ] 
} + .' policy.json > updated_policy.json

# Step 4: Set Updated IAM Policy
echo "${RED}${BOLD}Applying Updated IAM Policy...${RESET}"
gcloud projects set-iam-policy $(gcloud config get-value project) updated_policy.json

# Step 5: Enable Security Center API
echo "${CYAN}${BOLD}Enabling Security Center API...${RESET}"
gcloud services enable securitycenter.googleapis.com --project=$DEVSHELL_PROJECT_ID

# Step 6: Wait for 20 seconds
echo "${YELLOW}${BOLD}Waiting for API to be enabled...${RESET}"
sleep 20

# Step 7: Add IAM Binding for BigQuery Admin
echo "${MAGENTA}${BOLD}Granting BigQuery Admin Role...${RESET}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 8: Remove IAM Binding for BigQuery Admin
echo "${BLUE}${BOLD}Revoking BigQuery Admin Role...${RESET}"
gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 9: Add IAM Binding for IAM Admin
echo "${GREEN}${BOLD}Granting IAM Admin Role...${RESET}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_EMAIL \
  --role=roles/cloudresourcemanager.projectIamAdmin 2>/dev/null

# Step 10: Create Compute Instance
echo "${BLUE}${BOLD}Creating Compute Instance...${RESET}"
gcloud compute instances create instance-1 \
--zone=$ZONE \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230912,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced

# Step 11: Create DNS Policy
echo "${CYAN}${BOLD}Creating DNS Policy...${RESET}"
gcloud dns --project=$DEVSHELL_PROJECT_ID policies create dns-test-policy --description="quickgcplab" --networks="default" --private-alternative-name-servers="" --no-enable-inbound-forwarding --enable-logging

# Step 12: Wait for 30 seconds
echo "${YELLOW}${BOLD}Waiting for DNS Policy to take effect...${RESET}"
sleep 30

# Step 13: SSH into Compute Instance and Execute Commands
echo "${MAGENTA}${BOLD}Connecting to Compute Instance...${RESET}"
gcloud compute ssh instance-1 --zone=$ZONE --tunnel-through-iap --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud projects get-iam-policy \$(gcloud config get project) && curl etd-malware-trigger.goog"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${BOLD}${YELLOW}Have you checked your progress for Task 1 & Task 2? (Y/N): ${RESET}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD}${GREEN}Great! Proceeding to the next steps...${RESET}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD}${RED}Please check your progress for Task 1 & Task 2 and then press Y to continue.${RESET}"
        else
            echo
            echo "${BOLD}${MAGENTA}Invalid input. Please enter Y or N.${RESET}"
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 14: Delete Compute Instance
echo "${BLUE}${BOLD}Deleting Compute Instance...${RESET}"
gcloud compute instances delete instance-1 --zone=$ZONE --quiet

echo

function show_subscription_prompt() {
    echo "${BLUE}${BOLD}"
    echo "--------------------------------------------------------"
    echo " LIKE, SHARE, AND SUBSCRIBE TO DR ABHISHEK CLOUD CHANNEL"
    echo " For more cloud tutorials and automation scripts!"
    echo 
    echo " YouTube: https://www.youtube.com/@drabhishek.5460"
    echo "--------------------------------------------------------"
    echo "${RESET}"
}

# Display subscription prompt
show_subscription_prompt

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
