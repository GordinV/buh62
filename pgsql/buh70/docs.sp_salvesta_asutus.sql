DROP FUNCTION IF EXISTS docs.sp_salvesta_asutus( JSON, INTEGER, INTEGER );
DROP FUNCTION IF EXISTS libs.sp_salvesta_asutus( JSON, INTEGER, INTEGER );

CREATE OR REPLACE FUNCTION libs.sp_salvesta_asutus(
  data        JSON,
  userid      INTEGER,
  user_rekvid INTEGER)
  RETURNS INTEGER AS
$BODY$

DECLARE
  asutus_id   INTEGER;
  userName    TEXT;
  doc_id      INTEGER = data ->> 'id';
  doc_data    JSON = data ->> 'data';
  doc_regkood TEXT = doc_data ->> 'regkood';
  doc_nimetus TEXT = doc_data ->> 'nimetus';
  doc_omvorm  TEXT = doc_data ->> 'omvorm';
  doc_kontakt TEXT = doc_data ->> 'kontakt';
  doc_aadress TEXT = doc_data ->> 'aadress';
  doc_tel     TEXT = doc_data ->> 'tel';
  doc_email   TEXT = doc_data ->> 'email';
  doc_mark    TEXT = doc_data ->> 'mark';
  doc_muud    TEXT = doc_data ->> 'muud';
  doc_pank    TEXT = doc_data ->> 'pank';
  doc_kmkr    TEXT = doc_data ->> 'kmkr';
  doc_KEHTIVUS DATE = doc_data ->> 'kehtivus';
  new_properties JSONB;
  json_object JSON;
  json_record RECORD;
  new_history JSONB;
  new_rights  JSONB;
  ids         INTEGER [];
BEGIN


  SELECT kasutaja
  INTO userName
  FROM userid u
  WHERE u.rekvid = user_rekvid AND u.id = userId;
  IF userName IS NULL
  THEN
    RAISE NOTICE 'User not found %', user;
    RETURN 0;
  END IF;
	
  IF (doc_id IS NULL)
  THEN
    doc_id = doc_data ->> 'id';
  END IF;

  SELECT row_to_json(row)
  INTO new_properties
  FROM (SELECT doc_kehtivus as kehtivus, doc_pank as pank, doc_kmkr as kmkr) row;


  -- вставка или апдейт docs.doc
  IF doc_id IS NULL OR doc_id = 0
  THEN

    SELECT row_to_json(row)
    INTO new_history
    FROM (SELECT
            now()    AS created,
            userName AS user) row;
    SELECT row_to_json(row)
    INTO new_rights
    FROM (SELECT
            ARRAY [userId] AS "select",
            ARRAY [userId] AS "update",
            ARRAY [userId] AS "delete") row;

    INSERT INTO libs.asutus (rekvid, regkood, nimetus, omvorm, kontakt, aadress, tel, email, mark, muud, properties)
    VALUES (user_rekvid, doc_regkood, doc_nimetus, doc_omvorm, doc_kontakt, doc_aadress, doc_tel, doc_email, doc_mark,
            doc_muud, new_properties)
    RETURNING id
      INTO asutus_id;


  ELSE
    -- history
    SELECT row_to_json(row)
    INTO new_history
    FROM (SELECT
            now()    AS updated,
            userName AS user) row;

    UPDATE libs.asutus
    SET
      regkood = doc_regkood,
      nimetus = doc_nimetus,
      omvorm  = doc_omvorm,
      kontakt = doc_kontakt,
      aadress = doc_aadress,
      tel     = doc_tel,
      email   = doc_email,
      mark    = doc_mark,
      muud    = doc_muud,
      properties = new_properties
    WHERE id = doc_id
    RETURNING id
      INTO asutus_id;

  END IF;

  RETURN asutus_id;

END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

GRANT EXECUTE ON FUNCTION libs.sp_salvesta_asutus(JSON, INTEGER, INTEGER) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION libs.sp_salvesta_asutus(JSON, INTEGER, INTEGER) TO dbpeakasutaja;


/*
select docs.sp_salvesta_asutus('{"id":0,"data":{"id":0,"number":"321","summa":24,"rekvid":null,"liik":0,"operid":null,"kpv":"2016-05-05","asutusid":1,"arvid":null,"lisa":"lisa","tahtaeg":"2016-05-19","kbmta":null,"kbm":4,"tasud":null,"tasudok":null,"muud":"muud","jaak":"0.00","objektid":null,"objekt":null,"regkood":null,"asutus":null},
"details":[{"id":"NEW0.6577064044198089","[object Object]":null,"nomid":"1","kogus":2,"hind":10,"kbm":4,"kbmta":20,"summa":24,"kood":"PAIGALDUS","nimetus":"PV paigaldamine"}]}',1, 1);

select * from libs.asutus

*/