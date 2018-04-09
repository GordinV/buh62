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

lcModel = 'palk\tootaja'

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
		lError = oDb.readFromModel(lcModel, 'selectAsLibs', 'gRekv, guserid', 'comTootajadRemote')

		If 	!lError And Used('comTootajadRemote') And Reccount('comTootajadRemote') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.

		Endif

		lError = check_fields_in_cursor(@aCheckedFields, 'comTootajadRemote')

		If lError
* success
			Wait Window 'test model ' + lcModel + ', selectAsLibs -> passed' Timeout 1
			Use In comTootajadRemote
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
	Select v_asutus_aa
	Append Blank
	Replace aa With 'EE01234' In v_asutus_aa


	lcNotValidFields = oDb.Validate(lcValidate, 'v_asutus')
* expect LIBRARY
	If Type('lcNotValidFields') = 'C'
		Replace Id With 0, regkood With '1234_isik_test' + Alltrim(Str(Rand() * 10000)), nimetus With 'vfp tootaja test ',;
			omvorm With 'ISIK' In v_asutus

	Endif

	lcNotValidFields = oDb.Validate(lcValidate, 'v_asutus')
* expect empty
	If Empty(lcNotValidFields)
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' validate -> passed' Timeout 1
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
		SELECT v_asutus_aa
		lcJson = '"asutus_aa":['+ oDb.getJson() + ']'
		
		Select v_asutus
		lcJson = '{"id":' + Alltrim(Str(v_asutus.Id)) + ',"data":'+ oDb.getJson(lcJson) + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_asutus_id')

		If 	!lError And Used('v_asutus_id') And Reccount('v_asutus_id') > 0 And !Empty(v_asutus_id.Id)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed' + Str(v_asutus_id.Id) Timeout 1
			Select v_asutus_id
			tnId = v_asutus_id.Id
			Use In v_asutus_id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_asutus')

		If 	!lError And Used('v_asutus') And Reccount('v_asutus') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lError = oDb.readFromModel(lcModel, 'asutus_aa', 'tnId, guserid', 'v_asutus_aa')

		If 	!lError And Used('v_asutus_aa')
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
*		CREATE CURSOR v_asutus (id int, regkood c(20), nimetus c(254), omvorm c(20), muud m null)
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_asutus')

		If 	!lError And Used('v_asutus') And Reccount('v_asutus') > 0 And !Empty(v_asutus.Id) And  v_asutus.is_tootaja
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lError = oDb.readFromModel(lcModel, 'asutus_aa', 'tnId, guserid', 'v_asutus_aa')

		If 	!lError And Used('v_asutus_aa') And Reccount('v_asutus_aa') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif


		lError = oDb.readFromModel(lcModel, 'tooleping', 'tnId, guserid', 'v_tooleping')

		If 	!lError And Used('v_tooleping') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lError = oDb.readFromModel(lcModel, 'palk_kaart', 'tnId, guserid', 'v_palk_kaart')

		If 	!lError OR !used('v_palk_kaart') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		tnKuu = MONTH(DATE())
		tnAasta = YEAR(DATE())
		lError = oDb.readFromModel(lcModel, 'curUsed_mvt', 'tnId, tnKuu, tnAasta', 'curUsedMvt')

		If 	!lError or !Used('curUsedMvt') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lError = oDb.readFromModel(lcModel, 'taotlus_mvt', 'tnId, guserid', 'v_taotlus_mvt')

		If 	!lError or !Used('v_taotlus_mvt') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		If (lError)
* success
			Wait Window 'test model ' + lcModel + ', row -> passed' Timeout 1
			Use In v_asutus
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	With oDb
		Local lcWhere
		lcWhere = "isikukood ilike 'test%'"
		lcAlias = 'curTootajad'
* parameters
		lError = oDb.readFromModel(lcModel, 'curTootajad', 'gRekv, guserid', 'tmp', lcWhere)

		If 	!lError Or !Used('tmp') And Reccount('tmp') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', curTootajad -> passed' Timeout 3
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
