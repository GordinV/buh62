Clear All


*gnVersia = 'MSSQL'
gnVersia = 'VFP'

Set Date To German
Set Century On

Set Safety Off

If !Used ('config')
	Use config In 0
Endif


*!*	SET STEP ON
*!*	lcstr = DateToStr(DATE())
*!*	RETURN


Create Cursor curKey (versia m)
Append Blank
Replace versia With 'RAAMA' In curKey
Create Cursor versia (admin Int Default 1)
Append Blank

gnhandleSQL = 0
lcDbf = ''


If gnVersia = 'MSSQL'
	gnhandleSQL = SQLConnect ('zursql','zinaida','159')
Else
	lcDbf = 'c:\install\buh50\dbase\buhdata5.dbc'
	If File(lcDbf)
		Open Database (lcDbf)
	Endif
	If !Dbused('buhdata5')
		Messagebox('Database file not found')
		Return .F.
	Endif

Endif

*gnhandlePG = SQLConnect ('pgzur','vlad','490710')

gnhandlePG = SQLConnect ('buhdata60','vlad','490710')


If gnVersia = 'MSSQL' And gnhandleSQL < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
If gnhandlePG < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 1
gversia = 'PG'


Local lError
=sqlexec (gnhandlePG,'begin work')

* switch off triggers

lcString = " update pg_trigger set tgenabled = false"
If sqlexec (gnhandlePG,lcString) < 0
	Set Step On
	lError = .F.
Else
	lError = update_nom()
*	lError = versia ()
	If Vartype (lError ) = 'N'
		lError = Iif( lError = 1,.T.,.F.)
	Endif

Endif

If lError = .F.
	=sqlexec (gnhandlePG,'ROLLBACK WORK')
Else
	lcString = " update pg_trigger set tgenabled = true"
	=sqlexec (gnhandlePG,lcString)
	=sqlexec (gnhandlePG,'COMMIT WORK')
*!*		Wait Window 'Grant access to views' Nowait
*!*		lError =pg_grant_views()
*!*		Wait Window 'Grant access to tables' Nowait
*!*		lError = pg_grant_tables()
Endif
=SQLDISCONNECT(gnhandlePG)
If Used('qryLog')
	Copy Memo qryLog.Log To Buh60Dblog.Log
	Use In qryLog
Endif

FUNCTION update_nom
lcString = 'select * from nomenklatuur'
IF SQLEXEC(gnHandleSQL,lcString,'tmpNom') < 0
	MESSAGEBOX('Viga')
	SET STEP ON 
	RETURN .f.
ENDIF

lcString = 'select * from nomenklatuur'
IF SQLEXEC(gnHandlePG,lcString,'qryNom') < 0
	MESSAGEBOX('Viga')
	SET STEP ON 
	RETURN .f.
ENDIF


Select qryNom
Scan
	Wait Window qryNom.kood+Str(Recno('qryNom'))+'/'+Str(Reccount('qryNom')) Nowait
	Select tmpNom
	Locate For tmpNom.Id = qryNom.Id
	If Found() And Ltrim(Rtrim(qryNom.nimetus)) <> Ltrim(Rtrim(tmpNom.nimetus))
* parandame
		lcString = "update nomenklatuur set nimetus = '"+ Ltrim(Rtrim(tmpNom.nimetus)) +"' where id = "+Str(qryNom.Id)
		If SQLEXEC(gnHandlePG,lcString) < 0
			Messagebox('Viga')
			_Cliptext = lcString
			Set Step On
			Exit
			Return .F.
		Endif

	Endif

Endscan
RETURN 1

Endfunc


Function create_cursors
	Create Cursor mssqlUserid (Id Int, rekvId Int, kasutaja c(40), ametnik c(254), ;
		kasutaja_ Int, peakasutaja_ Int, admin_ Int, muud m Null, Password c(10))

	Create Cursor qryMssqlrekv(  Id Int,  parentid Int , regkood c(20),  nimetus c(254),  kbmkood c(20);
		, aadress m,  haldus c(254),  tel c(120),  faks c(120),  email c(120) ,  juht c(120), raama c(120),;
		muud m Null,  recalc Int )

	Create Cursor qryasutus( Id Int,rekvId Int,regkood c(20),nimetus c(254), omvorm c(20),;
		aadress m, kontakt m,  tel c(20),  faks c(60), email c(60),  muud m Null,  tp c(20))

	If !Used('mssqllibrary')
		Create Cursor mssqllibrary(Id Int,rekvId Int,kood c(20),nimetus c(254),Library c(20),muud m Null  Default Iif(Isnull(muud),'',muud),tun1 Int,;
			tun2 Int, tun3 Int,  tun4 Int,  tun5 Int)
	Endif

	Create Cursor mssqlpalkAsutus(Id Int,rekvId Int,osakondid Int, ametId Int, kogus N(12,2), vaba N(12,2),;
		palgamaar Int, muud m Null, tunnusid Int)

	Create Cursor mssqlpvkaart(Id Int,  parentid Int,  vastisikid Int,  soetmaks N(12,4),  ;
		soetkpv d,  kulum N(12,4),  algkulum N(12,4),  gruppid Int,  konto c(20),  tunnus Int, ;
		mahakantud d,  otsus m,  muud m Null)

	Create Cursor mssqlpvoper(Id Int,  parentid Int,  nomid Int,  doklausid Int,  lausendid Int ,;
		journalid Int,  journal1id Int,  liik Int,  kpv c(10),  Summa N(12,4))

	Create Cursor mssqlpalk_lib(Id Int,  parentid Int,  liik Int,  tund Int,  maks Int,  palgafond Int,;
		asutusest Int,  lausendid Int,  algoritm c(10),  muud m Null,  Round N(12,4),  sots Int, konto c(20))

	Create Cursor mssqltooleping(Id Int, parentid Int, osakondid Int,ametId Int, algab d, lopp d,;
		toopaev Int,palk N(12,4) ,  palgamaar Int, pohikoht Int,  koormus Int,ametnik Int,tasuliik Int,;
		pank Int,  aa c(16),  muud m Null, rekvId Int)

	Create Cursor mssqlpalkkaart(  Id Int,  parentid Int ,  lepingid Int ,  libid Int,  Summa N(12,4),;
		percent_ Int,  tulumaks Int,  tulumaar Int,  Status Int, muud m Null, alimentid Int,  tunnusid Int)

	Create Cursor mssqlpalktaabel(Id Int,  toolepingid Int,  kokku Int,  too Int,  paev Int,;
		ohtu Int,  oo Int,  tahtpaev Int,  puhapaev Int,  kuu Int,  aasta Int,  muud m Null)

	Create Cursor mssqlpuudumine(Id Int,  lepingid Int,  kpv1 c(10),  kpv2 c(10),  paevad Int,  Summa N(12,4),;
		tunnus Int,  tyyp Int,  muud m Null,  libid Int)

	Create Cursor mssqlpalkoper(Id Int,  rekvId Int,  libid Int,  lepingid Int,  kpv c(10),  Summa N(12,4),;
		doklausid Int)

	Create Cursor mssqlpalkjaak(Id Int, lepingid Int, kuu i, aasta i, jaak N(12,4), arvestatud N(12,4), kinni N(12,4),;
		tki N(12,4), tka N(12,4), pm N(12,4), tulumaks N(12,4), sotsmaks N(12,4), muud N(12,4), g31 N(12,4)  ;
		DEFAULT Iif(aasta < 2006 And tulumaks >0,1700, 2000 ))

	Create Cursor mssqlnom (Id Int,  rekvId Int, doklausid Int, dok c(20),kood c(20) , ;
		nimetus c(254),  uhik c(20),  hind N(12,4), muud m Null,  ulehind N(12,4),kogus N(12,3),  formula m)

	Create Cursor mssqlklassif (Id Int,  nomid Int, palklibid Int, libid Int , tyyp Int, tunnusid Int,;
		kood1 c(20),  kood2 c(20), kood3 c(20), kood4 c(20), kood5 c(20), konto c(20))

	Create Cursor mssqlautod (Id Int,omanikid Int,Mark c(254),regnum c(12),idkood c(11),;
		tuubikood c(40),vinkood c(40), mootor c(40), aasta Int ,;
		voimsus Int,  kindlustus c(40), saadetud c(40), Status Int,  muud m )

	Create Cursor mssqlautod (Id Int,omanikid Int,Mark c(254),regnum c(12),idkood c(11),;
		tuubikood c(40),vinkood c(40), mootor c(40), aasta Int ,;
		voimsus Int,  kindlustus c(40), saadetud c(40), Status Int,  muud m )

	Create Cursor mssqlarv (Id Int,  rekvId Int, Userid Int, journalid Int, doklausid Int,  liik Int, operid Int Not Null Default 0,;
		number c(20) Not Null Default Space(1),  kpv d Not Null Default Date(), asutusid Int Not Null Default 0,;
		arvid Int Not Null Default 0, lisa c(120) Not Null Default Space(1), tahtaeg d, kbmta N(12,4) Not Null Default 0,;
		kbm N(12,4) Not Null Default 0,  Summa N(12,4) Not Null Default 0, tasud d,  tasudok c(254), muud m, jaak N(12,4) Not Null Default 0,;
		objektid Int Not Null Default 0)


	Create Cursor mssqlarv1 (Id Int,  parentid Int Not Null, nomid Int Not Null, kogus N(18,3) Not Null Default 0,;
		hind N(12,4) Not Null Default 0, soodus Int Not Null Default 0, kbm N(12,4) Not Null Default 0,;
		maha Int Not Null Default 0,  Summa N(12,4) Not Null Default 0,  muud m,;
		kood1 c(20) Not Null Default Space(20), kood2 c(20) Not Null Default Space(20),;
		kood3 c(20) Not Null Default Space(20), kood4 c(20) Not Null Default Space(20),;
		kood5 c(20) Not Null Default Space(20), konto c(20) Not Null Default Space(20),;
		tp c(20) Not Null Default Space(20),  kbmta N(12,4) Not Null Default 0,;
		isikid Int Not Null Default 0, tunnus c(20) Not Null Default Space(20),;
		proj c(20) Not Null Default Space(20))


	Create Cursor mssqlarv3 (Id Int, arvid Int Not Null, arv1id Int Not Null, autoid Int Not Null, isikid Int Not Null, ;
		lastupd d)


	CREATE CURSOR mssqljournal (id int, rekvid id, userid int, dokid int, kpd d, asutusId int, selg m, dok c(120), muud m null )


	create CURSOR mssqljournal1 (id int, parentid int, lausendid int, summa n(12,2),;
  		muud m null, deebet c(20), kreedit c(20), lisa_d c(20), lisa_k c(20), valuuta c(3),;
  		kuurs n(12,6), valsumma n(12,2), kood1 c(20), kood2 c(20), kood3 c(20), kood4 c(20),;
  		kood5 c(20), tunnus c(20), proj c(20))


	CREATE CURSOR mssqlJournalid (rekvid int, journalid int, number int, aasta int)



Endfunc


Function mssql_to_cursor

	Wait Window 'Selection record into cursors ...' Timeout 3
	Wait Window 'Selection record into cursors: userid ...' Nowait

	If sqlexec(gnhandleSQL,'select * from userid','qryUserid') < 0 Or !Used('qryUserid')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: rekv ...' Nowait
	If sqlexec(gnhandleSQL,'select * from rekv','qryRekv') < 0 Or !Used('qryRekv')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: library ...' Nowait
	If sqlexec(gnhandleSQL,'select * from library','tmplibrary') < 1 Or !Used('tmplibrary')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: palk_asutus ...' Nowait
	If sqlexec(gnhandleSQL,'select * from palk_asutus','tmppalkasutus') < 0 Or !Used('tmppalkasutus')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: pv_kaart ...' Nowait
	If sqlexec(gnhandleSQL,'select * from pv_kaart','tmppvkaart')< 0 Or !Used('tmppvkaart')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: pv_oper ...' Nowait

	If sqlexec(gnhandleSQL,'select * from pv_oper','tmppvoper')< 0 Or !Used('tmppvoper')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: palk_lib ...' Nowait

	If sqlexec(gnhandleSQL,'select * from palk_lib','tmppalklib') < 1 Or !Used('tmppalklib')
		Set Step On
		Return .F.
	Endif
	If sqlexec(gnhandleSQL,'select * from tooleping WHERE YEAR(lopp) = 1900  or YEAR(LOPP) > 2006 ','tmptooleping') < 0 Or !Used('tmpTooleping')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: palk_kaart ...' Nowait

	If sqlexec(gnhandleSQL,'select * from palk_kaart','tmppalkkaart') < 0 Or !Used('tmppalkkaart')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: palk_taabel1 ...' Nowait

	If sqlexec(gnhandleSQL,'select * from palk_taabel1','tmppalktaabel') < 0 Or !Used('tmppalktaabel')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: palk_oper ...' Nowait
	If sqlexec(gnhandleSQL,'select * from palk_oper where YEAR(kpv) = 2006','tmppalkoper') < 0 Or !Used('tmppalkoper')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: palk_jaak ...' Nowait
	If sqlexec(gnhandleSQL,'select * from palk_jaak where aasta = 2006 or (kuu = 12 and aasta = 2005) ','tmppalkjaak') < 0 Or !Used('tmppalkoper')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: nomenklatuur ...' Nowait
	If sqlexec(gnhandleSQL,'select * from nomenklatuur','tmpNom') < 1 Or !Used('tmpNom')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: tmp_klassif ...' Nowait
	If sqlexec(gnhandleSQL,'select * from tmp_klassif','tmpKl') < 1 Or !Used('tmpKl')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: autod ...' Nowait

	If sqlexec(gnhandleSQL,'select * from autod','tmpautod') < 1 Or !Used('tmpautod')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: asutus ...' Nowait

	If sqlexec(gnhandleSQL,'select * from asutus','tmpasutus') < 1 Or !Used('tmpasutus')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: arv ...' Nowait

	If sqlexec(gnhandleSQL,'select * from arv','tmparv') < 1 Or !Used('tmparv')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: arv1 ...' Nowait

	If sqlexec(gnhandleSQL,'select * from arv1','tmparv1') < 1 Or !Used('tmparv1')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: arv1 ...' Nowait

	If sqlexec(gnhandleSQL,'select * from arv3','tmparv3') < 1 Or !Used('tmparv3')
		Set Step On
		Return .F.
	Endif

	Wait Window 'Selection record into cursors: saldo ...' Nowait

	If sqlexec(gnhandleSQL,"select parentid, algsaldo from kontoinf ",'tmpkontoinf') < 1 Or !Used('tmpkontoinf')
		Set Step On
		Return .F.
	Endif

	If sqlexec(gnhandleSQL,"select kontoid, asutusId ,algsaldo from subkonto ",'tmpsubkonto') < 1 Or !Used('tmpSubkonto')
		Set Step On
		Return .F.
	Endif

	If sqlexec(gnhandleSQL,"select deebet, sum(summa) as summa from curJournal where datepart(kpv,'YEAR') < 2006 group by deebet ",'tmpDB') < 1 Or !Used('tmpDB')
		Set Step On
		Return .F.
	Endif
	If sqlexec(gnhandleSQL,"select kreedit, sum(summa) as summa from curJournal where DATEPART(kpv,'YEAR') < 2006 group by kreedit ",'tmpKR') < 1 Or !Used('tmpKR')
		Set Step On
		Return .F.
	Endif

	If sqlexec(gnhandleSQL,"select asutusId,deebet, sum(summa) as summa from curJournal where datepart(kpv,'YEAR') < 2006 group by asutusId, deebet ",'tmpADB') < 1 Or !Used('tmpADB')
		Set Step On
		Return .F.
	Endif
	If sqlexec(gnhandleSQL,"select asutusId, kreedit, sum(summa) as summa from curJournal where datepart(kpv,'YEAR') < 2006 group by asutusId, kreedit ",'tmpAKR') < 1 Or !Used('tmpAKR')
		Set Step On
		Return .F.
	Endif

	If sqlexec(gnhandleSQL,"select curJournal.* , journal.muud from curJournal inner join journal on journal.id = curJournal.id where datepart(curjournal.kpv,'YEAR') = 2006  ",'tmpCurJournal') < 1 Or !Used('tmpAKR')
		Set Step On
		Return .F.
	Endif


*!*		Wait Window 'Selection record into cursors: saldo1 ...' Nowait

*!*		If sqlexec(gnhandleSQL,"select * from saldo1 WHERE period = '200601'",'tmpsaldo1') < 1 Or !Used('tmpsaldo1')
*!*			Set Step On
*!*			Return .F.
*!*		Endif

	Wait Window 'Selection record into cursors: done' Timeout 3


Endfunc

Function vfp_to_cursor

	Wait Window 'Selection record into cursors ...' Timeout 3
	Wait Window 'Selection record into cursors: userid ...' Nowait

	Select * From Userid Into Cursor qryUserid

	Wait Window 'Selection record into cursors: rekv ...' Nowait
	Select * From rekv Into Cursor qryRekv

	Wait Window 'Selection record into cursors: library ...' Nowait
	Select * From Library Into Cursor tmplibrary

	Wait Window 'Selection record into cursors: palk_asutus ...' Nowait
	Select * From palk_asutus Into Cursor tmppalkasutus

	Wait Window 'Selection record into cursors: pv_kaart ...' Nowait
	Select * From pv_kaart Into Cursor tmppvkaart

	Wait Window 'Selection record into cursors: pv_oper ...' Nowait

	Select * From pv_oper Into Cursor tmppvoper

	Wait Window 'Selection record into cursors: palk_lib ...' Nowait

	Select * From palk_lib Into Cursor tmppalklib

	Select * From tooleping Where Empty(lopp) Or Year(lopp) > 2006 Into Cursor tmptooleping

	Wait Window 'Selection record into cursors: palk_kaart ...' Nowait

	Select * From palk_kaart Into Cursor tmppalkkaart

	Wait Window 'Selection record into cursors: palk_taabel1 ...' Nowait

	Select * From palk_taabel1 Into Cursor tmppalktaabel

	Wait Window 'Selection record into cursors: palk_oper ...' Nowait
	Select * From palk_oper Where Year(kpv) = 2006 Into Cursor tmppalkoper

	Wait Window 'Selection record into cursors: palk_jaak ...' Nowait
	Select * From palk_jaak Where aasta = 2006 Or (kuu = 12 And aasta = 2005)  Into Cursor tmppalkjaak

	Wait Window 'Selection record into cursors: nomenklatuur ...' Nowait
	Select * From nomenklatuur Into Cursor tmpNom

*!*		WAIT WINDOW 'Selection record into cursors: tmp_klassif ...' nowait
*!*		select * from tmp_klassif into CURSOR tmpKl

	Wait Window 'Selection record into cursors: autod ...' Nowait

	Select * From autod Into Cursor tmpautod

	Wait Window 'Selection record into cursors: asutus ...' Nowait

	Select * From asutus Into Cursor tmpasutus

	Wait Window 'Selection record into cursors: arv ...' Nowait

	Select * From arv Into Cursor tmparv

	Wait Window 'Selection record into cursors: arv1 ...' Nowait

	Select * From arv1 Into Cursor tmparv1

	Wait Window 'Selection record into cursors: arv3 ...' Nowait

	Select * From arv3 Into Cursor tmparv3


	Wait Window 'Selection record into cursors: saldo ...' Nowait

	Select parentid, algsaldo From kontoinf Into Cursor tmpkontoinf

	Select kontoid, asutusid ,algsaldo From subkonto Into Cursor tmpsubkonto

	Select deebet, Sum(Summa) As Summa From curJournal_ ;
		where kpv < Date(2006,01,01) Group By deebet Into Cursor tmpDB

	Select kreedit, Sum(Summa) As Summa From curJournal_ ;
		where kpv < Date(2006,01,01) Group By kreedit Into Cursor tmpKR

	Select asutusid,deebet, Sum(Summa) As Summa From curJournal_ ;
		where kpv < Date(2006,01,01) Group By asutusid, deebet Into Cursor tmpADB

	Select asutusid, kreedit, Sum(Summa) As Summa From curJournal_ ;
		where kpv < Date(2006,01,01) Group By asutusid, kreedit Into Cursor tmpAKR

	Select curJournal_.*, journal.muud From curJournal_  inner join journal on journal.id = curJournal_.id;
		where curJournal_.kpv >= Date(2006,01,01)  Into Cursor tmpCurJournal


	Wait Window 'Selection record into cursors: done' Timeout 3


Endfunc



Function versia

	=create_cursors()
	If gnVersia = 'MSSQL'
		lnResult = mssql_to_cursor()
	Else
		lnResult = vfp_to_cursor()
	Endif

	Select mssqlUserid
	Append From Dbf('qryUserid')
	Use In qryUserid

	Select qryMssqlrekv
	Append From Dbf('qryRekv')
	Use In qryRekv


	Select qryasutus

	Append From Dbf('tmpAsutus')
	Use In ('tmpAsutus')


	Wait Window 'deleting records from pg_table: library ...' Nowait

	If sqlexec(gnhandlePG,'delete from library') < 1
		Set Step On
		Return .F.
	Else
		Wait Window 'deleting records from pg_table: done' Nowait
	Endif


	Select mssqllibrary
	Append From Dbf('tmplibrary')

	Select mssqllibrary
	Scan
&& kontrol
		Wait Window 'library: '+Ltrim(Rtrim(mssqllibrary.nimetus)) Nowait
		lcString = "select id from library where id = "+Str(mssqllibrary.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryLib')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryLib') < 1
			lcString = " insert into library (id,rekvid,kood,nimetus,library,muud) values ("+;
				STR(mssqllibrary.Id)+","+Str(mssqllibrary.rekvId)+",'"+Ltrim(Rtrim(mssqllibrary.kood))+"','"+;
				LTRIM(Rtrim(mssqllibrary.nimetus))+"','"+Ltrim(Rtrim(mssqllibrary.Library))+"','"+Iif(Isnull(mssqllibrary.muud),'',mssqllibrary.muud)+"')"

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan

* 2. kontrol syst user

*SET STEP ON
&& import asutused
	lError = 1
	lError = kasutajad_import()
	If lError > 0
		lError=rekv_import()
	Endif
	If lError > 0
		lError=userid_import()
	Endif
*!*	*SET STEP ON

	If lError > 0
		lError = nom_import()
	Endif
*SET STEP ON
*!*		If lError > 0
*!*			lError = palkamet_import()
*!*		Endif
*SET STEP ON
*!*		If lError > 0
*!*			lError = palkosakond_import()
*!*		Endif
*SET STEP ON

	If lError > 0
		lError=palklib_import()
	Endif
*SET STEP ON

	If lError > 0
		lError=asutus_import()
	Endif
*SET STEP ON
	If lError > 0
		lError=pv_import()
	Endif
*SET STEP ON
	If lError > 0
		lError=palk_import()
	Endif
*SET STEP ON
	If lError > 0
		lError = palk_asutus_import()
	Endif
*SET STEP ON

	If lError > 0
		lError = arv_import()
	Endif

	If lError > 0
		lError = journal_import()
	Endif

	If lError > 0
		lError = saldo_import()
	Endif



	If lError > 0
		lError = set_serials()
	Endif
*!*		If lError > 0
*!*			lError=kontoplaan_import()
*!*		Endif
*!*		If lError > 0
*!*			lError = rugodiv_import()
*!*		Endif


	Return lError
ENDFUNC


FUNCTION journal_import

	SELECT tmpCurjournal
	SCAN

&& kontrol
		Wait Window 'journal: '+Str(Recno('tmpcurJournal'))+'/' + Str(Reccount('tmpcurJournal'))  Nowait
		lcString = "select id from journal where id = "+Str(tmpcurJournal.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryPa')
		If lError < 1
			lnResult = lError
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif

		If Reccount('qryPa') < 1
			lcString = " insert into journal (id, userid, rekvid, kpv , asutusId , selg , dok , muud) values ("+;
				STR(tmpcurJournal.Id)+" ,1,"+Str(tmpcurJournal.rekvId)+ ","+;
				DateToStr(tmpcurJournal.kpv)+" , "+Str(tmpcurJournal.asutusId)+" ,'"+;
				LTRIM(RTRIM(tmpcurJournal.selg))+"','"+ tmpcurJournal.dok + "','" +;
				IIF(ISNULL(tmpcurJournal.muud),SPACE(1),LTRIM(RTRIM(tmpcurJournal.muud)) )+ "')"

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			ENDIF			
		Endif



			lcString = " insert into journal1 (parentid , summa , deebet,"+;
				 " kreedit ) values ("+;
				STR(tmpcurJournal.Id)+" ,"+Str(tmpcurJournal.summa,12,2)+ ",'"+LTRIM(rtrim(tmpcurJournal.deebet))+" ', '"+;
				LTRIM(RTRIM(tmpcurJournal.kreedit))+"')"
				
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			ENDIF			

			lcString = " insert into journalid (rekvid , journalid , number , aasta ) values ("+;
				STR(tmpcurJournal.rekvId)+" ,"+Str(tmpcurJournal.id)+ ","+str(tmpcurJournal.number)+","+;
				str(tmpcurJournal.aasta)+")"
				
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			ENDIF			

		
	ENDSCAN
	RETURN lError
ENDFUNC




Function saldo_import
	Wait Window 'Arvestan algsaldo ...' Nowait
	Select * From DBF('tmplibrary') Where Library = 'KONTOD' Into Cursor tmpKontod
	Select tmpKontod
	Scan
		Wait Window 'Arvestan algsaldo: ' + tmpKontod.kood Nowait
		Select tmpkontoinf
		Locate For parentid = tmpKontod.Id
		If !Found()
			lnAlgsaldo = 0
		Else
			lnAlgsaldo = tmpkontoinf.algsaldo
		Endif

		Select tmpDB
		Locate For Alltrim(deebet) = Alltrim(tmpKontod.kood)
		If Found()
			lnDb = tmpDB.Summa
		Else
			lnDb = 0
		Endif

		Select tmpKR
		Locate For Alltrim(kreedit) = Alltrim(tmpKontod.kood)
		If Found()
			lnKR = tmpKR.Summa
		Else
			lnKR = 0
		Endif

		If (lnAlgsaldo + lnDb - lnKR ) <> 0
			lcString = "insert into kontoinf (rekvid, parentId, algsaldo, aasta) values (1,"+;
				STR(tmpKontod.Id)+","+ Str( (lnAlgsaldo + lnDb - lnKR ),12,2)+",2006)"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif

		Endif
		Wait Window 'Arvestan algsaldo: ' + tmpKontod.kood = Str( (lnAlgsaldo + lnDb - lnKR ),12,2) Nowait

		Select tmpsubkonto
		Scan For kontoid = tmpKontod.Id
			lnAlgsaldo = tmpsubkonto.algsaldo

			Select tmpADB
			Locate For Alltrim(tmpADB.deebet) = Alltrim(tmpKontod.kood) And tmpADB.asutusid = tmpsubkonto.asutusid
			If Found()
				lnDb = tmpADB.Summa
			Else
				lnDb = 0
			Endif

			Select tmpAKR
			Locate For Alltrim(kreedit) = Alltrim(tmpKontod.kood) And tmpAKR.asutusid = tmpsubkonto.asutusid
			If Found()
				lnKR = tmpAKR.Summa
			Else
				lnKR = 0
			Endif

			If (lnAlgsaldo + lnDb - lnKR ) <> 0
				lcString = "insert into subkonto (rekvid, kontoId, asutusId, algsaldo, aasta) values (1,"+;
					STR(tmpKontod.Id)+","+ Str(tmpsubkonto.asutusid)+"," + Str( (lnAlgsaldo + lnDb - lnKR ),12,2)+",2006)"
				lError = sqlexec(gnhandlePG, lcString)
				If lError < 1
					lnResult = lError
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif

			Endif

		Endscan


	Endscan

	RETURN lerror

Endfunc




Function arv_import
	Local lnResult
	lnResult = 1

	Select mssqlarv
	Scan For mssqlarv.kpv >= Date(2006,01,01)
&& kontrol
		Wait Window 'arv: '+Str(Recno('mssqlarv'))+'/' + Str(Reccount('mssqlarv'))  Nowait
		lcString = "select id from arv where id = "+Str(mssqlarv.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryPa')
		If lError < 1
			lnResult = lError
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif

		If Reccount('qryPa') < 1
			lcString = " insert into arv (id ,  rekvid , userid , journalid, doklausid,  liik, operid ,number,  kpv , asutusid ,arvid , lisa c(120), tahtaeg, kbmta , kbm ,  summa, tasud ,  tasudok , muud , jaak , objektid) values ("+;
				STR(mssqlarv.Id)+" ,"+Str(mssqlarv.rekvId)+ ","+Str(mssqlarv.Userid)+" , "+;
				STR(mssqlarv.journalid)+" ,"+Str(mssqlarv.doklausid)+" , "+Str(mssqlarv.liik)+" ,"+;
				STR(mssqlarv.operid)+" ,'"+ mssqlarv.Number + "'," + DateToStr(mssqlarv.kpv) + "," +;
				STR(mssqlarv.asutusid)+"," + Str(mssqlarv.arvid)+",'"+Ltrim(Rtrim(mssqlarv.lisa))+"',"+;
				DateToStr(mssqlarv.tahtaeg)+","+Str(mssqlarv.kbmta,12,2)+"," + Str(mssqlarv.kbm,12,2)+","+;
				STR(mssqlarv.Summa,12,2)+","+DateToStr(mssqlarv.tasud)+",'"+Ltrim(Rtrim(mssqlarv.tasudok))+"','"+;
				IIF(Isnull(mssqlarv.muud),'',Ltrim(Rtrim(mssqlarv.muud)))+"',"+Str(mssqlarv.jaak,12,2)+;
				STR(mssqlarv.objektid)+")"
			Str(mssqlpalkAsutus.tunnusid)+")"

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif

		Select mssqlarv1
		Scan For mssqlarv1.parentid = mssqlarv.Id
			lcString = "select id from arv1 where id = "+Str(mssqlarv1.Id)
			lError = sqlexec(gnhandlePG, lcString,'qryPa')
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif

			lcString = " insert into arv1 (id,  parentid, nomid, kogus,	hind, soodus, kbm,maha, summa,  muud,;
	  			kood1, kood2,kood3,kood4,kood5, konto,tp, kbmta, isikid, tunnus, proj, values ("+;
				STR(mssqlarv1.Id)+" ,"+Str(mssqlarv1.parentid)+ ","+Str(mssqlarv1.nomid)+" , "+;
				STR(mssqlarv1.kogus,12,4)+" ,"+Str(mssqlarv1.hind,12,2)+" , "+Str(mssqlarv1.soodus)+" ,"+;
				STR(mssqlarv1.kbm,12,2)+" ,"+ Str(mssqlarv1.maha) + "," + Str(mssqlarv1.Summa,12,2) + ",'" +;
				IIF(Isnull(mssqlarv1.muud),'',mssqlarv1.muud)+"','" + Ltrim(Rtrim(mssqlarv1.kood1))+"','"+;
				LTRIM(Rtrim(mssqlarv1.kood2))+"','"+Ltrim(Rtrim(mssqlarv1.kood3))+"','"+;
				LTRIM(Rtrim(mssqlarv1.kood4))+"','"+Ltrim(Rtrim(mssqlarv1.kood5))+"','"+;
				LTRIM(Rtrim(mssqlarv1.konto))+"','"+Ltrim(Rtrim(mssqlarv1.tp))+"',"+;
				STR(mssqlarv1.kbmta,12,2)+","+Str(mssqlarv1.isikid)+",'"+mssqlarv1.tunnus+"','"+mssqlarv1.Proj+"')"



			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				lnResult = lError
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif


		Endscan
*Scan For mssqlarv1.parentid = mssqlarv.Id
		Select mssqlarv3
		Scan For mssqlarv3.arvid = mssqlarv.Id
			Select mssqlarv3
			Scan For mssqlarv1.parentid = mssqlarv.Id
				lcString = "select id from arv1 where id = "+Str(mssqlarv1.Id)
				lError = sqlexec(gnhandlePG, lcString,'qryPa')
				If lError < 1
					lnResult = lError
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif

				lcString =  "insert into arv3 (id, arvid, arv1id, autoid, isikid) values ("+;
					STR(mssqlarv3.Id)+","+Str(mssqlarv3.arvid)+","+Str(mssqlarv3.arv1id)+","+;
					STR(mssqlarv3.autoid)+","+Str(mssqlarv3.isikid)+")"


				lError = sqlexec(gnhandlePG, lcString)
				If lError < 1
					lnResult = lError
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif



			Endscan
*Scan For mssqlarv1.parentid = mssqlarv.Id


		Endscan
*Scan For mssqlarv3.arvid = mssqlarv.Id
	Endscan



	Return lnResult


Function palk_asutus_import


	If sqlexec(gnhandlePG,'delete from palk_asutus') < 0
		Set Step On
		Return .F.
	Endif


	Select mssqlpalkAsutus
	Append From Dbf('tmppalkasutus')
	Use In tmppalkasutus

	Select mssqlpalkAsutus
	Scan
&& kontrol
		Wait Window 'palkasutus: '+Str(Recno('mssqlpalkAsutus'))+'/' + Str(Reccount('mssqlpalkAsutus'))  Nowait
		lcString = "select id from palk_asutus where id = "+Str(mssqlpalkAsutus.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryPa')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPa') < 1
			lcString = " insert into palk_asutus (Id ,rekvId ,osakondid , ametId , kogus , vaba , palgamaar, tunnusid) values ("+;
				STR(mssqlpalkAsutus.Id)+" ,"+Str(mssqlpalkAsutus.rekvId)+ ","+Str(mssqlpalkAsutus.osakondid)+" , "+;
				STR(mssqlpalkAsutus.ametId)+" ,"+Str(mssqlpalkAsutus.kogus,12,2)+" , "+Str(mssqlpalkAsutus.vaba,12,2)+" ,"+;
				STR(mssqlpalkAsutus.palgamaar)+" ,"+Str(mssqlpalkAsutus.tunnusid)+")"

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc


Function set_serials
	Wait Window 'setting seq. value' Nowait
	lcString = " select * from pg_tables where tableowner = 'vlad' and left (tablename::varchar,2) <> 'pg' AND SCHEMANAME='public'"
	lError = sqlexec(gnhandlePG, lcString,'qryTbl')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Exit
	Endif
	Select qryTbl
	Scan For Upper(qryTbl.tablename) <> Upper('lncount') ;
			AND Upper(qryTbl.tablename) <> Upper('lcdb') ;
			AND Upper(qryTbl.tablename) <> Upper('lnarvjaak ') ;
			AND Upper(qryTbl.tablename) <> Upper('tmp_vanemtasu4 ') ;
			AND Upper(qryTbl.tablename) <> Upper('v_vanemsaldo ') ;
			AND Upper(qryTbl.tablename) <> Upper('tmp_algsaldokoopia') ;
			AND Left(Upper(qryTbl.tablename),3) <> 'TMP'


		lcString = "select id from "+Ltrim(Rtrim(qryTbl.tablename)) +" order by id desc limit 1"
		lError = sqlexec(gnhandlePG, lcString,'qryTblId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryTblId') > 0 And qryTblId.Id > 0
			lcString = " SELECT SETVAL('"+Ltrim(Rtrim(qryTbl.tablename))+"_id_seq',"+Str(qryTblId.Id)+")"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif

	Endscan
	Return lError
Endfunc


Function pv_import

	Select * From mssqllibrary Where Library = 'PVGRUPP' Into Cursor mssqlgrupplib

	If sqlexec(gnhandlePG,'delete from pv_kaart')< 0
		Set Step On
		Return .F.
	Endif




	Set Step On

	Select mssqlpvkaart

	Append From Dbf('tmppvkaart')
	Use In tmppvkaart



	If sqlexec(gnhandlePG,'delete from pv_oper')< 0
		Set Step On
		Return .F.
	Endif


	Select mssqlpvoper
	Append From Dbf('tmppvoper')
	Use In tmppvoper

	Select mssqlpvkaart
	Scan
&& kontrol
		Wait Window 'mssqlpvkaart:'+Str(Recno('mssqlpvkaart'))+'/'+Str(Reccount('mssqlpvkaart')) Nowait
		lcString = "select id from pv_kaart where id = "+Str(mssqlpvkaart.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryPvK')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPvK') < 1
			lcString = " insert into pv_kaart (Id,  parentid,  vastisikid,  soetmaks,soetkpv,  kulum ,  algkulum ,"+;
				" gruppid,  konto,  tunnus, mahakantud,  otsus ,  muud ) values ("+;
				STR(mssqlpvkaart.Id)+","+  Str(mssqlpvkaart.parentid)+","+  Str(mssqlpvkaart.vastisikid)+","+;
				STR(mssqlpvkaart.soetmaks,14,2)+"," + DateToStr(mssqlpvkaart.soetkpv) + ","+;
				STR(mssqlpvkaart.kulum,14,2)+" ,"+  Str(mssqlpvkaart.algkulum,14,2)+" ,"+;
				STR(mssqlpvkaart.gruppid)+",'"+  mssqlpvkaart.konto+"',"+ Str(mssqlpvkaart.tunnus)+","+;
				IIF(Left(Dtoc(mssqlpvkaart.mahakantud,1),4) = '1900' Or Left(Dtoc(mssqlpvkaart.mahakantud,1),4) = 'NULL',;
				"NULL", DateToStr(mssqlpvkaart.mahakantud))+",'"+mssqlpvkaart.otsus +"','"+  Iif(Isnull(mssqlpvkaart.muud),' ',mssqlpvkaart.muud)+"')"

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan


	Select mssqlpvoper
	Scan For !Isnull(mssqlpvoper.kpv)
&& kontrol
		Wait Window 'mssqlpvoper:'+Str(Recno('mssqlpvoper'))+'/'+Str(Reccount('mssqlpvoper')) Nowait
		lcString = "select id from pv_oper where id = "+Str(mssqlpvoper.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryPvO')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPvO') < 1
			lcString = " insert into pv_oper (id,  parentid,  nomid,  doklausid, liik,  kpv,  summa) values ("+;
				STR(mssqlpvoper.Id)+","+  Str(mssqlpvoper.parentid)+","+  Str(mssqlpvoper.nomid)+","+;
				STR(mssqlpvoper.doklausid)+","+ Str(mssqlpvoper.liik)+"," +DateToStr(mssqlpvoper.kpv)+ ","+;
				STR( mssqlpvoper.Summa,14,2)+")"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan



	Return lError
Endfunc



Function palklib_import

	If sqlexec(gnhandlePG,'delete from palk_lib') < 1
		Set Step On
		Return .F.
	Endif



	Select mssqlpalk_lib
	Append From Dbf('tmppalklib')
	Use In tmppalklib



	Select mssqlpalk_lib
	Scan
&& kontrol
		Wait Window 'palk_lib: '+Str(Recno('mssqlpalk_lib'))+'/'+Str(Reccount('mssqlpalk_lib')) Nowait
		lcString = "select id from palk_lib where id = "+Str(mssqlpalk_lib.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryPLib')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryPLib') < 1
			lcString = " insert into palk_lib (id,  parentid ,  liik ,  tund ,  maks,   palgafond,"+;
				" asutusest, algoritm ,  round ,  sots , konto ) values ("+;
				STR(mssqlpalk_lib.Id)+","+  Str(mssqlpalk_lib.parentid)+","+Str(mssqlpalk_lib.liik)+","+;
				STR(mssqlpalk_lib.tund)+","+  Str(mssqlpalk_lib.maks)+","+  Str(mssqlpalk_lib.palgafond)+","+;
				STR(mssqlpalk_lib.asutusest)+",'"+mssqlpalk_lib.algoritm +"',"+Str(mssqlpalk_lib.Round,12,4)+","+;
				STR(mssqlpalk_lib.sots)+" ,'"+mssqlpalk_lib.konto+"')"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan

	Return lError
Endfunc


Function palk_import


	If sqlexec(gnhandlePG,'delete from tooleping') < 0
		Set Step On
		Return .F.
	Endif


	Select 	mssqltooleping
	Append From Dbf('tmpTooleping')
	Use In tmptooleping



	If sqlexec(gnhandlePG,'delete from palk_kaart') < 0
		Set Step On
		Return .F.
	Endif



	Select 	mssqlpalkkaart
	Append From Dbf('tmppalkkaart')
	Use In tmppalkkaart



	If sqlexec(gnhandlePG,'delete from palk_taabel1') < 0
		Set Step On
		Return .F.
	Endif



	Select 	mssqlpalktaabel
	Append From Dbf('tmppalktaabel')
	Use In tmppalktaabel



	If sqlexec(gnhandlePG,'delete from palk_oper ') < 0
		Set Step On
		Return .F.
	Endif


	Select 	mssqlpalkoper
	Append From Dbf('tmppalkoper')
	Use In tmppalkoper


	If sqlexec(gnhandlePG,'delete from palk_jaak ') < 0
		Set Step On
		Return .F.
	Endif

	Select 	mssqlpalkjaak
	Append From Dbf('tmppalkjaak')
	Use In tmppalkjaak


	lError = 1
	Set Step On
	Select mssqltooleping
	Scan
&& kontrol
		Wait Window 'tooleping:'+Str(Recno('mssqltooleping'))+'/'+Str(Reccount('mssqltooleping')) Nowait
		lcString = "select id from tooleping where id = "+Str(mssqltooleping.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryTooL')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryTooL') < 1
			lcString = " insert into tooleping (id , parentid , osakondid ,ametid,  algab , lopp ,"+;
				" toopaev ,palk ,  palgamaar , pohikoht ,  koormus ,ametnik ,tasuliik ,pank ,  aa ,  muud , rekvid ) values (" +;
				str(mssqltooleping.Id)+","+Str(mssqltooleping.parentid) +","+ Str(mssqltooleping.osakondid)+" ,"+;
				STR(mssqltooleping.ametId)+"," + DateToStr(mssqltooleping.algab)+","+DateToStr(mssqltooleping.lopp)+","+Str(mssqltooleping.toopaev)+","+Str(mssqltooleping.palk,12,4)+","+;
				STR(mssqltooleping.palgamaar)+","+ Str(mssqltooleping.pohikoht)+","+ Str(mssqltooleping.koormus)+","+;
				STR(mssqltooleping.ametnik)+","+Str(mssqltooleping.tasuliik)+","+Str(mssqltooleping.pank)+",'"+;
				mssqltooleping.aa +"','"+Iif(Isnull(mssqltooleping.muud),' ',mssqltooleping.muud)+"',"+Str(mssqltooleping.rekvId)+")"

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan

	If lError > 0

		Select mssqlpalkkaart


		Scan
&& kontrol

			Select mssqltooleping
			Locate For Id = mssqlpalkkaart.lepingid
			If Found()

				Wait Window 'Palkkaart:'+Str(Recno('mssqlpalkkaart'))+'/'+Str(Reccount('mssqlpalkkaart')) Nowait
				lcString = "select id from palk_kaart where id = "+Str(mssqlpalkkaart.Id)
				lError = sqlexec(gnhandlePG, lcString,'qryPKaart')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If Reccount('qryPkaart') < 1
					lcString = " insert into palk_kaart (id,  parentid  ,  lepingid  ,  libid,  summa,"+;
						" percent_ ,  tulumaks ,  tulumaar ,  status , alimentid ,  tunnusid) values ("+;
						STR(mssqlpalkkaart.Id)+","+  Str(mssqlpalkkaart.parentid)+"  ,"+  Str(mssqlpalkkaart.lepingid)+","+;
						STR(mssqlpalkkaart.libid)+","+  Str(mssqlpalkkaart.Summa,12,4)+","+ Str(mssqlpalkkaart.percent_)+" ,"+;
						STR(mssqlpalkkaart.tulumaks)+" ,"+  Str(mssqlpalkkaart.tulumaar)+" ,"+Str(mssqlpalkkaart.Status)+" ,"+;
						STR(mssqlpalkkaart.alimentid)+" ,"+Str(mssqlpalkkaart.tunnusid)+")"

					lError = sqlexec(gnhandlePG, lcString)
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						_Cliptext = lcString
						Exit
					Endif
				Endif
			Endif

		Endscan

	Endif

	If lError > 0

		Select mssqlpalktaabel
		Scan
&& kontrol
			Wait Window 'Palktaabel:'+Str(Recno('mssqlpalktaabel'))+'/'+Str(Reccount('mssqlpalktaabel')) Nowait

			Select mssqltooleping
			Locate For Id = mssqlpalktaabel.toolepingid
			If Found()


				lcString = "select id from palk_taabel1 where id = "+Str(mssqlpalktaabel.Id)
				lError = sqlexec(gnhandlePG, lcString,'qryPTab')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If Reccount('qryPtab') < 1
					lcString = " insert into palk_taabel1 (id ,  toolepingid ,  kokku ,  too ,  paev , ohtu ,  oo ,  tahtpaev,  puhapaev,  kuu,  aasta) values ("+;
						STR(mssqlpalktaabel.Id)+" ,"+  Str(mssqlpalktaabel.toolepingid)+" ,"+  Str(mssqlpalktaabel.kokku)+" ,"+;
						STR(mssqlpalktaabel.too)+" ,"+  Str(mssqlpalktaabel.paev)+" ,"+ Str(mssqlpalktaabel.ohtu)+" ,"+;
						STR(mssqlpalktaabel.oo)+" ,"+  Str(mssqlpalktaabel.tahtpaev)+","+  Str(mssqlpalktaabel.puhapaev)+","+;
						STR(mssqlpalktaabel.kuu)+","+  Str(mssqlpalktaabel.aasta)+")"

					lError = sqlexec(gnhandlePG, lcString)
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						_Cliptext = lcString
						Exit
					Endif
				Endif
			Endif

		Endscan
	Endif

	If lError > 0

		Select mssqlpuudumine
		Scan
&& kontrol

			Wait Window 'Puudumine:'+Str(Recno('mssqlpuudumine'))+'/'+Str(Reccount('mssqlpuudumine')) Nowait

			Select mssqltooleping
			Locate For Id = mssqlpuudumine.lepingid
			If Found()


				lcString = "select id from puudumine where id = "+Str(mssqlpuudumine.Id)
				lError = sqlexec(gnhandlePG, lcString,'qryPuud')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If Reccount('qryPuud') < 1
					lcString = " insert into puudumine (id ,lepingid ,kpv1,kpv2,paevad ,summa ,tunnus ,tyyp,libid) values ("+;
						STR(mssqlpuudumine.Id)+" ,"+Str(mssqlpuudumine.lepingid)+","+ DateToStr(mssqlpuudumine.kpv1) + ","+ DateToStr(mssqlpuudumine.kpv2) + ","+;
						STR(mssqlpuudumine.paevad)+" ,"+Str(mssqlpuudumine.Summa,12,4)+" ,"+Str(mssqlpuudumine.tunnus)+" ,"+;
						STR(mssqlpuudumine.tyyp)+","+Str(mssqlpuudumine.libid)+")"
					lError = sqlexec(gnhandlePG, lcString)
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						_Cliptext = lcString
						Exit
					Endif

				Endif
			Endif

		Endscan
	Endif



	If lError > 0

		Select mssqlpalkoper
		Scan
&& kontrol
			Wait Window 'Palkoper:'+Str(Recno('mssqlpalkoper'))+'/'+Str(Reccount('mssqlpalkoper')) Nowait

			Select mssqltooleping
			Locate For Id = mssqlpalkoper.lepingid
			If Found()

				lcString = "select id from palk_oper where id = "+Str(mssqlpalkoper.Id)
				lError = sqlexec(gnhandlePG, lcString,'qryPOper')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If Reccount('qryPOper') < 1
					lcString = " insert into palk_oper (id,  rekvid ,  libid ,  lepingid ,  kpv,  summa ,doklausid ) values ("+;
						STR(mssqlpalkoper.Id)+","+  Str(mssqlpalkoper.rekvId)+" ,"+  Str(mssqlpalkoper.libid)+" ,"+;
						STR(mssqlpalkoper.lepingid)+","+ DateToStr(mssqlpalkoper.kpv)+","+  Str(mssqlpalkoper.Summa,12,4) +","+Str(mssqlpalkoper.doklausid)+")"

					lError = sqlexec(gnhandlePG, lcString)
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						_Cliptext = lcString
						Exit
					Endif
				Endif
			Endif

		Endscan

	Endif

	If lError > 0

		Select mssqlpalkjaak
		Scan
&& kontrol
			Wait Window 'Palkoper:'+Str(Recno('mssqlpalkjaak'))+'/'+Str(Reccount('mssqlpalkjaak')) Nowait

			Select mssqltooleping
			Locate For Id = mssqlpalkjaak.lepingid
			If Found()

				lcString = "select id from palk_jaak where id = "+Str(mssqlpalkjaak.Id)
				lError = sqlexec(gnhandlePG, lcString,'qryPOper')
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					Exit
				Endif
				If Reccount('qryPOper') < 1
					lcString = " insert into palk_jaak (Id , lepingid,kuu,aasta,jaak,arvestatud,kinni,tki,tka,pm,tulumaks,sotsmaks,muud, g31 ) values ("+;
						STR(mssqlpalkjaak.Id) +","+ Str(mssqlpalkjaak.lepingid)+","+Str(mssqlpalkjaak.kuu)+","+;
						Str(mssqlpalkjaak.aasta)+","+Str(mssqlpalkjaak.jaak)+","+Str(mssqlpalkjaak.arvestatud)+","+;
						Str(mssqlpalkjaak.kinni)+","+Str(mssqlpalkjaak.tki)+","+Str(mssqlpalkjaak.tka)+","+Str(mssqlpalkjaak.pm)+","+;
						Str(mssqlpalkjaak.tulumaks)+","+Str(mssqlpalkjaak.sotsmaks)+","+Str(mssqlpalkjaak.muud)+","+ Str(mssqlpalkjaak.g31)+")"

					lError = sqlexec(gnhandlePG, lcString)
					If lError < 1
						Messagebox("Viga "+lcString,'Kontrol')
						Set Step On
						_Cliptext = lcString
						Exit
					Endif
				Endif
			Endif

		Endscan

	Endif


	Return lError
Endfunc


Function nom_import

	If sqlexec(gnhandlePG,'delete from nomenklatuur') < 1
		Set Step On
		Return .F.
	Endif


	Select mssqlnom
	Append From Dbf('tmpNom')
	Use In tmpNom


	If sqlexec(gnhandlePG,'delete from klassiflib') < 1
		Set Step On
		Return .F.
	Endif



*!*		Select mssqlklassif
*!*		Append From Dbf('tmpKl')
*!*		Use In tmpKl


	If sqlexec(gnhandlePG,'delete from autod') < 1
		Set Step On
		Return .F.
	Endif


	Select mssqlautod
	Append From Dbf('tmpautod')
	Use In tmpautod


	Select mssqlnom
	Scan
&& kontrol
		Wait Window mssqlnom.nimetus Nowait
		lcString = "select id from nomenklatuur where id = "+Str(mssqlnom.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryNom')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryNom') < 1
			lcString = " insert into nomenklatuur (id,rekvid , doklausid, dok,kood,	nimetus,  uhik,  hind, muud ,  ulehind,kogus,  formula) values ("+;
				STR(mssqlnom.Id)+","+Str(mssqlnom.rekvId)+","+Str(mssqlnom.doklausid)+",'"+Ltrim(Rtrim(mssqlnom.dok))+"','"+Ltrim(Rtrim(mssqlnom.kood))+"','"+;
				LTRIM(Rtrim(remove_simbol(mssqlnom.nimetus)))+"','"+;
				LTRIM(Rtrim(mssqlnom.uhik))+"',"+Str(mssqlnom.hind,12,2)+",'"+Iif(Isnull(mssqlnom.muud),'',mssqlnom.muud)+"',"+Str(mssqlnom.ulehind,12,2)+","+;
				STR(mssqlnom.kogus,12,4)+",'" +mssqlnom.formula+"')"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				_Cliptext = lcString
				Exit
			Endif
		Endif
	Endscan
	If lError > 0

		Select mssqlklassif
		Scan
&& kontrol
			Wait Window 'mssqlklassif' + Str(Recno('mssqlklassif'))+'/'+ Str(Reccount('mssqlklassif')) Nowait
			lcString = "select id from klassiflib where id = "+Str(mssqlklassif.Id)
			lError = sqlexec(gnhandlePG, lcString,'qryNom')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			If Reccount('qryNom') < 1
				lcString = " insert into KLASSIFLIB (id,nomid,palklibid,libid,tyyp,tunnusid,kood1,kood2,kood3,kood4,kood5,konto) values ("+;
					STR(mssqlklassif.Id)+","+Str(mssqlklassif.nomid)+","+Str(mssqlklassif.palklibid)+","+Str(mssqlklassif.libid)+","+;
					STR(mssqlklassif.tyyp)+","+Str(mssqlklassif.tunnusid)+",'"+mssqlklassif.kood1+"','"+mssqlklassif.kood2+"','"+;
					mssqlklassif.kood3+"','"+mssqlklassif.kood4+"','"+mssqlklassif.kood5+"','"+mssqlklassif.konto+"')"
				lError = sqlexec(gnhandlePG, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan
	Endif
	If lError > 0

		Select mssqlautod
		Scan
&& kontrol
			Wait Window 'mssqlautod' + Str(Recno('mssqlautod'))+'/'+ Str(Reccount('mssqlautod')) Nowait
			lcString = "select id from autod where id = "+Str(mssqlautod.Id)
			lError = sqlexec(gnhandlePG, lcString,'qryA')
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif



			If Reccount('qryA') < 1
				lcString = " insert into autod (id,omanikid,mark,regnum,idkood,tuubikood,vinkood, mootor, aasta, voimsus ,  kindlustus , saadetud, status,  muud ) values ("+;
					STR(mssqlautod.Id)+","+Str(mssqlautod.omanikid)+",'"+mssqlautod.Mark+"','"+mssqlautod.regnum+"','"+;
					mssqlautod.idkood+"','"+mssqlautod.tuubikood+"','"+mssqlautod.vinkood+"','"+ mssqlautod.mootor+"',"+;
					STR(mssqlautod.aasta)+","+Str(mssqlautod.voimsus)+",'"+mssqlautod.kindlustus+"','"+;
					mssqlautod.saadetud+"',"+Str(mssqlautod.Status)+",'"+ Iif(Isnull(mssqlautod.muud),'',mssqlautod.muud) +"')"

				lError = sqlexec(gnhandlePG, lcString)
				If lError < 1
					Messagebox("Viga "+lcString,'Kontrol')
					Set Step On
					_Cliptext = lcString
					Exit
				Endif
			Endif
		Endscan
	Endif

	Return lError
Endfunc


Function kasutajad_import
	Select Distinct kasutaja From mssqlUserid Into Cursor pgSysUserid
	Select pgSysUserid
	lcString = 'select * from pg_user'
	lError = sqlexec(gnhandlePG, lcString,'qryPgUserid')
	If lError < 1
		Messagebox("Viga "+lcString,'Kontrol')
		Set Step On
		Return
	Endif

	Select pgSysUserid
	Scan
		Wait Window pgSysUserid.kasutaja Nowait
		Select qryPgUserid
		Locate For Upper(usename) =  Upper(pgSysUserid.kasutaja)
		If !Found()
&& uus user
			lcPassword = Lower(Right(Sys(2015),9))
			Update mssqlUserid Set Password = lcPassword Where kasutaja = pgSysUserid.kasutaja
			lcGrupp = 'KASUTAJA'
			lcString = 'CREATE USER "'+ Ltrim(Rtrim(pgSysUserid.kasutaja))+'"'+;
				" PASSWORD '"+lcPassword +"' NOCREATEDB NOCREATEUSER in group dbkasutaja "

			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
			lcString = "CREATE USER "+ Ltrim(Rtrim(pgSysUserid.kasutaja))+;
				" PASSWORD '"+lcPassword +"' NOCREATEDB NOCREATEUSER in group dbkasutaja "

		Endif
	Endscan
	Select * From mssqlUserid Into Table mssqlUseridtbl
	Return lError

Endfunc

Function rekv_import
	Select qryMssqlrekv
	Scan
&& kontrol
		lcString = "select id from rekv where id = "+Str(qryMssqlrekv.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryrekv')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryRekv') < 1
			lcString = " insert into rekv (id,  parentid,regkood,nimetus,kbmkood,aadress,haldus,tel,faks, email,juht, raama, "+;
				" muud,  recalc ) values ("+;
				STR(qryMssqlrekv.Id)+","+Str(qryMssqlrekv.parentid)+",'"+qryMssqlrekv.regkood+"','"+qryMssqlrekv.nimetus+"','"+;
				qryMssqlrekv.kbmkood+"','"+qryMssqlrekv.aadress+"','"+qryMssqlrekv.haldus+"','"+qryMssqlrekv.tel+"','"+;
				qryMssqlrekv.faks+"','"+qryMssqlrekv.email+"','"+qryMssqlrekv.juht+"','"+;
				qryMssqlrekv.raama+"','"+Iif(Isnull(qryMssqlrekv.muud),'',qryMssqlrekv.muud)+"',"+Str(qryMssqlrekv.recalc)+")"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif

	Endscan
	Return lError
Endfunc

Function userid_import
&& import userid
	Select mssqlUserid
	Scan
*!*		Create Cursor mssqlUserid (lnRowid Int, rekvId Int, kasutaja c(40), ametnik c(254), ;
*!*			kasutaja_ Int, peakasutaja_ Int, admin_ Int, muud m null, Password c(10))
		Wait Window mssqlUserid.ametnik Nowait
		lcString = " select id from userid where id = "+Str(mssqlUserid.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryUserId')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryUserId') < 1
			lcString = " insert into userid (id, rekvid, kasutaja, ametnik, kasutaja_, peakasutaja_,admin) values ("+;
				STR(mssqlUserid.Id)+","+Str(mssqlUserid.rekvId)+",'"+mssqlUserid.kasutaja+"','"+;
				mssqlUserid.ametnik+"',"+Str(mssqlUserid.kasutaja_)+","+Str(mssqlUserid.peakasutaja_)+","+;
				STR(mssqlUserid.admin_)+")"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Function asutus_import
	Select 	qryasutus
	Scan
		Wait Window qryasutus.nimetus Nowait
		lcString = " select id from asutus where id = "+Str(qryasutus.Id)
		lError = sqlexec(gnhandlePG, lcString,'qryAsut')
		If lError < 1
			Messagebox("Viga "+lcString,'Kontrol')
			Set Step On
			Exit
		Endif
		If Reccount('qryAsut') < 1
			lcString = " insert into asutus (id,rekvid,regkood,nimetus,omvorm,aadress, kontakt,tel,faks,email,muud, tp) values ("+;
				STR(qryasutus.Id)+","+Str(qryasutus.rekvId)+",'"+qryasutus.regkood+"','"+qryasutus.nimetus+"','"+;
				qryasutus.omvorm+"','"+qryasutus.aadress+"','"+qryasutus.kontakt+"','"+;
				qryasutus.tel+"','"+qryasutus.faks+"','"+qryasutus.email+"','"+;
				IIF(Isnull(qryasutus.muud),'',qryasutus.muud)+"','800599')"
			lError = sqlexec(gnhandlePG, lcString)
			If lError < 1
				Messagebox("Viga "+lcString,'Kontrol')
				Set Step On
				Exit
			Endif
		Endif
	Endscan
	Return lError
Endfunc

Endfunc



Function remove_simbol
	Lparameters tcString
	Local lcString
	lcString = ''
	lcProjStr = "'"

	If lcProjStr $ lcString
*	lnStart = STUFF(tcString,AT(tcString,lcProjStr),'')
		lnStart = Stuff(tcString,At(lcProjStr,tcString),1,'')

	Endif


	Return lcString


Function DateToStr
	Lparameters tdKpv

	Local lcString

	If Type('tdKpv') = 'C'
		tdKpv = Alltrim(tdKpv)
		tdKpv = Date(Val(Right(tdKpv,4)),Val(Substr(tdKpv,4,2)),Val(Left(tdKpv,2)))
	Endif

	If Empty(tdKpv) Or Type('tdKpv') <> 'D'
		lcString = 'null'
	Else
		lcString = "DATE("+Left(Dtoc(tdKpv,1),4)+","+Substr(Dtoc(tdKpv,1),5,2)+","+Right(Dtoc(tdKpv,1),2)+")"
	Endif

	Return lcString
