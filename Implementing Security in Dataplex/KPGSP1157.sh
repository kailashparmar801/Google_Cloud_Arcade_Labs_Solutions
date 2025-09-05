

gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

export PROJECT_ID=$(gcloud config get-value project)

gcloud services enable dataplex.googleapis.com datacatalog.googleapis.com

gcloud dataplex lakes create customer-info-lake --location=$REGION --display-name="Techcps Info Lake"

gcloud dataplex zones create customer-raw-zone --location=$REGION --display-name="Techcps Raw Zone" --lake=customer-info-lake --type=RAW --resource-location-type=SINGLE_REGION

gcloud dataplex assets create customer-online-sessions \
  --location=$REGION \
  --display-name="Techcps Online Sessions" \
  --lake=customer-info-lake \
  --zone=customer-raw-zone \
  --resource-type=STORAGE_BUCKET \
  --resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID-bucket

