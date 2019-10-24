#!/bin/bash
dumpFilePath="./testForRestore.dump"
userName="ptgres"
PGPASSWORD="ptgres"
defaultDbName="postgres";

databaseName=TestDb-loc-0;
#databaseName=TestDb-loc-1;

echo "Close all connection to database $databaseName";
psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$databaseName';" --dbname=$defaultDbName --host=127.0.0.1 --port=5432 --username=$userName

echo "Dropping database $databaseName"
dropdb -e --username=$userName --host=127.0.0.1 $databaseName

echo "Creating database $databaseName"
createdb -e --username=$userName --host=127.0.0.1 $databaseName

echo "Restoring database $databaseName from dump file $dumpFilePath..."
pg_restore --clean --host=127.0.0.1 --username=$userName --dbname=$databaseName --clean --if-exists $dumpFilePath

echo "Complete!"
