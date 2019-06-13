Parameters t_dokprop_id

Local l_arv_id, l_onnestus
v_arv_id = 0
l_onnestus = .F.

If !Used('v_xml_arv')
	Messagebox('Arved ei leidnud',0+64,'Import ostuarved')
	Return 0
Endif

l_model = 'raamatupidamine\arv'


If Type('Odb') = 'U'
	Set Classlib To classes\Classlib
	oDb = Createobject('db')
	oDb.login = 'temp'
	oDb.Pass = '12345'
	gnHandle = SQLConnect('test_server','temp','12345')
	gRekv = 63
	gUserId = 70
Endif

* load model

tnId = -1
l_error = oDb.readFromModel(l_model, 'row', 'tnId, guserid', 'v_arv')
If !l_error Or !Used('v_arv')
	Set Step On
	Return .F.
Endif

l_error = oDb.readFromModel(l_model, 'details', 'tnId, guserid', 'v_arvread')
If !l_error Or !Used('v_arvread')
	Set Step On
	Return .F.
Endif

Select v_xml_arv
Wait Window 'Importeerin arve nr. ' + Alltrim(v_xml_arv.Number) Timeout 1

* asutusId
Select comAsutusRemote
Locate For Alltrim(regkood) = Alltrim(v_xml_arv.regkood)

If !Found()
	Messagebox('Asutus:' + Alltrim(v_xml_arv.asutus) + ',' + Alltrim(v_xml_arv.regkood) + ' ei leidnud',0+64,'e-Arve import')
Else
	Select v_arv

	Insert Into v_arv (rekvid, Userid, doklausId, Number, liik, kpv, asutusid, Summa, kbmta, kbm, tahtaeg, lisa) ;
		VALUES (gRekv, gUserId, t_dokprop_id, v_xml_arv.Number, 1, v_xml_arv.kpv, comAsutusRemote.Id, v_xml_arv.Summa, ;
		v_xml_arv.kbmta, v_xml_arv.kbm, v_xml_arv.tahtpaev, v_xml_arv.lisa)


* details
	Select 	v_xml_arv_detail
	Scan For Id = v_xml_arv.Id
* seach for noms
		l_nom_id = getNomIdByNimetus(Alltrim(Upper('OMNIVA')))

		Insert Into v_arvread (nomid, kogus, hind, Summa, kbmta, km, kbm, nimetus, konto, tp, kood1, kood2, kood5, MUUD) ;
			VALUES (l_nom_id, v_xml_arv_detail.kogus, v_xml_arv_detail.Summa / v_xml_arv_detail.kogus, ;
			v_xml_arv_detail.summa_kokku, v_xml_arv_detail.Summa,v_xml_arv_detail.kbm_maar, v_xml_arv_detail.kbm,;
			v_xml_arv_detail.nimetus,;
			v_xml_arv_detail.konto,;
			comAsutusRemote.tp, v_xml_arv_detail.tegev, v_xml_arv_detail.allikas, v_xml_arv_detail.artikkel, ;
			v_xml_arv_detail.nimetus)
	Endscan

	Select v_arvread
	If Reccount('v_arvread') > 0 And Reccount('v_arv') > 0
		l_onnestus = .T.
	Endif


Endif

* saving
If l_onnestus
	l_error = save_arve()

	If Used('v_arv_id')
		l_arv_id = v_arv_id.Id
		Use In v_arv_id
	Endif
ELSE
	l_arv_id = 0
Endif



Use In v_arv

Use In v_arvread

Return l_arv_id
Endfunc


Function save_arve
	If Empty(v_arv.rekvid)
		Replace rekvid With gRekv,;
			userId With gUserId In v_arv
	Endif

	lcJson = ''
	Select v_arvread
	Go Top
	lcJson = '"gridData":['+ oDb.getJson() + ']'

	Select v_arv
	lcJson = '{"id":' + Alltrim(Str(v_arv.Id)) + ',"data": '+ oDb.getJson(lcJson) +  '}'
	lError = oDb.readFromModel(l_model, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_arv_id')
	Return lError

Endfunc



Function getNomIdByNimetus
	Parameters tcNimetus
	Local l_id

	Select comNomRemote
	Locate For Alltrim(Upper(kood)) = tcNimetus And dok = 'ARV'
	If Found()
		l_id = comNomRemote.Id
	Else
		Messagebox('Nomenklatuur ei leidnud'+ tcNimetus,0+64,'Import ostuarved')
		Return 0
* save noms
*	INSERT INTO comNomRemote (id, kood, nimetus) VALUES (2,'',tcNimetus)
*	l_id = comNomRemote.id
	Endif
	Return l_id

Endfunc



