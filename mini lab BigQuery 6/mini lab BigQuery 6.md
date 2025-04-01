# mini lab : BigQuery : 6

## 🔑 Solution [here](https://youtu.be/3C1cwrmRSos)

### ⚙️ Execute the Following Commands in Cloud Shell

```
PROJECT_ID=$(gcloud config get-value project)
REGION="us"

gcloud iam service-accounts add-iam-policy-binding ${PROJECT_ID}@${PROJECT_ID}.iam.gserviceaccount.com \
--role='roles/iam.serviceAccountTokenCreator'

sleep 20

bq mk --transfer_config --project_id="${PROJECT_ID}" --target_dataset=ecommerce --display_name="Monthly Customer Orders Backup" --params='{"query":"SELECT * FROM `'${PROJECT_ID}'.ecommerce.customer_orders`", "destination_table_name_template":"backup_orders", "write_disposition":"WRITE_TRUNCATE"}' --data_source=scheduled_query --schedule="1 of month 00:00" --location="${REGION}"
```

# 🎉 Woohoo! You Did It! 🎉

Your hard work and determination paid off! 💻
You've successfully completed the lab. **Way to go!** 🚀

### 💬 Stay Connected with Our Community!
👉 Join the conversation and never miss an update:
📢 [Telegram Channel](https://t.me/quickgcplab)
👥 [Discussion Group](https://t.me/quickgcplabchats)

# [QUICK GCP LAB](https://www.youtube.com/@quickgcplab)
