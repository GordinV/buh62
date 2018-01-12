
DROP FUNCTION if exists libs.check_asutus(tnAsutusId integer, tnRekvId integer);

CREATE OR REPLACE FUNCTION libs.check_asutus(tnAsutusId integer, tnRekvId integer)
  RETURNS boolean AS
$BODY$

begin
	if not exists 
	(select 1 from tooleping 
		where parentId = tnAsutusId 
		and rekvid <> tnRekvId 
		and  not exists (select 1 from tooleping t 
			where parentId = tnAsutusId  
			and rekvId = tnRekvId))   
		OR EXISTS (select 1 from docs.arv 
			where asutusid = tnAsutusId 
			and rekvid = tnRekvId)
		or exists (select 1 from docs.journal j 
			where asutusid = tnAsutusId  
			and j.rekvid = tnRekvId)	
		or exists (select 1 from docs.korder1 k 
			where asutusid = tnAsutusId  
			and k.rekvid = tnRekvId)
		or exists (select 1 from mk inner join mk1 m on mk.id = m.parentid 
			where m.asutusid = tnAsutusId and mk.rekvid = tnRekvId) then
		return true;
	else
		return false;
	end if;
	

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION libs.check_asutus(integer,integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION libs.check_asutus(integer,integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION libs.check_asutus(integer,integer) TO dbvaatleja;


select * from libs.asutus where libs.check_asutus(id,1)
