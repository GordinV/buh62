Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_doklausend'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'raamatupidamine\doklausend'

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


=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_row_validate_model()
	lcAlias = 'validate'
	cursorName = 'v_doklausHeader'
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
		Replace Id With 0, rekvid With gRekv, selg With '__test' + Left(Alltrim(Str(Rand() * 10000)),10)

		Select v_doklausend
		Insert Into v_doklausend (Summa,  deebet, kreedit) Values ;
			(100, '111','113')

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

		lError = oDb.readFromModel(lcModel, lcAlias, 'gUserid,tnId','result')

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
		lcJson = ''
		lcAlias = 'saveDoc'
* parameters

		Select v_doklausend
		Go Top
		lcJson = '"gridData":['+ oDb.getJson() + ']'

		Select v_doklausHeader
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data": '+ oDb.getJson(lcJson) + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_doklausHeader')

		If 	!lError And Used('v_doklausHeader') And Reccount('v_doklausHeader') > 0 And v_doklausHeader.Id < 1
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			SELECT v_doklausHeader
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed,' + Alltrim(Str(Id)) Timeout 1
			Select v_doklausHeader
			tnId = Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_doklausHeader'
	With oDb
		lcAlias = 'row'

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError Or !Used(cursorName) Or Reccount(cursorName) = 0
			Return .F.
		Endif

		Dimension aCheckedFields(3)
		aCheckedFields[1] = 'DOK'
		aCheckedFields[2] = 'MUUD'
		aCheckedFields[3] = 'SELG'

		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

		If !lError
			Return .F.
		Endif

* details

		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_doklausend')

		If !lError Or !Used('v_doklausHeader') Or !Used('v_doklausend')
			lError = .F.
		Endif

		Dimension aCheckedFields(9)
		aCheckedFields[1] = 'DEEBET'
		aCheckedFields[2] = 'KREEDIT'
		aCheckedFields[3] = 'LISA_D'
		aCheckedFields[4] = 'LISA_K'
		aCheckedFields[5] = 'KOOD1'
		aCheckedFields[6] = 'KOOD2'
		aCheckedFields[7] = 'KOOD3'
		aCheckedFields[8] = 'KOOD5'
		aCheckedFields[9] = 'SUMMA'

		lError = check_fields_in_cursor(@aCheckedFields, 'v_doklausend')

		If !lError
			Return .F.
		Endif

		If 	!lError  Or Reccount(cursorName) = 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Function test_of_row_model

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_doklausHeader')
		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_doklausend')

		If 	!lError Or !Used('v_doklausHeader') Or Reccount('v_doklausend') = 0 Or !Used('v_doklausend') Or Reccount('v_doklausend') = 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	Local cursorName
	Dimension aCheckedFields(6)
	aCheckedFields[1] = 'DOK'
	aCheckedFields[2] = 'SELG'
	aCheckedFields[3] = 'LISA_D'
	aCheckedFields[4] = 'LISA_K'
	aCheckedFields[5] = 'DEEBET'
	aCheckedFields[6] = 'KREEDIT'

	cursorName  = 'tmpDokLausend'

	Local lcWhere
	tcDeebet = '11%'
TEXT TO lcWhere NOSHOW textmerge
	deebet ilike ?tcDeebet
ENDTEXT


	lcAlias = 'curDoklausend'
* parameters
	lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', cursorName, lcWhere)

	If 	!lError Or !Used(cursorName)
		Messagebox('test failed',0 + 48,'Error')
		Set Step On
		Return .F.
	Endif

	lError = check_fields_in_cursor(@aCheckedFields, cursorName)

	If 	!lError
		Messagebox('test failed, puuduvad vajaliku andmed',0 + 48,'Error')
		Return .F.
	Endif

* success
	If lError
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 3
		Use In (cursorName)
	Endif
	Return lError
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
