﻿-- Function: sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying)

-- DROP FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying);

/*

select sp_salvesta_arv1(501::int,466::int,48::int,1.00::numeric,25.00::numeric,0::int,0.00::numeric,0::int,25.00::numeric,''::text,''::varchar,''::varchar,''::varchar,''::varchar,''::varchar,'3512'::varchar,'800599'::varchar,25.00::numeric,0::int,''::varchar,'EEK'::varchar,1.00::numeric,'EEK'::varchar)

select * from dokvaluuta1 order by id desc limit 5

SELECT Arv.id, Arv.number, Arv.kpv as kpv, Arv.tahtaeg, Arv.summa, Arv.tasud,  Arv.tasudok,  ARV.USERID, Asutus.nimetus AS asutus,  arv.asutusid, 
Arv.journalid, arv.liik, arv.operId, arv.jaak, arv.objektId, 
ARV.DOKLAUSID, ifnull(dokprop.konto,space(20)) as konto, arv.muud,
ifnull(dokvaluuta1.valuuta,'EEK')::VARCHAR as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
FROM  Arv INNER join  asutus Asutus on asutus.id = ARV.asutusId inner join userid on arv.userid = userid.id 
left outer join dokprop on dokprop.id = arv.doklausId left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2)
order by arv.id desc limit 10


SELECT Arv.id, Arv.number, Arv.kpv as kpv, Arv.tahtaeg, Arv.summa, Arv.tasud,  Arv.tasudok,  ARV.USERID, Asutus.nimetus AS asutus,  arv.asutusid, Arv.journalid, 
arv.liik, arv.operId, arv.jaak, arv.objektId, ARV.DOKLAUSID, ifnull(dokprop.konto,space(20)) as konto, arv.muud,ifnull(dokvaluuta1.valuuta,'EEK')::VARCHAR as valuuta, 
ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
FROM  Arv INNER join  asutus Asutus on asutus.id = ARV.asutusId inner join userid on arv.userid = userid.id left outer join dokprop on dokprop.id = arv.doklausId 
left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokliik = 3) 
order by arv.id desc limit 10

*/
CREATE OR REPLACE FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tnkogus alias for $4;
	tnhind alias for $5;
	tnsoodus alias for $6;
	tnkbm alias for $7;
	tnmaha alias for $8;
	tnsumma alias for $9;
	ttmuud alias for $10;
	tckood1 alias for $11;
	tckood2 alias for $12;
	tckood3 alias for $13;
	tckood4 alias for $14;
	tckood5 alias for $15;
	tckonto alias for $16;
	tctp alias for $17;
	tnkbmta alias for $18;
	tnisikid alias for $19;
	tctunnus alias for $20;
	tcValuuta alias for $21;
	tnKuurs alias for $22;
	tcProj alias for $23;
	lnarv1Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into arv1 (parentid,nomid,kogus,hind,soodus,kbm,maha,summa,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,kbmta,isikid,tunnus,proj) 
		values (tnparentid,tnnomid,tnkogus,tnhind,tnsoodus,tnkbm,tnmaha,tnsumma,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tnkbmta,tnisikid,tctunnus,tcProj);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnarv1Id:= cast(CURRVAL('public.arv1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnarv1Id = 0;
	end if;

	if lnarv1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
		values (lnarv1Id,2,tcValuuta, tnKuurs);


else
	-- muuda 
	select * into lrCurRec from arv1 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind or lrCurRec.soodus <> tnsoodus 
		or lrCurRec.kbm <> tnkbm or lrCurRec.maha <> tnmaha or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 
		or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.kbmta <> tnkbmta 
		or lrCurRec.isikid <> tnisikid or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then 
	update arv1 set 
		parentid = tnparentid,
		nomid = tnnomid,
		kogus = tnkogus,
		hind = tnhind,
		soodus = tnsoodus,
		kbm = tnkbm,
		maha = tnmaha,
		summa = tnsumma,
		muud = ttmuud,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		konto = tckonto,
		tp = tctp,
		kbmta = tnkbmta,
		isikid = tnisikid,
		tunnus = tctunnus,
		proj = tcProj
	where id = tnId;
	end if;
	lnarv1Id := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 2 and dokid = lnarv1Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (2, lnarv1Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 2 and dokid = lnarv1Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

						
		end if;
	
	end if;
	
end if;

	-- kontrollin valuuta arv taabelis

	if (select count(id) from dokvaluuta1 where dokliik = 3 and dokid = tnParentId) = 0 then
	
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (tnParentId,3,tcValuuta, tnKuurs);
	else
	
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = tnParentId and dokliik = 3;

	end if;

	perform sp_updatearvjaak(tnParentId, date());

         return  lnarv1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_arv1(integer, integer, integer, numeric, numeric, integer, numeric, integer, numeric, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, integer, character varying, character varying,numeric,character varying) TO dbpeakasutaja;
