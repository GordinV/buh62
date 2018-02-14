Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_arvtasu'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'raamatupidamine\arvtasu'

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
	cursorName = 'v_arvtasu'
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
		Replace Id With 0, rekvid With gRekv, summa WITH 100, pankkassa WITH 4, doc_arv_id WITH 39
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
		tnId = v_arvtasu.id
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
		lcAlias = 'saveDoc'
* parameters
		Select(cursorName)
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', cursorName)

		SELECT (cursorName)
		If 	!lError And Used(cursorName) And Reccount(cursorName) > 0 AND v_arvtasu.id < 1
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' Timeout 1
			Select(cursorName)
			tnId = Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_arvtasu'
	With oDb
		lcAlias = 'row'

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError
			Return .F.
		Endif

		If 	!lError Or !Used(cursorName) Or Reccount(cursorName) = 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Function test_of_row_model
	Dimension aCheckedFields(5)
	aCheckedFields[1] = 'PANKKASSA'
	aCheckedFields[2] = 'SUMMA'
	aCheckedFields[3] = 'KUURS'
	aCheckedFields[4] = 'VALUUTA'
	aCheckedFields[5] = 'MUUD'

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
	Dimension aCheckedFields(9)
	aCheckedFields[1] = 'NUMBER'
	aCheckedFields[2] = 'KPV'
	aCheckedFields[3] = 'SUMMA'
	aCheckedFields[4] = 'ASUTUS'
	aCheckedFields[5] = 'DOK'
	aCheckedFields[6] = 'TASULIIK'
	aCheckedFields[7] = 'OBJEKT'
	aCheckedFields[8] = 'SUMMA_KOKKU'
	aCheckedFields[9] = 'READ_KOKKU'

	lcSubTotals  = " sum (summa) OVER()  as summa_kokku, count(id) over() as read_kokku"

	With oDb
		Local lcWhere
		lcWhere = "dok ilike '%muud%'"
		lcAlias = 'curArvtasud'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', cursorName, lcWhere, lcSubTotals)

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
