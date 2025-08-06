

gcloud auth list

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/region "$REGION"

git clone https://github.com/GoogleCloudPlatform/terraform-google-lb
cd ~/terraform-google-lb/examples/basic

export GOOGLE_PROJECT=$(gcloud config get-value project)

terraform init

sed -i 's/us-central1/'"$REGION"'/g' variables.tf

echo "$GOOGLE_PROJECT" | terraform plan

echo "$GOOGLE_PROJECT" | terraform apply --auto-approve

EXTERNAL_IP=$(terraform output | grep load_balancer_default_ip | cut -d = -f2 | xargs echo -n)

echo "http://${EXTERNAL_IP}"

