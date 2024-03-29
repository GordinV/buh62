Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'palk\tooleping'

lError = oDb.readFromModel('libs\libraries\amet', 'selectAsLibs', 'gRekv, guserid', 'comAmetRemote')
SELECT comAmetRemote
LOCATE FOR !ISNULL(osakondid)

lError = oDb.readFromModel('palk\tootaja', 'selectAsLibs', 'gRekv, guserid', 'comTootajadRemote')
SELECT comTootajadRemote
GO bottom


Wait Window 'test model ' + lcModel  Timeout 1
lsuccess = test_of_grid_model()
If lsuccess
	lsuccess = test_of_row_new_model()
Endif
If lsuccess
	lsuccess = test_of_row_validate_model()
Endif
If lsuccess
	lsuccess = test_of_row_save_model()
Endif

If lsuccess
	lsuccess = test_of_row_model()
Endif

If lsuccess
	lsuccess = test_of_row_delete_model()
Endif

If lsuccess
	lsuccess = test_of_selectAsLibs_model()
Endif

=SQLDISCONNECT(gnHandle)
Clear All


Function test_of_selectAsLibs_model
	Dimension aCheckedFields(1)
	aCheckedFields[1] = 'REKVID'

	With oDb
		lcAlias = 'selectAsLibs'
* parameters
		lError = oDb.readFromModel(lcModel, 'selectAsLibs', 'gRekv, guserid', 'comToolepingRemote')

		If 	!lError And Used('comToolepingRemote') And Reccount('comToolepingRemote') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.

		Endif

		lError = check_fields_in_cursor(@aCheckedFields, 'comToolepingRemote')

		If lError
* success
			Wait Window 'test model ' + lcModel + ', selectAsLibs -> passed' Timeout 1
			Use In comToolepingRemote
		Endif
		Return lError
	Endwith
Endfunc


Function test_of_row_validate_model()
	lcAlias = 'validate'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)

	lcNotValidFields = oDb.Validate(lcValidate, 'v_tooleping')
* expect LIBRARY
	If Type('lcNotValidFields') = 'C'
		Replace Id With 0, ;
			parentid WITH comTootajadRemote.id,;
			algab WITH DATE(), osakondid WITH comAmetRemote.osakondid, ametid WITH comAmetRemote.id,;
			palk With 100 In v_tooleping

	Endif

	lcNotValidFields = oDb.Validate(lcValidate, 'v_tooleping')
* expect empty
	If Empty(lcNotValidFields)
		Wait Window 'test model ' + lcModel + ', validate -> passed' Timeout 1
		Return .T.
	Else
		Messagebox('test failed',0 + 48,'Error')
		Set Step On
		Return .F.

	Endif

Endfunc


Function test_of_row_delete_model

	With oDb
* parameters

		lError = oDb.readFromModel(lcModel, 'deleteDoc', 'gUserid,tnId','result')

		If 	!lError Or !Used('result') Or !Isnull(result.error_code)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', deleteDoc delete -> passed' Timeout 1
			Select result
			Return .T.
		Endif


	Endwith


Function test_of_row_save_model

	With oDb
		lcAlias = 'saveDoc'
* parameters
* cursor v_tunnus -> json

		Select v_tooleping
		lcJson = '{"id":' + Alltrim(Str(v_tooleping.Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_tooleping_id')

		If 	!lError And Used('v_tooleping_id') And Reccount('v_tooleping_id') > 0 And !Empty(v_tooleping_id.Id)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed' + Str(v_tooleping_id.Id) Timeout 1
			Select v_tooleping_id
			tnId = v_tooleping_id.Id
			Use In v_tooleping_id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_tooleping')

		If 	!lError And Used('v_tooleping') And Reccount('v_tooleping') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		If (lError)
* success
			Wait Window 'test model ' + lcModel + ', row new -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Function test_of_row_model

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_tooleping')

		If 	!lError And Used('v_tooleping') And Reccount('v_tooleping') > 0 And !Empty(v_tooleping.Id)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		If (lError)
* success
			Wait Window 'test model ' + lcModel + ', row -> passed' Timeout 1
			Use In v_tooleping
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	With oDb
		Local lcWhere
		lcWhere = "amet ilike '%'"
		lcAlias = 'curToolepingud'
* parameters
		lError = oDb.readFromModel(lcModel, 'curToolepingud', 'gRekv, guserid', 'tmp', lcWhere)

		If 	!lError Or !Used('tmp') And Reccount('tmp') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', curToolepingud -> passed' Timeout 3
			Use In tmp
			Return .T.
		Endif
	Endwith
Endfunc



Function check_fields_in_cursor(aCheckedFields, tcAlias)
*	Parameters 	aCheckedFields, tcAlias

	lnFields = Afields(laFields,tcAlias)

	For i = 1 To Alen(aCheckedFields)
		lnElement = Ascan(laFields, aCheckedFields[i])

		If lnElement = 0
			Messagebox('test failed, puudub field ' + aCheckedFields[i],0 + 48,'Error')
			lError = .F.
			Exit
		Endif
	Endfor

	Return lError
Endfunc
