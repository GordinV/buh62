Parameters tnOpt
*On Error
l_test = .f.
If (l_test)
	gcProgNimi = 'EELARVE'
	Create Cursor curkey (versia c(20))
	Insert Into curkey (versia) Values ('EELARVE')

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
	= OpenView('comTpremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.), 'comTpremote', 'libs\libraries\tp')
	Select coMTpremote
	Index On Id Tag Id
	Index On LEFT(koOd,20) Tag koOd
	Set Order To Id

	= OpenView('comEelarveremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.), 'comEelarveRemote', 'libs\libraries\artikkel')
	Select comEelarveremote
	Index On Id Tag Id
	Index On LEFT(koOd,20) Tag koOd Additive
	Set Order To Id
	
	= OpenView('comAllikadRemote',Iif ('EELARVE' $ curkey.versia,.F.,.T.), 'comAllikadRemote', 'libs\libraries\allikas')
	Select coMallikadremote
	Index On Id Tag Id
	Index On LEFT(koOd,20) Tag koOd
	Set Order To Id
	
	= OpenView('comRahaRemote',Iif ('EELARVE' $ curkey.versia,.F.,.T.), 'comRahaRemote', 'libs\libraries\rahavoog')
	Select coMRaharemote
	Index On Id Tag Id
	Index On LEFT(koOd,20) Tag koOd
	Set Order To Id

	= OpenView('comtegevremote',Iif ('EELARVE' $ curkey.versia,.F.,.T.), 'comTegevRemote', 'libs\libraries\tegev')
	Select coMtegevremote
	Index On Id Tag Id
	Index On LEFT(koOd,20) Tag koOd
	Set Order To Id


Endif

= OpenView('comObjektremote',.T., 'comObjektRemote', 'libs\libraries\objekt')

Select comObjektRemote
Index On Id Tag Id
Index On LEFT(koOd,40) Tag koOd Additive
Set Order To Id

=OpenView('comAaRemote',Iif ('EELARVE' $ curkey.versia,.F.,.T.), 'comAaRemote', 'ou\aa')
Index On Id Tag Id
Set Order To Id

= OpenView('comGruppRemote',Iif ('POHIVARA' $ curkey.versia,.F.,.T.),'comGruppRemote','libs\libraries\pv_grupp')
Select comGruppRemote
Index On Id Tag Id
Index On LEFT(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comProjremote', .t., 'comProjRemote','libs\libraries\project')
Select comProjremote
Index On Id Tag Id
Index On LEFT(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comUritusremote', .t., 'comUritusRemote', 'libs\libraries\uritus')
Select comUritusremote
Index On Id Tag Id
Index On LEFT(koOd,20) Tag koOd Additive
Set Order To Id

tdKehtivus = Date() - 365
IF (OpenView('comasutusRemote', .T.,'comAsutusRemote','libs\libraries\asutused'))
	Select coMasutusremote
	Index On Id Tag Id
	Index On LEFT(reGkood,40) Tag reGkood Additive
	Index On Left(Upper(niMetus), 40) Tag niMetus Additive
	Set Order To Id
ENDIF

=OpenView('comDokRemote', .T.,'comDokRemote','libs\libraries\dok')
Select comDokremote
Index On LEFT(koOd,20) Tag koOd
Index On Id Tag Id
Set Order To Id

= OpenView('comkassaRemote', .t., 'comKassaRemote', 'ou\kassa')
Select comkassaRemote
Index On Id Tag Id
Set Order To Id

= OpenView('comkontodRemote',Iif ('RAAMA' $ curkey.versia ,.F.,.T.), 'comkontodRemote', 'libs\libraries\kontod')
Select coMkontodremote
Index On Id Tag Id
Index On LEFT(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comnomRemote', .T.,'comnomRemote','libs\libraries\nomenclature')
Select coMnomremote
Index On Id Tag Id
Index On LEFT(koOd,20) Tag koOd Additive
Set Order To Id
= OpenView('comrekvRemote', .T.,'comRekvRemote','ou\rekv')
Select comrekvRemote
Index On Id Tag Id
Set Order To Id

= OpenView('comtunnusRemote', Iif ('RAAMA' $ curkey.versia ,.F.,.T.),'comtunnusRemote','libs\libraries\tunnus')
Select comtunnusRemote
Index On Id Tag Id
Index On Left(koOd,20) Tag koOd Additive
Set Order To Id

= OpenView('comValuutaRemote',.t.,'comValuutaRemote','libs\libraries\valuuta')
If Used('comValuutaRemote')
	Select coMValuutaRemote
	Index On Id Tag Id
	Index On LEFT(koOd,20) Tag koOd Additive
	Set Order To koOd
Endif

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
	With oDb
		If !Empty(tcModel)
			lError = oDb.readFromModel(tcModel, 'selectAsLibs', 'gRekv, guserid', tcView)
			IF !lError
				SET STEP ON 
				RETURN .f.
			ENDIF
			
		Else

			If  .Not. Used(tcView)
				.Use(tcView,tcCursor,Iif (tlopt = .F.,.F.,.T.),gnHandleAsync)
			Else
				If tlopt = .F.
					.dbReq(tcCursor,gnHandle,tcView)
				Endif
			Endif
		Endif

	Endwith
Endproc
*
