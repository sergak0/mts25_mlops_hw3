USE teta;

DROP TABLE IF EXISTS teta.transactions_optimized;

CREATE TABLE teta.transactions_optimized
(
    `transaction_time` DateTime,
    `merch`            LowCardinality(String),
    `cat_id`           LowCardinality(String),
    `amount`           Float64 CODEC(ZSTD(3)),
    `name_1`           String,
    `name_2`           String,
    `gender`           LowCardinality(String),
    `street`           String,
    `one_city`         LowCardinality(String),
    `us_state`         LowCardinality(String),
    `post_code`        String,
    `lat`              Float32,
    `lon`              Float32,
    `population_city`  UInt32,
    `jobs`             LowCardinality(String),
    `merchant_lat`     Float32,
    `merchant_lon`     Float32,
    `target`           UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

INSERT INTO teta.transactions_optimized
SELECT *
FROM teta.transactions;
