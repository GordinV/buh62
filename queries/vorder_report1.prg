Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
ENDIF

tnId = cWhere

If !Used('v_korder1')
	lError = oDb.readFromModel('raamatupidamine\vorder', 'row', 'tnId, guserid', 'v_korder1')
	lError = oDb.readFromModel('raamatupidamine\vorder', 'details', 'tnId, guserid', 'v_korder2')
Endif

Select v_korder1.Id, v_korder1.Number, v_korder1.kpv, v_korder1.nimi,  v_korder1.aadress, v_korder1.dokument, v_korder1.alus, ;
	v_Korder2.nimetus,  v_Korder2.Summa,  v_korder1.kassa As aa, v_korder1.kokku, ;
	v_Korder2.kood1,  v_Korder2.kood2, v_Korder2.kood3, v_Korder2.kood4, v_Korder2.kood5, ;
	v_Korder2.tunnus;
	FROM  v_korder1, v_Korder2 ;
	ORDER By v_Korder2.nimetus ;
	INTO Cursor vorder_report1


lError = oDb.readFromModel('raamatupidamine\journal', 'row', 'tnId, guserid', 'qryJournal')
lError = oDb.readFromModel('raamatupidamine\journal', 'details', 'tnId, guserid', 'qryJournal1')

Create Cursor vorder_lausend (Id Int, lausend m)
Append Blank
Select qryJournal1
Scan
	TEXT TO lcString TEXTMERGE noshow
					D: <<allrim(qryJournal1.deebet)>> TP: <<alltrim(qryJournal1.lisa_d)>>  K: <<alltrim(qryJournal1.kreedit)>>  TP: <<alltrim(qryJournal1.lisa_k)
	ENDTEXT
	TEXT TO lcString TEXTMERGE NOSHOW additive
					Summa  <<alltrim(Str (qryJournal1.Summa,12,2))>> Eel: <<alltrim(qryJournal1.kood5)>>
	ENDTEXT
	TEXT TO lcString TEXTMERGE NOSHOW additive
					TT: <<alltrim(qryJournal1.kood1)>>

	ENDTEXT

	Replace Id With qryJournal.Number,;
		vorder_lausend.lausend With lcString Additive In vorder_lausend
Endscan
If Used ('qryJournal')
	Use In qryJournal
Endif
If Used ('qryJournal1')
	Use In qryJournal1
Endif
Select vorder_report1


*!*	tnId = cWhere
*!*	cQuery = 'print_vorder1'
*!*	With odb
*!*		.use (cQuery,'vorder_report1',.t.)
*!*		.use ('v_korder1','qryVorder1')
*!*		.use ('v_korder2','qryVorder2')
*!*		If reccount ('qryvorder1') < 1
*!*			Select qryvorder1
*!*			Append blank
*!*		Endif

*!*		Select qryvorder2
*!*		If reccount ('qryvorder2') < 1
*!*			Append blank
*!*		Endif
*!*		Scan
*!*			lcNimetus = ''
*!*			If !empty (qryvorder2.nomid)
*!*				Select comNomremote
*!*				Locate for id = qryvorder2.nomid
*!*				lcNimetus = comNomremote.nimetus
*!*			Endif
*!*			Select vorder_report1
*!*			Append blank
*!*			Replace number with qryvorder1.number,;
*!*				kpv with qryvorder1.kpv,;
*!*				kokku with qryvorder1.summa,;
*!*				nimi with qryvorder1.nimi,;
*!*				aadress with qryvorder1.aadress,;
*!*				alus with qryvorder1.alus,;
*!*				nimetus with lcNimetus,;
*!*				summa with qryvorder2.summa,;
*!*				valuuta WITH qryvorder2.valuuta,;
*!*				kuurs WITH qryvorder2.kuurs,;
*!*				dokument with qryvorder1.dokument in vorder_report1

*!*		Endscan
*!*		Create cursor arve_lausend (id int, lausend m)

*!*		tnid = qryvorder1.journalid
*!*		.use ('v_journalid')
*!*		If reccount ('v_journalid') > 0
*!*			Insert into arve_lausend (id) values (v_journalid.number)
*!*			.use ('v_journal1','qryJournal1')
*!*			Select qryJournal1
*!*			Scan
*!*				lcString =  'D '+Ltrim(Rtrim(qryJournal1.deebet))+IIF(!EMPTY(qryJournal1.lisa_d),' TP '+Ltrim(Rtrim(qryJournal1.lisa_d)),'')++Space(1)+;
*!*					'K '+Ltrim(Rtrim(qryJournal1.kreedit)) + IIF(!EMPTY(qryJournal1.lisa_k),' TP '+Ltrim(Rtrim(qryJournal1.lisa_k)),'') + Space(1)+'Summa '+;
*!*					qryJournal1.valuuta+' '+alltrim(Str (qryJournal1.Summa,12,2)) + Space(1)+IIF(!EMPTY(qryJournal1.kood5),' Eel. '+Ltrim(Rtrim(qryJournal1.kood5)),'')+Space(1)+;
*!*					IIF(!EMPTY(qryJournal1.kood1),' TT '+Ltrim(Rtrim(qryJournal1.kood1)),'') +Chr(13)
*!*				Replace arve_lausend.lausend with lcString additive in arve_lausend
*!*			Endscan
*!*			Use in qryJournal1
*!*		Endif
*!*		if used ('v_journalid')
*!*			use in v_journalid
*!*		endif
*!*	Endwith
*!*	select vorder_report1 