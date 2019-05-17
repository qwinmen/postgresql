@echo on
SetLocal EnableExtensions EnableDelayedExpansion
set PgsqlBin=C:\Projects\pgsql\10\bin
set vacuumdb=%PgsqlBin%\vacuumdb.exe
set psql=%PgsqlBin%\psql.exe

rem DbConnection string:
set databaseName=TestDb-loc
set userName=ptgres
set PGPASSWORD=ptgres

rem Schema.table param [jobs|public]:
set table_schema=public

For /F "tokens=* delims=" %%I In (' ^
%psql% -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = '%table_schema%' AND table_type = 'BASE TABLE';" --dbname=%databaseName% --echo-queries --host=localhost --port=5432 --username=%userName% 
') Do ^
For /f "tokens=1*" %%a in ("%%I") Do "%vacuumdb%" --echo --freeze --jobs=2 --verbose --analyze --host=localhost --port=5432 --username=%userName% --dbname=%databaseName% --table=\"%table_schema%\".\"%%a\"
