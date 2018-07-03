Parameters tnOpt
*!*	= OpenView('comaaRemote')
*!*	INDEX ON id TAG id
*!*	SET ORDER TO id

= OpenView('comrekvRemote')
SELECT comrekvRemote
Index On Id Tag Id
Set Order To Id

= OpenView('comValuutaRemote')
SELECT comValuutaRemote
Index On Id Tag Id
Set Order To Id

= OpenView('comNomRemote')
SELECT comNomRemote
Index On Id Tag Id
Set Order To Id

=OpenView('comDokRemote', .T.,'comDokRemote','libs\libraries\dok')
Select comDokremote
Index On LEFT(koOd,20) Tag koOd
Index On Id Tag Id
Set Order To Id

*!*	tdKehtivus = Date() - 365
*!*	IF (OpenView('comasutusRemote', .T.,'comAsutusRemote','libs\libraries\asutused'))
*!*		Select coMasutusremote
*!*		Index On Id Tag Id
*!*		Index On LEFT(reGkood,40) Tag reGkood Additive
*!*		Index On Left(Upper(niMetus), 40) Tag niMetus Additive
*!*		Set Order To Id
*!*	ENDIF


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
