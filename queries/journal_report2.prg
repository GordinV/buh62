Parameter tnId
If Vartype (tnId) = 'C'
	tnId = Val(tnId)
Endif
If Empty (tnId) And Used ('curJournal')
	tnId = curJournal.Id
Endif
lError = oDb.readFromModel('raamatupidamine\journal', 'row', 'tnId, guserid', 'qryjournal')
lError = oDb.readFromModel('raamatupidamine\journal', 'details', 'tnId, guserid', 'qryjournal1')

Create Cursor journal_report1 (Id Int, kpv d, asutus c(254), dok c(120) Null, ;
	selg m , deebet c(20), kreedit c(20), lisa_d c(20) Null, lisa_k c(20) Null, Summa Y,;
	kood1 c(20) Null, valuuta c(20) Default 'EUR', kuurs N(14,4) Default 1, kood2 c(20) Null,;
	kood3 c(20) Null, kood4 c(20) Null, kood5 c(20) Null, muud m Null, kasutaja c(120) Null, TUNNUS c(20) Null, Proj c(20) Null)




Select qryJournal1

Scan
	Select journal_report1
	Append Blank

	Replace kpv With qryjournal.kpv,;
		id With qryjournal.Number,;
		asutus With Rtrim(qryjournal.asutus),;
		dok With Iif(Isnull(qryjournal.dok),'',qryjournal.dok),;
		selg With qryjournal.selg,;
		deebet With qryJournal1.deebet,;
		lisa_d With qryJournal1.lisa_d,;
		lisa_k With qryJournal1.lisa_k,;
		kreedit With qryJournal1.kreedit,;
		kood1 With Iif(Isnull(qryJournal1.kood1),'',qryJournal1.kood1),;
		kood2 With Iif(Isnull(qryJournal1.kood2),'',qryJournal1.kood2),;
		kood3 With Iif(Isnull(qryJournal1.kood3),'',qryJournal1.kood3),;
		kood4 With Iif(Isnull(qryJournal1.kood4),'',qryJournal1.kood4),;
		kood5 With Iif(Isnull(qryJournal1.kood5),'',qryJournal1.kood5),;
		summa With qryJournal1.Summa,;
		TUNNUS With Iif(Isnull(qryJournal1.TUNNUS),'',qryJournal1.TUNNUS),;
		proj With Iif(Isnull(qryJournal1.Proj),'',qryJournal1.Proj),;
		muud With qryjournal.muud  In journal_report1
Endscan

Use In qryjournal
Use In qryJournal1

Select journal_report1
