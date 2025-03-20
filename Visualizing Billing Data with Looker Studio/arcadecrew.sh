#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                  Starting the process...                   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo


echo "${YELLOW_TEXT}${BOLD_TEXT}Running BigQuery SQL queries...${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}Querying all records from billing export table...${RESET_FORMAT}"
bq query --use_legacy_sql=false \
"
SELECT * FROM \`ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999\`
"


echo "${BLUE_TEXT}${BOLD_TEXT}Retrieving unique service descriptions...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT service.description FROM \`ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999\` GROUP BY service.description
"


echo "${BLUE_TEXT}${BOLD_TEXT}Counting occurrences of each service description...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT service.description, COUNT(*) AS num FROM \`ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999\` GROUP BY service.description
"


echo "${BLUE_TEXT}${BOLD_TEXT}Retrieving unique billing regions...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT location.region FROM \`ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999\` GROUP BY location.region
"


echo "${BLUE_TEXT}${BOLD_TEXT}Counting occurrences of each billing region...${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
SELECT location.region, COUNT(*) AS num FROM \`ctg-storage.bigquery_billing_export.gcp_billing_export_v1_01150A_B8F62B_47D999\` GROUP BY location.region
"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe our Channel:${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@Arcade61432${RESET_FORMAT}"
echo