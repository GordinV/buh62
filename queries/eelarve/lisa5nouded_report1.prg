Parameter cWhere
Local lnDeebet, lnKreedit
tcAllikas = '%'
tcArtikkel = '%'
tcTegev = '%'
tcObjekt = '%'
tcEelAllikas = '%'
lnDeebet = 0
lnKreedit = 0
dKpv1 = iif(!empty(fltrAruanne.kpv1), fltrAruanne.kpv1,date(year(date()),1,1))
dKpv2 = iif(!empty(fltrAruanne.kpv2), fltrAruanne.kpv2,date())
Replace fltrAruanne.kpv1 with dKpv1,;
	fltrAruanne.kpv2 with dKpv2 in fltrAruanne

With odb
		tnAsutusId1 = 0
		tnAsutusId2 = 999999999
		cAsutus = '%%'

	Create cursor KaibeAsutusAndmik_report1 (algsaldo n(12,2),deebet n(12,2),;
		kreedit n(12,2),lsaldo n(12,2), konto c(20), nimetus c(120), asutus c(120), Asutusid int)
	Index on Asutusid tag Asutusid
	Index on alltrim(str (Asutusid))+':' + alltrim(konto) tag klkonto
	Index on left (upper (asutus),40) tag asutus
	Set order to Asutusid
&& algsaldo arvestused
	dKpv2 = dKpv1
	dKpv1 = date(year(dKpv1), month(dKpv1),1)
	If used('cursorSaldod1')
		Use in cursorSaldod1
	Endif
	Wait window [Arvestan alg.saldo ..] nowait
	tnAasta = year(dKpv1)
&&Use querySubKontod in 0 alias 'kontonimetused'
	If !used ('curAasta')
		.use ('curAasta')
	Endif
	Select top 1 kuu, aasta from curAasta order by aasta DESC, kuu DESC where kinni = 'Jah' into cursor qryAasta

	If reccount ('qryAasta') > 0 and qryAasta.aasta < tnAasta 
		tnAasta = qryAasta.aasta
	else
		select curAasta
		calculate min(aasta) to tnAasta
		if empty (tnAasta)
			tnAasta = year (dKpv1)
		endif
	Endif
	Use in qryAasta

	tcKonto = '14%'
	.use('querySubKontod','kontonimetused')
	tcKonto = '15%'
	.use('querySubKontod','kontonimetused15')
	tcKonto = '16%'
	.use('querySubKontod','kontonimetused16')
	SELECT kontonimetused
	APPEND FROM DBF('kontonimetused15')
	APPEND FROM DBF('kontonimetused16')
	USE IN kontonimetused15
	USE IN kontonimetused16
	tnAasta = year(dKpv1)

	Select kontonimetused
	SCAN 
		Insert into KaibeAsutusAndmik_report1 (algsaldo, konto, nimetus, asutus, Asutusid) values ;
			(kontonimetused.algsaldo, kontonimetused.kood, kontonimetused.kontonimi, ;
			kontonimetused.nimetus, kontonimetused.Asutusid)
	Endscan
	Select KaibeAsutusAndmik_report1
	tcAsutus = '%'
	tnSaldo1 = -999999999
	tnSaldo2 = 999999999
	tnlSaldo1 = -999999999
	tnlSaldo2 = 999999999
	tnDb1 = -999999999
	tnDb2 = 999999999
	tnKr1 = -999999999
	tnKr2 = 999999999
	tcKonto = '14%'
	lError = .exec ("sp_klsaldo ",str (grekv)+","+str(month (dKpv1),2)+","+str (tnAasta,4)+",'"+alltrim(tcKonto)+"%','"+cAsutus+"'",'cursorSaldod' )
	tcKonto = '15%'
	lError = .exec ("sp_klsaldo ",str (grekv)+","+str(month (dKpv1),2)+","+str (tnAasta,4)+",'"+alltrim(tcKonto)+"%','"+cAsutus+"'",'cursorSaldod15' )
	tcKonto = '16%'
	lError = .exec ("sp_klsaldo ",str (grekv)+","+str(month (dKpv1),2)+","+str (tnAasta,4)+",'"+alltrim(tcKonto)+"%','"+cAsutus+"'",'cursorSaldod16' )
	Select cursorSaldod
	APPEND FROM DBF('cursorSaldod15')	
	Select cursorSaldod
	APPEND FROM DBF('cursorSaldod16')	
	USE IN cursorSaldod15
	USE IN cursorSaldod16
	
	DELETE FROM cursorSaldod WHERE LEFT(ALLTRIM(konto),3) NOT in ;
		('141','145','147','148','149','151','154','155','156','158','159','167','168','169')
	If dKpv1 < fltrAruanne.kpv1
		cDok = '%%'
		cSelg = '%%'
		nSumma1 = -99999999
		nSumma2 = 999999999
		cKreedit = '%%'
		cDeebet = '14%'
		tcTpD = '%'
		tcTpK = '%'

		.use('curJournal','JournalQuery1')
		cDeebet = '15%'
		.use('curJournal','JournalQuery1_15')
		cDeebet = '16%'
		.use('curJournal','JournalQuery1_16')
		SELECT JournalQuery1
		APPEND FROM DBF('JournalQuery1_15')
		APPEND FROM DBF('JournalQuery1_16')
		USE IN JournalQuery1_15
		USE IN JournalQuery1_16

		cDeebet = '%'
		cKreedit = '14%'
		.use('curJournal','JournalQuery1_')
		cKreedit = '15%'
		.use('curJournal','JournalQuery1_15')
		cKreedit = '16%'
		.use('curJournal','JournalQuery1_16')
		SELECT JournalQuery1_
		APPEND FROM DBF('JournalQuery1_15')
		APPEND FROM DBF('JournalQuery1_16')
		USE IN JournalQuery1_15
		USE IN JournalQuery1_16
		
		SELECT JournalQuery1
		APPEND FROM DBF(JournalQuery1_)
		USE IN JournalQuery1_
		Select cursorSaldod
		Scan
			Select Journalquery1
			Sum summa for alltrim(deebet) = alltrim(cursorSaldod.konto) and;
				Journalquery1.Asutusid = cursorSaldod.Asutusid  to lnDeebet
			Sum summa for alltrim(kreedit) = alltrim(cursorSaldod.konto) and;
				Journalquery1.Asutusid = cursorSaldod.Asutusid to lnKreedit

			Select KaibeAsutusAndmik_report1
			Locate for konto = cursorSaldod.konto and Asutusid = cursorSaldod.Asutusid
			If !found ()
				Select comKontodRemote
				Locate for konto = cursorSaldod.konto
				Select comAsutusRemote
				Locate for id = cursorSaldod.Asutusid
				Insert into KaibeAsutusAndmik_report1 (algsaldo, konto, nimetus, asutus, Asutusid) values ;
					(0, comKontodRemote.kood, comKontodRemote.nimetus, ;
					comAsutusRemote.nimetus, cursorSaldod.Asutusid)
			Endif
			Replace algsaldo with (cursorSaldod.deebet - cursorSaldod.kreedit)+lnDeebet-lnKreedit,;
				lsaldo with algsaldo + deebet - kreedit  in KaibeAsutusAndmik_report1
		Endscan
	Else
		Select cursorSaldod
		Scan
			Update KaibeAsutusAndmik_report1 set ;
				algsaldo = cursorSaldod.deebet - cursorSaldod.kreedit,;
				lsaldo = algsaldo + deebet - kreedit;
				where konto = cursorSaldod.konto and Asutusid = cursorSaldod.Asutusid
		Endscan
	Endif
	Use in kontonimetused
	Wait window [Arvestan kaibed ..] nowait
	Select KaibeAsutusAndmik_report1
&& �������
	dKpv1 = fltrAruanne.kpv1
	dKpv2 = fltrAruanne.kpv2
	cKreedit = '%%'
	cDok = '%%'
	cSelg = '%%'
	nSumma1 = -99999999
	nSumma2 = 999999999
	cDeebet = '14%'
	.use('curJournal','JournalQuery1')
	cDeebet = '15%'
	.use('curJournal','JournalQuery1_15')
	cDeebet = '16%'
	.use('curJournal','JournalQuery1_16')
	
	Select Journalquery1
	APPEND from DBF('JournalQuery1_15')
	APPEND from DBF('JournalQuery1_16')
	USE IN JournalQuery1_15
	USE IN JournalQuery1_16

	DELETE FROM Journalquery1 WHERE LEFT(ALLTRIM(deebet),3) NOT in ;
		('141','145','147','148','149','151','154','155','156','158','159','167','168','169')
	Scan
		Select KaibeAsutusAndmik_report1
		cIndex = alltrim(str (Journalquery1.Asutusid))+':'+alltrim(Journalquery1.deebet)
		SET ORDER to klkonto
		Seek cIndex
		If found ()
			Replace deebet with deebet + Journalquery1.summa ;
				lsaldo with algsaldo + deebet - kreedit in KaibeAsutusAndmik_report1
		Else
			Select comKontodRemote
			Locate for kood = Journalquery1.deebet
			Insert into KaibeAsutusAndmik_report1 (algsaldo, konto, nimetus, asutus, Asutusid, deebet) values ;
				(0, Journalquery1.deebet, comKontodRemote.nimetus, ;
				Journalquery1.asutus, Journalquery1.Asutusid,Journalquery1.summa)
		Endif
	Endscan
	cDeebet = '%%'
	cKreedit = '14%'
	.use('curJournal','JournalQuery1')
	cKreedit = '15%'
	.use('curJournal','JournalQuery1_15')
	cKreedit = '16%'
	.use('curJournal','JournalQuery1_16')
	Select Journalquery1
	APPEND FROM DBF('JournalQuery1_15')
	APPEND FROM DBF('JournalQuery1_16')
	USE IN JournalQuery1_15
	USE IN JournalQuery1_16
	DELETE FROM Journalquery1 WHERE LEFT(ALLTRIM(kreedit),3) NOT in ;
		('141','145','147','148','149','151','154','155','156','158','159','167','168','169')
	
	Scan
		Select KaibeAsutusAndmik_report1
		cIndex = alltrim(str (Journalquery1.Asutusid))+':'+alltrim(Journalquery1.kreedit)
		SET ORDER to klkonto
		Seek cIndex
		If found ()
			Replace kreedit with kreedit + Journalquery1.summa,;
				lsaldo with algsaldo + deebet - kreedit in KaibeAsutusAndmik_report1
		Else
			Select comKontodRemote
			Locate for kood = Journalquery1.kreedit
			Insert into KaibeAsutusAndmik_report1 (algsaldo, konto, nimetus, asutus, Asutusid, kreedit) values ;
				(0, Journalquery1.kreedit, comKontodRemote.nimetus, ;
				Journalquery1.asutus, Journalquery1.Asutusid,Journalquery1.summa)
		Endif
	Endscan
Endwith
If used('Journalquery1')
	Use in Journalquery1
Endif
If used('cursorSaldod')
	Use in cursorSaldod
Endif
Clear
Select KaibeAsutusAndmik_report1
Delete FRom KaibeAsutusAndmik_report1 WHERE empty (lsaldo) or 	LEFT(ALLTRIM(konto),3) NOT in	('141','145','147','148','149','151','154','155','156','158','159','167','168','169')
Set order to asutus
