# Register Ingester DK

Register Ingester DK is a data ingester for the [OpenOwnership](https://www.openownership.org/en/) [Register](https://github.com/openownership/register) project. It processes bulk data published in the Central Business Register published by the Danish Business Authority in Denmark, and ingests records into [Elasticsearch](https://www.elastic.co/elasticsearch/). Optionally, it can also publish new records to [AWS Kinesis](https://aws.amazon.com/kinesis/). It uses raw records only, and doesn't do any conversion into the [Beneficial Ownership Data Standard (BODS)](https://www.openownership.org/en/topics/beneficial-ownership-data-standard/) format.

## Installation

Install and boot [Register](https://github.com/openownership/register).

Configure your environment using the example file:

```sh
cp .env.example .env
```

- `DK_CVR_PASSWORD`: DK Elasticsearch source password
- `DK_CVR_USERNAME`: DK Elasticsearch source username
- `DK_STREAM`: AWS Kinesis stream to which to publish new records (optional)

Create the Elasticsearch indexes:

```sh
docker compose run ingester-dk create-indexes
```

## Testing

Run the tests:

```sh
docker compose run ingester-dk test
```

## Usage

To ingest the bulk data:

```sh
docker compose run ingester-dk ingest-bulk
```
