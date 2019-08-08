--Postgresql
/*Пример триггера на таблицу "Organs".
* Цель: изменять (увеличивать) значение поля ревизии при любом изменении данных в таблице.
* Основа числа для ревизии - промежуток времени (эпоха) с константного значения postgresql до даты создания
* или обновления данных.
*/
CREATE TRIGGER "TR_Organs_ChangeRevision"
  BEFORE INSERT OR UPDATE OR DELETE
    ON "Organs"
FOR EACH ROW EXECUTE PROCEDURE Organs_ChangeRevision()
;
CREATE OR REPLACE FUNCTION Organs_ChangeRevision()
RETURNS TRIGGER AS $changes$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        NEW."Revision" := extract(epoch FROM coalesce(NEW."LastModificationTime", NEW."CreationTime"))::BIGINT;
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
      IF(OLD."Title" != NEW."Title") THEN
          NEW."Revision" := extract(epoch FROM coalesce(NEW."LastModificationTime", NEW."CreationTime"))::BIGINT;
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        NEW."Revision" := extract(epoch FROM coalesce(NEW."LastModificationTime", NEW."CreationTime"))::BIGINT;
        RETURN NEW;
    END IF;
    RETURN NULL;
 END;
$changes$ LANGUAGE plpgsql
;
