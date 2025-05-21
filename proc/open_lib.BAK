Parameters tnOpt
*On Error
l_test = .F.
If (l_test)
	gcProgNimi = 'EELARVE'

	Set Classlib To classes\Classlib
	gVersia = 'PG'
	oDb = Createobject('db')

	gRekv = 1
	guserid = 1
	tnId = 0

	gnHandle = SQLConnect('localPg', 'vlad','123')
	gnHandleAsync = gnHandle

	If gnHandle < 0
		Messagebox('Connection error',0+48,'Error')
		Return .T.
	Endif

Endif




If Empty(tnOpt)
	= OpenView('comTpremote',.T., 'comTpremote', 'libs\libraries\tp')
	Select coMTpremote
	Index On Id Tag Id
	Index On Left(koOd,20) Tag koOd
	Set Order To Id

	= OpenView('comEelarveremote',.T., 'comEelarveRemote', 'libs\libraries\artikkel')
	Select comEelarveremote
	Index On Id Tag Id
	Index On Left(koOd,20) Tag koOd Additive
	Set Order To Id

	= OpenView('comAllikadRemote',.T., 'comAllikadRemote', 'libs\libraries\allikas')
	Select coMallikadremote
	Index On Id Tag Id
	Index On Left(koOd,20) Tag koOd
	Set Order To Id

	= OpenView('comRahaRemote',.T., 'comRahaRemote', 'libs\libraries\rahavoog')
	Select coMRaharemote
	Index On Id Tag Id
	Index On Left(koOd,20) Tag koOd
	Set Order To Id

	= OpenView('comtegevremote',.T., 'comTegevRemote', 'libs\libraries\tegev')
	Select coMtegevremote
	Index On Id Tag Id
	Index On Left(koOd,20) Tag koOd
	Set Order To Id


ENDIF

get_cities()

= OpenView('comLaduRemote',.T., 'comLaduRemote', 'ladu\ladu')

Select comLaduRemote
Index On Id Tag Id
Index On Left(koOd,40) Tag koOd Additive
Set Order To Id


= OpenView('comObjektremote',.T., 'comObjektRemote', 'libs\libraries\objekt')

Select comObjektRemote
Index On Id Tag Id
Index On Left(koOd,40) Tag koOd Additive
Set Order To Id

=OpenView('comAaRemote',.T., 'comAaRemote', 'ou\aa')
Index On Id Tag Id
Set Order To Id

= OpenView('comGruppRemote',.T.,'comGruppRemote','libs\libraries\pv_grupp')
Select comGruppRemote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comProjremote', .T., 'comProjRemote','libs\libraries\project')
Select comProjremote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comUritusremote', .T., 'comUritusRemote', 'libs\libraries\uritus')
Select comUritusremote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

tdKehtivus = Date() - 365
If (OpenView('comasutusRemote', .T.,'comAsutusRemote','libs\libraries\asutused'))
	Select coMasutusremote
	Index On Id Tag Id
	Index On Left(reGkood,40) Tag reGkood Additive
	Index On Left(Upper(niMetus), 40) Tag niMetus Additive
	Set Order To Id
Endif

=OpenView('comDokRemote', .T.,'comDokRemote','libs\libraries\dok')
Select comDokremote
Index On Left(koOd,20) Tag koOd
Index On Id Tag Id
Set Order To Id

= OpenView('comkassaRemote', .T., 'comKassaRemote', 'ou\kassa')
Select comkassaRemote
Index On Id Tag Id
Set Order To Id

= OpenView('comkontodRemote',.T., 'comkontodRemote', 'libs\libraries\kontod')
Select coMkontodremote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comnomRemote', .T.,'comnomRemote','libs\libraries\nomenclature')
Select coMnomremote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comtunnusRemote', .T.,'comtunnusRemote','libs\libraries\tunnus')
Select comtunnusRemote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

*!*	If gcProgNimi = 'HOOLDEKODU.EXE'
*!*		lcString = "select count(id) as kogus from hooettemaksud where staatus = 1"
*!*		lError = SQLEXEC(gnHandle,lcString,'qry')
*!*		If lError > 0 And Used('qry') And Val(Alltrim(qry.kogus)) > 0
*!*			Messagebox('Leitud klassifitseerimata ettemaksed')
*!*	* leitud klassifitseerimata ettemasud, kaivitame ettemasu register
*!*			oTools.btnEttemaks.Click()
*!*		Endif
*!*	Endif


Return
Endproc


*
Procedure OpenView
	Lparameter tcView, tlopt, tcCursor, tcModel
	If Empty(tcCursor)
		tcCursor = tcView
	Endif
	If !Empty(tcModel)
		lError = oDb.readFromModel(tcModel, 'selectAsLibs', 'gRekv, guserid', tcView)
		If !lError
			Set Step On
			Return .F.
		Endif

	Else
		Set Step On
	Endif
Endproc
*


PROCEDURE get_cities
IF !USED('qryCities')
	CREATE CURSOR qryCities (nimetus c(254)) 
	INSERT INTO qryCities (nimetus) VALUES ('Haapsalu')
	INSERT INTO qryCities (nimetus) VALUES ('Keila')
	INSERT INTO qryCities (nimetus) VALUES ('Kohtla-Jarve')
	INSERT INTO qryCities (nimetus) VALUES ('Kunda')
	INSERT INTO qryCities (nimetus) VALUES ('Maardu')
	INSERT INTO qryCities (nimetus) VALUES ('NARVA')
	INSERT INTO qryCities (nimetus) VALUES ('NARVA-JÕESUU')
	INSERT INTO qryCities (nimetus) VALUES ('Paide')
	INSERT INTO qryCities (nimetus) VALUES ('Paldiski')
	INSERT INTO qryCities (nimetus) VALUES ('Rakvere')
	INSERT INTO qryCities (nimetus) VALUES ('Sillamae')
	INSERT INTO qryCities (nimetus) VALUES ('Tallinn')
	INSERT INTO qryCities (nimetus) VALUES ('Tartu')
	INSERT INTO qryCities (nimetus) VALUES ('Valga')
	INSERT INTO qryCities (nimetus) VALUES ('Võru')
	INSERT INTO qryCities (nimetus) VALUES ('Võsu')
	INSERT INTO qryCities (nimetus) VALUES ('Väike-Marja')
	INSERT INTO qryCities (nimetus) VALUES ('Tapa')
endif
ENDPROC
