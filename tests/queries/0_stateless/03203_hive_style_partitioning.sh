#!/usr/bin/env bash
# Tags: no-fasttest

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../shell_config.sh
. "$CURDIR"/../shell_config.sh

$CLICKHOUSE_LOCAL -q "SELECT 'TESTING THE FILE HIVE PARTITIONING'"


$CLICKHOUSE_LOCAL -n -q """
set use_hive_partitioning = 1;

SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/sample.parquet') LIMIT 10;

SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/sample.parquet') WHERE column0 = _column0;

SELECT *, _column0, _column1 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column1 = _column1;
SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column1 = _column1;

SELECT *, _column0, _column1 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;
SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;

SELECT *, _column0, _column1 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column1 = _column1;
SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column1 = _column1;

SELECT *, _column0, _column1 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;
SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;

SELECT *, _non_existing_column FROM file('$CURDIR/data_hive/partitioning/non_existing_column=Elizabeth/sample.parquet') LIMIT 10;
SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=*/sample.parquet') WHERE column0 = _column0;

SELECT _number, _date FROM file('$CURDIR/data_hive/partitioning/number=42/date=2020-01-01/sample.parquet') LIMIT 1;
SELECT _array, _float FROM file('$CURDIR/data_hive/partitioning/array=[1,2,3]/float=42.42/sample.parquet') LIMIT 1;
SELECT toTypeName(_array), toTypeName(_float) FROM file('$CURDIR/data_hive/partitioning/array=[1,2,3]/float=42.42/sample.parquet') LIMIT 1;
SELECT count(*) FROM file('$CURDIR/data_hive/partitioning/number=42/date=2020-01-01/sample.parquet') WHERE _number = 42;
"""

$CLICKHOUSE_LOCAL -n -q """
set use_hive_partitioning = 0;

SELECT *, _column0 FROM file('$CURDIR/data_hive/partitioning/column0=Elizabeth/sample.parquet') LIMIT 10;
""" 2>&1 | grep -c "UNKNOWN_IDENTIFIER"


$CLICKHOUSE_LOCAL -q "SELECT 'TESTING THE URL PARTITIONING'"


$CLICKHOUSE_LOCAL -n -q """
set use_hive_partitioning = 1;

SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/sample.parquet') LIMIT 10;

SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/sample.parquet') WHERE column0 = _column0;

SELECT *, _column0, _column1 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column1 = _column1;
SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column1 = _column1;

SELECT *, _column0, _column1 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;
SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;

SELECT *, _column0, _column1 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column1 = _column1;
SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column1 = _column1;

SELECT *, _column0, _column1 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;
SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;

SELECT *, _non_existing_column FROM url('http://localhost:11111/test/hive_partitioning/non_existing_column=Elizabeth/sample.parquet') LIMIT 10;"""

$CLICKHOUSE_LOCAL -n -q """
set use_hive_partitioning = 0;

SELECT *, _column0 FROM url('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/sample.parquet') LIMIT 10;
""" 2>&1 | grep -c "UNKNOWN_IDENTIFIER"


$CLICKHOUSE_LOCAL -q "SELECT 'TESTING THE S3 PARTITIONING'"


$CLICKHOUSE_LOCAL -n -q """
set use_hive_partitioning = 1;

SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/sample.parquet') LIMIT 10;

SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/sample.parquet') WHERE column0 = _column0;

SELECT *, _column0, _column1 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column1 = _column1;
SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column1 = _column1;

SELECT *, _column0, _column1 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;
SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Schmidt/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;

SELECT *, _column0, _column1 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column1 = _column1;
SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column1 = _column1;

SELECT *, _column0, _column1 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;
SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/column1=Gordon/sample.parquet') WHERE column0 = _column0 AND column1 = _column1;

SELECT *, _non_existing_column FROM s3('http://localhost:11111/test/hive_partitioning/non_existing_column=Elizabeth/sample.parquet') LIMIT 10;
SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=*/sample.parquet') WHERE column0 = _column0;
"""

$CLICKHOUSE_LOCAL -n -q """
set use_hive_partitioning = 0;

SELECT *, _column0 FROM s3('http://localhost:11111/test/hive_partitioning/column0=Elizabeth/sample.parquet') LIMIT 10;
""" 2>&1 | grep -c "UNKNOWN_IDENTIFIER"
