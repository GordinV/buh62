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

lcModel = 'raamatupidamine\vmk'

Wait Window 'test model ' + lcModel  Timeout 1

lError = oDb.readFromModel('libs\libraries\nomenclature', 'selectAsLibs', 'gRekv, guserid', 'comnomRemote')
lError = oDb.readFromModel('libs\libraries\asutused', 'selectAsLibs', 'gRekv, guserid', 'comAsutusRemote')
lError = oDb.readFromModel('ou\aa', 'selectAsLibs', 'gRekv, guserid', 'comAaRemote')


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
	lsuccess = test_of_generateJournal()
Endif


If lsuccess
	lsuccess = test_of_row_delete_model()
Endif


=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_generateJournal
* test of  error_code = 4; -- No documents found
	l_tnId_backup = tnId
	tnId = -1
	lError = oDb.readFromModel(lcModel, 'generateJournal', 'guserid, tnId', 'result')

	If !lError Or !Used('result') Or Reccount('result') = 0 Or  result.error_code <> 4
		Messagebox('test failed',0 + 48,'Error')
		Set Step On

	Endif
* error_message = 'User not found';
error_code = 3;

	If lError
		tnId = 	l_tnId_backup
		lUserid = guserid
		guserid = 99999

		lError = oDb.readFromModel(lcModel, 'generateJournal', 'guserid, tnId', 'result')

		If !lError Or !Used('result') Or Reccount('result') = 0 
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
		Endif
	Endif


	guserid = lUserid

* test for succesfull execution
	If lError
		lError = oDb.readFromModel(lcModel, 'generateJournal', 'guserid, tnId', 'result')

	Endif

	If 	!lError Or !Used('result') Or Reccount('result') = 0
		Messagebox('test failed',0 + 48,'Error')
		Set Step On
	Endif

	If lError
* success
		Wait Window 'test model ' + lcModel + ', generateJournal -> passed' Timeout 1
	Endif
	Return	lError
Endfunc





Function test_of_row_validate_model()
	lcAlias = 'validate'
	cursorName = 'v_mk'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)

	lcNotValidFields = oDb.Validate(lcValidate, cursorName)
* expect LIBRARY

	Select comAsutusRemote
	Go Bottom

	If Type('lcNotValidFields') = 'C'
		Select (cursorName)
		Replace Id With 0, rekvid With gRekv, selg With '__test' + Left(Alltrim(Str(Rand() * 10000)),10),;
			Summa With 100, kpv With Date(), maksepaev WITH DATE(), opt WITH 1

		Select comNomRemote
		Go Bottom

		Select v_mk1
		Insert Into v_mk1 (asutusid, nomid,  Summa, aa, konto) Values ;
			(comAsutusRemote.Id, comNomRemote.Id, 100, 'AA1000', '113')

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

		Select v_mk1
		Go Top
		lcJson = '"gridData":['+ oDb.getJson() + ']'

		SELECT v_mk
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data": '+ oDb.getJson(lcJson) + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', cursorName)

		If 	!lError And Used('v_mk') And Reccount('v_mk') > 0 AND v_mk.id < 1
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Select(cursorName)
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed,' + Alltrim(Str(Id)) Timeout 1
			Select(cursorName)
			tnId = Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_mk'
	With oDb
		lcAlias = 'row'

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError
			Return .F.
		Endif

		Dimension aCheckedFields(7)
		aCheckedFields[1] = 'NUMBER'
		aCheckedFields[2] = 'KPV'
		aCheckedFields[2] = 'MAKSEPAEV'
		aCheckedFields[3] = 'ARVID'
		aCheckedFields[4] = 'AAID'
		aCheckedFields[5] = 'VIITENR'
		aCheckedFields[6] = 'MUUD'
		aCheckedFields[7] = 'DOKLAUSID'

		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

		If !lError
			Return .F.
		Endif

* details

		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_mk1')

		If !lError Or !Used('v_mk1') Or !Used('v_mk')
			lError = .F.
		Endif

		Dimension aCheckedFields(15)
		aCheckedFields[1] = 'ASUTUSID'
		aCheckedFields[2] = 'NOMID'
		aCheckedFields[3] = 'TUNNUS'
		aCheckedFields[4] = 'KONTO'
		aCheckedFields[5] = 'TP'
		aCheckedFields[6] = 'KOOD1'
		aCheckedFields[7] = 'KOOD2'
		aCheckedFields[8] = 'KOOD3'
		aCheckedFields[9] = 'KOOD5'
		aCheckedFields[10] = 'KOOD4'
		aCheckedFields[11] = 'PROJ'
		aCheckedFields[12] = 'SUMMA'
		aCheckedFields[13] = 'VALUUTA'
		aCheckedFields[14] = 'KUURS'
		aCheckedFields[15] = 'LAUSNR'

		lError = check_fields_in_cursor(@aCheckedFields, 'v_mk1')

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
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_mk')
		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_mk1')

		If 	!lError Or !Used('v_mk') Or Reccount('v_mk1') = 0 Or !Used('v_mk1') Or Reccount('v_mk1') = 0 
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
	Dimension aCheckedFields(9)
	aCheckedFields[1] = 'NUMBER'
	aCheckedFields[2] = 'KPV'
	aCheckedFields[3] = 'NIMETUS'
	aCheckedFields[4] = 'VALUUTA'
	aCheckedFields[5] = 'DEEBET'
	aCheckedFields[6] = 'KREEDIT'
	aCheckedFields[7] = 'AA'
	aCheckedFields[8] = 'KOOD'
	aCheckedFields[9] = 'OPT'

	cursorName  = 'tmpMk'

	Local lcWhere
	tdKpv1 = DATE(2016,01,01)
	tdKpv2 = DATE()
	tnSumma1 = -9999
	tnSumma2 = 9999
	
TEXT TO lcWhere NOSHOW textmerge
	kpv >= ?tdKpv1 and kpv <= ?tdKpv2
	and deebet >= ?tnSumma1 and kreedit <= ?tnSumma2

ENDTEXT

	lcSubTotals = " sum (deebet) OVER()  as deebet_kokku , sum(kreedit) over() as kreedit_kokku, count(id) over() as read_kokku"

	lcAlias = 'curMK'
* parameters
	lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', cursorName, lcWhere, lcSubTotals)

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
