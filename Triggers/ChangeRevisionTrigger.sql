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
;
/*Пример триггера на таблицу "Organs".
* Цель: изменять (увеличивать) значение поля ревизии при любом изменении данных в таблице.
* Основа числа для ревизии - самовычисляемая последовательность (SEQUENCE).
*/
CREATE SEQUENCE IF NOT EXISTS public."Organs_Revision_Seq" MINVALUE 1
;
CREATE OR REPLACE FUNCTION Organs_ChangeRevision()
RETURNS TRIGGER AS $changes$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
	    IF(OLD."Title" != NEW."Title" OR OLD."IsDeleted" != NEW."IsDeleted") THEN
            NEW."Revision" := (SELECT nextval('public."Organs_Revision_Seq"'));
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        NEW."Revision" := (SELECT nextval('public."Organs_Revision_Seq"'));
        RETURN NEW;
    END IF;
RETURN NULL;
END;
$changes$ LANGUAGE plpgsql
;
CREATE TRIGGER "TR_Organs_ChangeRevision"
	BEFORE INSERT OR UPDATE
	 ON "Organs"
	FOR EACH ROW EXECUTE PROCEDURE Organs_ChangeRevision()
;