Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
tnId = cWhere

If !Used('v_korder1')
	lError = oDb.readFromModel('raamatupidamine\sorder', 'row', 'tnId, guserid', 'v_korder1')
	lError = oDb.readFromModel('raamatupidamine\sorder', 'details', 'tnId, guserid', 'v_korder2')
Endif

Select v_korder1.Id, v_korder1.Number, v_korder1.kpv, v_korder1.nimi,  v_korder1.aadress, v_korder1.dokument, v_korder1.alus, ;
	v_Korder2.nimetus,  v_Korder2.Summa,  v_korder1.kassa As aa, v_korder1.kokku, ;
	v_Korder2.kood1,  v_Korder2.kood2, v_Korder2.kood3, v_Korder2.kood4, v_Korder2.kood5, ;
	v_Korder2.tunnus;
	FROM  v_korder1, v_Korder2 ;
	ORDER By v_Korder2.nimetus ;
	INTO Cursor sorder_report1

tnId = v_korder1.journalid

lError = oDb.readFromModel('raamatupidamine\journal', 'row', 'tnId, guserid', 'qryJournal')
lError = oDb.readFromModel('raamatupidamine\journal', 'details', 'tnId, guserid', 'qryJournal1')

Create Cursor sorder_lausend (Id Int, lausend m)
Append Blank
Select qryJournal1
Scan
TEXT TO lcString TEXTMERGE noshow
D: <<alltrim(qryJournal1.deebet)>> TP: <<alltrim(qryJournal1.lisa_d)>>  K: <<alltrim(qryJournal1.kreedit)>>  TP: <<alltrim(qryJournal1.lisa_k)>>
ENDTEXT
TEXT TO lcString TEXTMERGE NOSHOW additive
Summa  <<alltrim(Str (qryJournal1.Summa,12,2))>> Eel: <<alltrim(qryJournal1.kood5)>>
ENDTEXT
TEXT TO lcString TEXTMERGE NOSHOW additive
TT: <<alltrim(qryJournal1.kood1)>>

ENDTEXT

	Replace Id With qryJournal.Number,;
		sorder_lausend.lausend With lcString Additive In sorder_lausend
Endscan
If Used ('qryJournal')
	Use In qryJournal
Endif
If Used ('qryJournal1')
	Use In qryJournal1
Endif
Select sorder_report1
