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

lcModel = 'libs\libraries\pv_kaart'

If !Used('comPvGruppRemote')
	lError = oDb.readFromModel('libs\libraries\pv_grupp', 'selectAsLibs', 'gRekv, guserid', 'comPvGruppRemote')
	Select comPvGruppRemote
	Go Bottom
Endif


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
	l_cursorName = 'comPvKaartRemote'
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
	cursorName = 'v_library'
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
		Replace Id With 0, rekvid With gRekv, kood With '__test' + Left(Alltrim(Str(Rand() * 10000)),10),;
			nimetus With 'vfp test PV_KAART',;
			gruppid With comPvGruppRemote.Id,;
			kulum With 20,;
			soetmaks With 100,;
			library With 'POHIVARA'
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
		Select(cursorName)
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', cursorName)


		Select(cursorName)
		If 	!lError And Used(cursorName) And Reccount(cursorName) > 0 And Id > 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc -> passed' Timeout 1
			Select(cursorName)
			tnId = Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_library'
	With oDb
		lcAlias = 'row'

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError
			Return .F.
		Endif


		If 	!lError Or !Used(cursorName) Or Reccount(cursorName) = 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
		Endif

		If lError
			lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_pv_oper')
			If !lError  Or !Used('v_pv_oper')
				Return .F.
			Endif

		Endif

		If lError
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' Timeout 1
		Endif

		Return lError
	Endwith


Function test_of_row_model
	Dimension aCheckedFields(17)
	aCheckedFields[1] = 'KONTO'
	aCheckedFields[2] = 'KOOD'
	aCheckedFields[3] = 'NIMETUS'
	aCheckedFields[4] = 'GRUPPID'
	aCheckedFields[5] = 'SOETKPV'
	aCheckedFields[6] = 'KULUM'
	aCheckedFields[7] = 'ALGKULUM'
	aCheckedFields[8] = 'SOETMAKS'
	aCheckedFields[9] = 'PARHIND'
	aCheckedFields[10] = 'JAAK'
	aCheckedFields[11] = 'VASTISIKID'
	aCheckedFields[12] = 'SELG'
	aCheckedFields[13] = 'LIIK'
	aCheckedFields[14] = 'RENTNIK'
	aCheckedFields[15] = 'MAHAKANTUD'
	aCheckedFields[16] = 'VALUUTA'
	aCheckedFields[17] = 'KUURS'

	With oDb
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)

		If 	!lError And Used(cursorName) And Reccount(cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		
		lError = check_fields_in_cursor(@aCheckedFields, cursorName) 


		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_pv_oper')

		If 	!lError And Used('v_pv_oper') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif


* success


		If lError
			Wait Window 'test model ' + lcModel + ', row -> passed' Timeout 1
		Endif

		Return lError
	Endwith


Endfunc

Function test_of_grid_model
	Local cursorName
	cursorName  = 'tmpPohivara'

	Dimension aCheckedFields(1)
	aCheckedFields[1] = 'STATUS'


	With oDb
		Local lcWhere
		lcWhere = "kood ilike 'test%'"
* parameters
		lError = oDb.readFromModel(lcModel, 'curPohivara', 'gRekv, guserid', cursorName, lcWhere)

		If 	!lError Or !Used(cursorName)
			Messagebox('test failed',0 + 48,'Error')
		Endif

		lnFields = Afields(laFields,cursorName)

		For i = 1 To Alen(aCheckedFields)
			lnElement = Ascan(laFields, aCheckedFields[i])

			If lnElement = 0
				Messagebox('test failed, puudub field ' + aCheckedFields[i],0 + 48,'Error')
				lError = .F.
				Exit
			Endif
		Endfor


		If lError
* success
			Wait Window 'test model ' + lcModel + ', curPohivara -> passed' Timeout 3
			Use In (cursorName)
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