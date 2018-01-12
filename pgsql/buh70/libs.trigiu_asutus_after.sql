CREATE OR REPLACE FUNCTION libs.trigiu_asutus_after()
  RETURNS trigger AS
$BODY$
declare 
	lcErr varchar;
begin
	new.timestamp = localtimestamp;
return new;

end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE TRIGGER trigiu_asutus_after
  AFTER INSERT OR UPDATE
  ON libs.asutus
  FOR EACH ROW
  EXECUTE PROCEDURE libs.trigiu_asutus_after();
