Parameter tcKey
_Screen.WindowState = 2
Public gnHandle,gnHandleAsync, gcWindow, gRekv,gUserId, oPrintform2, oFinder, gReturn, oAsutused, oUserid,;
	oArved, oDokLausend, oNomenklatuur, oKontod, oAllikad, oArtikkel, oTegev,;
	oObjekt, oTunnus,oJournal, oSaldo, oAsutused, oUserid, oRekv, oLausendid, oKlsaldo, oDok, oTasud,;
	oLepingud, cKasutaja, oDb, oPohivara, oPvGruppid, oOsakonnad, oAmetid, oPalklib, oPalkOper, oTaabel1, oPeriod,;
	oHoliday, gnKuu, gnAasta, gdKpv, oPalkJaak, oMaksuKoodid,;
	oGruppid, oLaduOper, oVarad, oLaduJaak, oLaduArved, oLaod,;
	gVersia, gcDatabase, glError, oEelarve, oTuludeAllikad, oTulutaitm, oKuluTaitm, gcHelp, oTeenused,;
	tcAllikas, tcArtikkel, tcObjekt, tcTegev, tcEelAllikas, oToograafik, eETSD, tcTunnus, gcProgNimi, omk, oTood,;
	oPuudumised, oEtsd,tcOsakond, tnOsakondId1, tnOsakondId2,gnPaev,tnParentRekvId,;
	oTpr, oRahavoodid, oMenu, oEditMenu, oConnect, oKorderID, gcKey, oVanemtasu, gcAmetnik, oLahetuskulud, oLapsed,;
	oEeltaotlus, oEelVariandid,oDokumendid,;
	oReklmaksud, oReklVolgnik, oReklSaadetud, gMailParool,;
	oProjektid, oUritused, tcProj, tcUritus, tcgrupp, oValuuta,gcCurrentValuuta, glMvt

#Define TM 4
#Define SM 5
#Define TK 7
#Define PM 8

gnPaev = 0
gcAmetnik = ''
tcKasutaja = '%'
gcKey = tcKey
gcProgNimi = 'EELARVE.EXE'
cCaption = _Screen.Caption
glError = .F.
gVersia = 'MSSQL'
gdKpv = Date()
gnHandle = 0
gUserId = 0
gRekv = 0
glMvt = .T.

Local lError
Close Data All
Set Udfparms To Value
On Shutdown Quit
Set Resource Off
Set Hours To 24
Set Compatible Off
Set Null Off
Set Autosave On
Set Point To '.'
Set Help On
Set Lock On
Set Exclusive Off
Set Multilock On
Set Century On
Set Talk Off
Set Console Off
Set Notify Off
Set Safety Off
Set Delete On
Set Ansi On
Set Exact On
Set Console Off
Set Date To German
Set Memowidth To 8000
Set Textmerge On

cFile = 'buh60.chm'
If File(cFile)
	On Key Label F1 Do fHelp
	Set Help To buh60.CHM
	gcHelp = .T.
Else
	Set Help Off
	gcHelp = .F.
Endif

Create Cursor curprinter (Id Int, objekt c(40), nimetus1 c(120), nimetus2 c(120), procfail c(120), reportfail c(120),;
	reportvene c(120), Parameter m)

cFile = 'EELARVE\curPrinter.DBF'
If File (cFile)
	Use (cFile) In 0 Alias curPrinter0
Else
	Use curprinter In 0 Alias curPrinter0
Endif

Select curprinter
Append From Dbf('curPrinter0')

Use In curPrinter0

cFile1 = 'ERI\curPrinter.DBF'
If File (cFile1)
	Use (cFile1) In 0 Alias curPrinter4
	Select curprinter
	Append From Dbf('curPrinter4')
	Use In curPrinter4
Endif

If File ('KEY.DBF')
	Use Key In 0
Endif

If !Used('v_roles')
	Create Cursor v_roles (	nimetus c(120) Default 'Raamatupidaja', asutusid Int, nomid Int, nomidkassa Int,nomidpank Int, kbmnomidkassa Int,;
		kassaid Int, aaid Int, alus c(120),kassanr c(20),arvnr c(20), ;
		dokpropidarvvalju Int, dokpropidsorder Int, dokpropidpank Int, tunnusid Int)
Endif


Create Cursor comkey (Id Int, omanik c(120))
Select Id, Left(decrypt(f_key(),Mline(omanik,1)),120) As omanik From Key Into Cursor qryComkey
Select comkey
Append From Dbf ('qryComkey')
Use In qryComkey
Select comkey
=secure('OFF')
lQuit = .F.


lresult = checkuuendused()

If lresult = .T.
	lnResult = Messagebox ('Kas uuenda programm?',1+32+0,'Uuendamine')
	If lnResult = 1
		! /N git_pull.bat
		lQuit = .T.
	Endif
Endif

If lQuit = .F.
	Set Sysmenu To
	Set Sysmenu Automatic

	Set Classlib To Classlib
	Set Proc To classes\login
	oLogin = Createobject('login', tcKey)
	oLogin.Show()

	Set Classlib To toolseelarve Additive
	oTools = Createobject('Toolseelarve')

	oTools.translate()
	On Error Do err With Program(), Lineno(1)

	If !Empty(tcKey) And tcKey = '-m'
		Do valirekv
	Endif


	Read Events
Endif
Set Proc To
=sqldisconnect(gnHandle)
gnHandle = 0

_Screen.Caption = cCaption
On Key
Set Sysmenu To Default
_Screen.Picture = ''
Clear All
On Error

Procedure Ferr
Endproc

