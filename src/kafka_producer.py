import argparse
import csv
import json
import os

from kafka import KafkaProducer


def iter_csv_rows(csv_path: str):
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            yield row


def main():
    parser = argparse.ArgumentParser(
        description="Load CSV file into Kafka topic"
    )
    parser.add_argument(
        "--csv-path",
        default=os.getenv("CSV_PATH", "/app/data/train.csv"),
        help="Path to train.csv file",
    )
    parser.add_argument(
        "--bootstrap-servers",
        default=os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:29092"),
        help="Kafka bootstrap servers (comma separated)",
    )
    parser.add_argument(
        "--topic",
        default=os.getenv("KAFKA_TOPIC", "teta_train"),
        help="Kafka topic name",
    )

    args = parser.parse_args()

    producer = KafkaProducer(
        bootstrap_servers=args.bootstrap_servers.split(","),
        value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    )

    sent = 0
    try:
        for i, row in enumerate(iter_csv_rows(args.csv_path), start=1):
            producer.send(args.topic, row)
            sent += 1
            if i % 1000 == 0:
                producer.flush()
                print(f"Sent {i} messages...")

        producer.flush()
        print(f"Finished. Total messages sent: {sent}")
    finally:
        producer.close()


if __name__ == "__main__":
    main()
