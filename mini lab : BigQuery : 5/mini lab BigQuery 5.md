# mini lab : BigQuery : 5

## 🔑 Solution [here](https://youtu.be/7nSSBSQled0)

### ⚙️ Execute the Following Commands in Cloud Shell

```
PROJECT_ID=$(gcloud config get-value project)

bq load --autodetect --source_format=CSV customer_details.customers customers.csv

bq query --use_legacy_sql=false 'CREATE OR REPLACE TABLE customer_details.male_customers AS SELECT CustomerID, Gender FROM customer_details.customers WHERE Gender = "Male"'

bq extract --destination_format=CSV customer_details.male_customers gs://${PROJECT_ID}-bucket/exported_male_customers.csv
```

# 🎉 Woohoo! You Did It! 🎉

Your hard work and determination paid off! 💻
You've successfully completed the lab. **Way to go!** 🚀

### 💬 Stay Connected with Our Community!
👉 Join the conversation and never miss an update:
📢 [Telegram Channel](https://t.me/quickgcplab)
👥 [Discussion Group](https://t.me/quickgcplabchats)

# [QUICK GCP LAB](https://www.youtube.com/@quickgcplab)
