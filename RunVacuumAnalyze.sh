#!/bin/bash
# DbConnection string:
databaseName="TestDb-loc"
userName="ptgres"
PGPASSWORD="ptgres"

# Schema.table param [jobs|public]:
table_schema="jobs"
target=""

tables=$(psql -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = '$table_schema' AND table_type = 'BASE TABLE';" --dbname=$databaseName --host=localhost --port=5432 --username=$userName)
for item in $tables
do
target+=" --table=\"$table_schema\".\"${item}\" "
done          
vacuumdb --echo --freeze --jobs=2 --verbose --analyze --host=localhost --port=5432 --username=$userName --dbname=$databaseName $target
