Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_library'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'raamatupidamine\journal'

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
	cursorName = 'v_journal'
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
		Replace Id With 0, rekvid With gRekv, selg With '__test' + Left(Alltrim(Str(Rand() * 10000)),10),;
			summa WITH 100, kpv WITH DATE()
			
		SELECT v_journal1
		INSERT INTO v_journal1 (deebet, kreedit, summa) VALUES ('DB', 'KR', 100)
			
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
* parameters
		Select v_journal1
		lcJson = '"gridData":['+ oDb.getJson() + ']'

		Select(cursorName)
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data": '+ oDb.getJson(lcJson) +  ',' + lcJson + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', cursorName)

		If 	!lError OR !used(cursorName) or Reccount(cursorName) = 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success	
			SELECT(cursorName)
			Wait Window 'test model ' + lcModel + ',  saveDoc new -> passed,' + ALLTRIM(STR(id)) Timeout 1
			Select(cursorName)
			tnId = Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_journal'
	With oDb
		lcAlias = 'row'

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError
			Return .F.
		ENDIF
		
		Dimension aCheckedFields(7)
		aCheckedFields[1] = 'NUMBER'
		aCheckedFields[2] = 'KPV'
		aCheckedFields[3] = 'ASUTUSID'
		aCheckedFields[4] = 'SELG'
		aCheckedFields[5] = 'DOK'
		aCheckedFields[6] = 'OBJEKT'
		aCheckedFields[7] = 'MUUD'

		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

		IF !lError 
			Return .F.			
		ENDIF
		
* details

		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_journal1')

		If !lError Or !Used('v_journal1') Or !Used('v_journal')
			lError = .F.
		Endif

		Dimension aCheckedFields(18)
		aCheckedFields[1] = 'DEEBET'
		aCheckedFields[2] = 'KREEDIT'
		aCheckedFields[3] = 'SUMMA'
		aCheckedFields[4] = 'LISA_D'
		aCheckedFields[5] = 'LISA_K'
		aCheckedFields[6] = 'KOOD1'
		aCheckedFields[7] = 'KOOD2'
		aCheckedFields[8] = 'KOOD3'
		aCheckedFields[9] = 'KOOD5'
		aCheckedFields[10] = 'TUNNUS'
		aCheckedFields[11] = 'PROJ'
		aCheckedFields[12] = 'KOOD4'
		aCheckedFields[13] = 'VALUUTA'
		aCheckedFields[14] = 'KUURS'

		lError = check_fields_in_cursor(@aCheckedFields, 'v_journal1')

		IF !lError 
			Return .F.			
		ENDIF

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
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_journal')
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_journal1')

		If 	!lError Or !Used('v_journal') Or Reccount('v_journal') = 0 Or !Used('v_journal1') Or Reccount('v_journal1') = 0
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
	Dimension aCheckedFields(22)
	aCheckedFields[1] = 'KPV'
	aCheckedFields[2] = 'DEEBET'
	aCheckedFields[3] = 'LISA_D'
	aCheckedFields[4] = 'KREEDIT'
	aCheckedFields[5] = 'SUMMA'
	aCheckedFields[6] = 'LISA_K'
	aCheckedFields[7] = 'VALUUTA'
	aCheckedFields[8] = 'SELG'
	aCheckedFields[9] = 'DOK'
	aCheckedFields[10] = 'ASUTUS'
	aCheckedFields[11] = 'TUNNUS'
	aCheckedFields[12] = 'KOOD1'
	aCheckedFields[13] = 'KOOD5'
	aCheckedFields[14] = 'KOOD2'
	aCheckedFields[15] = 'KOOD3'
	aCheckedFields[16] = 'NUMBER'
	aCheckedFields[17] = 'SUMMA_KOKKU'
	aCheckedFields[18] = 'READ_KOKKU'
	aCheckedFields[19] = 'KASUTAJA'
	aCheckedFields[20] = 'MUUD'
	aCheckedFields[21] = 'OBJEKT'
	aCheckedFields[22] = 'VALUUTA'
	
	cursorName  = 'tmpJournal'
	With oDb
		Local lcWhere
		lcWhere = "selg ilike 'test%'"
		lcSubTotals = " sum (summa) OVER()  as summa_kokku, count(id) over() as read_kokku"

		lcAlias = 'curJournal'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', cursorName, lcWhere, lcSubTotals)

		If 	!lError Or !Used(cursorName)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		ENDIF
		
		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

		If 	!lError
			Messagebox('test failed, puuduvad vajaliku andmed',0 + 48,'Error')
			Return .F.
		ENDIF

* success
		IF lError
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 3
			Use In (cursorName)
		ENDIF
		
	ENDWITH
	RETURN lError
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

	RETURN lError
Endfunc
