Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
Local lnJaak
lnJaak = 0
tnId = cWhere

If !Used('v_avans1')
	With odb
		lError = .readFromModel('raamatupidamine\avans', 'row', 'tnId, guserid', 'v_avans1')
		lError = .readFromModel('raamatupidamine\avans', 'details', 'tnId, guserid', 'v_avans2')

	Endwith
Endif
tnId = v_avans1.journalid
lError = odb.readFromModel('raamatupidamine\journal', 'details', 'tnId, guserid', 'qryJournal1')


Select comAsutusremote
Locate For Id = v_avans1.asutusId

Select v_avans2
Sum Summa To lnSumma
Create Cursor avans_report1 (Number c(20) Default v_avans1.Number, kpv d Default v_avans1.kpv, kokku Y Default lnSumma,;
	selg m Default v_avans1.selg , isik c(254) Default comAsutusremote.nimetus,;
	nimetus c(254), muud m null, Summa Y, konto c(20) null, tunnus c(20) null, kood1 c(20) null,;
	kood2 c(20) null, kood3 c(20) null, kood5 c(20) null, jaak Y Default v_avans1.jaak,;
	lausend Int  NULL Default v_avans1.lausend, valuuta c(20) null Default 'EUR', kuurs N(14,4) Default 1)


Create Cursor laus (laus m)
Append Blank

Select qryJournal1
lcString = ''
Scan
	lcString = lcString + 'D '+Ltrim(Rtrim(qryJournal1.deebet))+ 'K '+Ltrim(Rtrim(qryJournal1.kreedit)) +' EUR '+Str(qryJournal1.Summa,12,2)+Chr(13)
Endscan
Use In qryJournal1

Replace laus With lcString In laus

Insert Into avans_report1 (nimetus, muud, Summa, konto, tunnus, kood1, kood2, kood3, kood5, valuuta, kuurs );
	SELECT nimetus, muud, Summa, konto, tunnus, kood1, kood2, kood3, kood5, 'EUR', 1 From v_avans2

Select avans_report1
If Reccount()< 1
	Append Blank
Endif
