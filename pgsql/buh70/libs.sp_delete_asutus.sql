DROP FUNCTION if exists libs.sp_delete_asutus(integer, integer);

CREATE OR REPLACE FUNCTION libs.sp_delete_asutus(
    IN userid integer,
    IN doc_id integer,
    OUT error_code integer,
    OUT result integer,
    OUT error_message text)
  RETURNS record AS
$BODY$

declare
	v_doc record;
	v_dependid_docs record;
	ids integer[];	
	asutus_history jsonb ;
	new_history jsonb;
begin
	
	select a.*, u.ametnik as user_name into v_doc
		from libs.asutus a 
		left outer join ou.userid u on u.id = userid
		where a.id = doc_id;

	-- проверка на пользователя и его соответствие учреждению

	if v_doc is null then
		error_code = 6; 
		error_message = 'Dokument ei leitud, docId: ' || coalesce(doc_id,0)::text ;
		result  = 0;
		return;

	end if;

	if not exists (select id 
		from ou.userid u 
		where id = userid
		and (u.rekvid = v_doc.rekvid or v_doc.rekvid is null or v_doc.rekvid = 0) 
		) then

		error_code = 5; 
		error_message = 'Kasutaja ei leitud, rekvId: ' || coalesce(v_doc.rekvid,0)::text || ', userId:' || coalesce(userid,0)::text;
		result  = 0;
		return;

	end if;	

	-- проверка на права. Предполагает наличие прописанных прав на удаление для данного пользователя в поле rigths


--	ids =  v_doc.rigths->'delete';
/*
	if not v_doc.rigths->'delete' @> jsonb_build_array(userid) then
		raise notice 'У пользователя нет прав на удаление'; 
		error_code = 4; 
		error_message = 'Ei saa kustuta dokument. Puudub õigused';
		result  = 0;
		return;

	end if;
*/			
	-- Проверка на наличие связанных документов и их типов (если тип не проводка, то удалять нельзя)

	if exists (
		select 1 from (
			select id  from docs.journal where asutusId = doc_id 
			union 
			select id from docs.arv where asutusid = doc_id
			union 
			select id from docs.korder1 where asutusid = doc_id 
			union 
			select id from docs.mk1 where asutusId = doc_id 
		) qry
	) then

		raise notice 'Есть связанные доку менты. удалять нельзя'; 
		error_code = 3; -- Ei saa kustuta dokument. Kustuta enne kõik seotud dokumendid
		error_message = 'Ei saa kustuta dokument. Kustuta enne kõik seotud dokumendid';
		result  = 0;
		return;
	end if;

	-- Логгирование удаленного документа

	asutus_history = row_to_json(row.*) from (select a.* 
		from libs.asutus a where a.id = doc_id) row;

	select row_to_json(row) into new_history from (select now() as deleted, v_doc.user_name as user, asutus_history as asutus) row;

	-- Установка статуса ("Удален")  и сохранение истории
--	delete from libs.asutus where id = doc_id;
	update libs.asutus set staatus = 3 where id = doc_id;
	
/*
	update docs.doc 
		set lastupdate = now(),
			history = coalesce(history,'[]')::jsonb || new_history,
			rekvid = v_doc.rekvid,
			status = DOC_STATUS
		where id = doc_id;	
*/		
	result  = 1;		
	return;
end;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

GRANT EXECUTE ON FUNCTION libs.sp_delete_asutus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION libs.sp_delete_asutus(integer, integer) TO dbpeakasutaja;
