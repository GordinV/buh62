{"sql": "select d.id, $2::integer as userid, to_char(created, 'DD.MM.YYYY HH:MM:SS')::text as created, to_char(lastupdate,'DD.MM.YYYY HH:MM:SS')::text as lastupdate, d.bpm, 
                 trim(l.nimetus) as doc, trim(l.kood) as doc_type_id,
                 trim(s.nimetus) as status, d.status as doc_status,
                 trim(a.number) as number, a.summa, a.rekvId, a.liik, a.operid, to_char(a.kpv,'YYYY-MM-DD') as kpv, 
                 a.asutusid, a.arvId, trim(a.lisa) as lisa, to_char(a.tahtaeg,'YYYY-MM-DD') as tahtaeg, a.kbmta, a.kbm, a.summa, 
                 a.tasud, trim(a.tasudok) as tasudok, a.muud, a.jaak, a.objektId, trim(a.objekt) as objekt, 
                 asutus.regkood, trim(asutus.nimetus) as asutus, 
                 a.doklausid, a.doklausid,dp.selg as dokprop 
                 from docs.doc d 
                 inner join libs.library l on l.id = d.doc_type_id 
                 inner join docs.arv a on a.parentId = d.id 
                 left outer join libs.library s on s.library = 'STATUS' and s.kood = d.status::text 
                 inner join libs.asutus as asutus on asutus.id = a.asutusId 
                 inner join ou.userid u on u.id = $2::integer 
                 left outer join libs.dokprop dp on dp.id = a.doklausid 
                 where d.id = $1"
}