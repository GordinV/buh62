Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_dok'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'libs\libraries\dok'

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
	lsuccess = test_of_selectAsLibs_model()
Endif

If lsuccess
	lsuccess = test_of_row_delete_model()
Endif


=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_selectAsLibs_model
	l_cursorName = 'comDokRemote'
	With oDb
		lcAlias = 'selectAsLibs'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', l_cursorName)

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

* kas uut Id in list
		Select(l_cursorName)
		Locate For Id = tnId

		If !Found() Then
			Messagebox('test failed, id not found',0 + 48,'Error')
			Return .F.
		Endif

* success
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Use In (l_cursorName)
		Return .T.

	Endwith


Endfunc


Function test_of_row_validate_model()
	lcAlias = 'validate'
	cursorName = 'v_dok'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)


	lcNotValidFields = oDb.Validate(lcValidate, cursorName)
* expect LIBRARY

	If Type('lcNotValidFields') = 'C'
		Select (cursorName)
		Replace Id With 0, rekvid With gRekv, kood With '__test' + Left(Alltrim(Str(Rand() * 10000)),10),nimetus WITH 'test', library With 'DOK'
	Endif

	lcNotValidFields = oDb.Validate(lcValidate, cursorName)
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
		lcAlias = 'deleteDoc'
* parameters

		lError = oDb.readFromModel(lcModel, 'deleteDoc', 'gUserid,tnId','result')

		If 	!lError Or !Used('result') Or !Isnull(result.error_code)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' delete -> passed' Timeout 1
			Select result
			Return .T.
		Endif


	Endwith


Function test_of_row_save_model
	With oDb
* parameters
		Select(cursorName)
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', cursorName)

		If 	!lError And Used(cursorName) And Reccount(cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test_of_row_save_model ' + lcModel + ', new -> passed' Timeout 1
			Select(cursorName)
			tnId = Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_dok'
	With oDb

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError
			Return .F.
		Endif

		If 	!lError Or !Used(cursorName) Or Reccount(cursorName) = 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test_of_row_new_model' + lcModel + ', new -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Function test_of_row_model
	Dimension aCheckedFields(5)
	aCheckedFields[1] = 'KOOD'
	aCheckedFields[2] = 'NIMETUS'
	aCheckedFields[3] = 'LIBRARY'
	aCheckedFields[4] = 'MODULE'
	aCheckedFields[5] = 'TYPE'

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', cursorName)

		If 	!lError And Used(cursorName) And Reccount(cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

* success
		If lError
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Endif
		Return lError


	Endwith


Endfunc

Function test_of_grid_model
	Local cursorName
	cursorName  = 'tmpDokprop'
	Dimension aCheckedFields(2)
	aCheckedFields[1] = 'KOOD'
	aCheckedFields[2] = 'NIMETUS'


	With oDb
		Local lcWhere
		lcWhere = "nimetus ilike 'test%'"
		lcAlias = 'curDok'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', cursorName, lcWhere)

		If 	!lError Or !Used(cursorName)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif
		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

* success
		If lError
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 3
			Use In (cursorName)
		Endif
		Return lError
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
