CREATE DATABASE IF NOT EXISTS teta;

DROP TABLE IF EXISTS teta.transactions_kafka;

CREATE TABLE teta.transactions_kafka
(
    `transaction_time` String,
    `merch`            String,
    `cat_id`           String,
    `amount`           String,
    `name_1`           String,
    `name_2`           String,
    `gender`           String,
    `street`           String,
    `one_city`         String,
    `us_state`         String,
    `post_code`        String,
    `lat`              String,
    `lon`              String,
    `population_city`  String,
    `jobs`             String,
    `merchant_lat`     String,
    `merchant_lon`     String,
    `target`           String
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list       = 'kafka:29092',
    kafka_topic_list        = 'teta_train',
    kafka_group_name        = 'teta_clickhouse_group',
    kafka_format            = 'JSONEachRow',
    kafka_num_consumers     = 1,
    kafka_handle_error_mode = 'stream';


DROP TABLE IF EXISTS teta.transactions;

CREATE TABLE teta.transactions
(
    `transaction_time` DateTime,
    `merch`            String,
    `cat_id`           String,
    `amount`           Float64,
    `name_1`           String,
    `name_2`           String,
    `gender`           String,
    `street`           String,
    `one_city`         String,
    `us_state`         String,
    `post_code`        String,
    `lat`              Float64,
    `lon`              Float64,
    `population_city`  UInt32,
    `jobs`             String,
    `merchant_lat`     Float64,
    `merchant_lon`     Float64,
    `target`           UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (transaction_time, us_state, cat_id);


DROP VIEW IF EXISTS teta.transactions_mv;

CREATE MATERIALIZED VIEW teta.transactions_mv
TO teta.transactions
AS
SELECT
    parseDateTimeBestEffort(transaction_time)       AS transaction_time,
    merch,
    cat_id,
    toFloat64OrZero(amount)                         AS amount,
    name_1,
    name_2,
    gender,
    street,
    one_city,
    us_state,
    post_code,
    toFloat64OrZero(lat)                            AS lat,
    toFloat64OrZero(lon)                            AS lon,
    toUInt32OrZero(population_city)                 AS population_city,
    jobs,
    toFloat64OrZero(merchant_lat)                   AS merchant_lat,
    toFloat64OrZero(merchant_lon)                   AS merchant_lon,
    toUInt8OrZero(target)                           AS target
FROM teta.transactions_kafka;
