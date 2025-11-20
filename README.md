# Hw3

Loads transactions from a csv file into Kafka, streams them into ClickHouse and runs a query to find the category of the largest transaction in each US state.  
It also includes an optimized ClickHouse table schema for faster queries.

---

## 1. Prerequisites

- Docker & Docker Compose installed
- Kaggle account to download `train.csv` from  
  https://www.kaggle.com/competitions/teta-ml-1-2025/data?select=train.csv

---

## 2. Project layout

```text
.
├── docker-compose.yml
├── Dockerfile.producer
├── requirements.txt
├── README.md
├── data/
│   └── train.csv
├── src/
│   └── kafka_producer.py
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_query_max_category_by_state.sql
│   ├── 02_query_max_category_by_state_optimized.sql
│   └── 03_optimized_tables.sql
└── results/
    ├── max_category_by_state.csv
    └── max_category_by_state_optimized.csv
```

1. csv -> Kafka: kafka_producer.py, producer service
2. ClickHouse from Kafka: 01_create_tables.sql
3. SQL + csv result: 02_query_max_category_by_state.sql, results/max_category_by_state.csv
4. Optimization: 03_optimized_tables.sql (+ optimized query & csv)

## 3. Setup

```commandline
git clone https://github.com/sergak0/mts25_mlops_hw3
cd mts25_mlops_hw3

mkdir -p data results
mv /path/to/train.csv data/train.csv
```

## 4. Start services

```commandline
docker compose up -d

docker exec -i clickhouse clickhouse-client \
  --user click --password click \
  --multiquery < sql/01_create_tables.sql
```

## 5. Load CSV → Kafka

```
docker compose run --rm producer
```

Check that data is in ClickHouse:

```commandline
docker exec -it clickhouse clickhouse-client \
  --user click --password click \
  --query "SELECT count() FROM teta.transactions"
```

## 6. Query: max transaction category per state

```
docker exec -i clickhouse clickhouse-client \
  --user click --password click \
  --query "$(cat sql/02_query_max_category_by_state.sql)" \
  --format CSVWithNames > results/max_category_by_state.csv
```
Result: results/max_category_by_state.csv.

## 7. Optimized schema (for 8–10)
Create optimized table and copy data:
```commandline
docker exec -i clickhouse clickhouse-client \
  --user click --password click \
  --multiquery < sql/03_optimized_tables.sql
```

Run optimized query:
```commandline
docker exec -i clickhouse clickhouse-client \
  --user click --password click \
  --query "$(cat sql/02_query_max_category_by_state_optimized.sql)" \
  --format CSVWithNames > results/max_category_by_state_optimized.csv
```

## 8. Stop

```commandline
docker compose down
```