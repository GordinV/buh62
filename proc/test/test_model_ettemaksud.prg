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

lcModel = 'rekl\ettemaksud'

* asutused
lError = oDb.readFromModel( 'libs\libraries\asutused', 'selectAsLibs', 'gRekv, guserid', 'comAsutusedRemote')
SELECT comAsutusedRemote
GO bottom

Wait Window 'test model ' + lcModel  Timeout 1
lsuccess = test_of_grid_model()
If lsuccess
	lsuccess = test_of_row_new_model()
ENDIF

If lsuccess
	lsuccess = test_of_row_validate_model()
ENDIF

If lsuccess
	lsuccess = test_of_row_save_model()
Endif

If lsuccess
	lsuccess = test_of_row_model()
Endif

If lsuccess
	lsuccess = test_of_row_delete_model()
Endif

=SQLDISCONNECT(gnHandle)

RETURN lsuccess
*Clear All



Function test_of_row_validate_model()
	lcAlias = 'validate'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)

	lcNotValidFields = oDb.Validate(lcValidate, 'v_ettemaks')
* expect LIBRARY
	If Type('lcNotValidFields') = 'C'
		Replace Id With 0, ;
			asutusid WITH comAsutusedRemote.id,;
			kpv WITH DATE(),;
			number WITH 1,;
			selg WITH 'test',;
			summa WITH 500 IN v_ettemaks			

	Endif

	lcNotValidFields = oDb.Validate(lcValidate, 'v_ettemaks')
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

		Select v_ettemaks
		lcJson = '{"id":' + Alltrim(Str(v_ettemaks.Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_ettemaks_id')

		If 	!lError And Used('v_ettemaks_id') And Reccount('v_ettemaks_id') > 0 And !Empty(v_ettemaks_id.Id)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed' + Str(v_ettemaks_id.Id) Timeout 1
			Select v_ettemaks_id
			tnId = v_ettemaks_id.Id
			Use In v_ettemaks_id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	Dimension aCheckedFields(4)
	aCheckedFields[1] = 'SUMMA'
	aCheckedFields[2] = 'ASUTUSID'
	aCheckedFields[3] = 'KPV'
	aCheckedFields[4] = 'SELG'
	
	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_ettemaks')

		If 	!lError And Used('v_ettemaks') And Reccount('v_ettemaks') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lError = check_fields_in_cursor(@aCheckedFields, 'v_ettemaks') 


		If (lError)
* success
			Wait Window 'test model ' + lcModel + ', row new -> passed' Timeout 1
		Endif
		RETURN lError

	Endwith


Function test_of_row_model

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_ettemaks')

		If 	!lError OR !Used('v_ettemaks') or Reccount('v_ettemaks') = 0 OR Empty(v_ettemaks.Id)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		If (lError)
* success
			Wait Window 'test model ' + lcModel + ', row -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	With oDb
		Local lcWhere
		lcWhere = "asutus ilike '%'"
* parameters
		lError = oDb.readFromModel(lcModel, 'curEttemaksud', 'gRekv, guserid', 'tmp', lcWhere)

		If 	!lError Or !Used('tmp') And Reccount('tmp') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', curEttemaksud -> passed' Timeout 3
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