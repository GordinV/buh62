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

lcModel = 'palk\puudumine'


lError = oDb.readFromModel('libs\libraries\palk_lib', 'selectAsLibs', 'gRekv, guserid', 'comPalkLibRemote')
SELECT comPalkLibRemote
GO bottom

lError = oDb.readFromModel('palk\tooleping', 'selectAsLibs', 'gRekv, guserid', 'comToolepingRemote')
SELECT comToolepingRemote
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

=SQLDISCONNECT(gnHandle)
Clear All



Function test_of_row_validate_model()
	lcAlias = 'validate'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)

	lcNotValidFields = oDb.Validate(lcValidate, 'v_puudumine')
* expect LIBRARY
	If Type('lcNotValidFields') = 'C'
		Replace Id With 0, ;
			lepingid WITH comToolepingRemote.id,;
			libid WITH comPalkLibRemote.id,;
			puudumiste_liik WITH 'PUHKUS',;
			tyyp WITH 1,;
			summa WITH 100 IN v_puudumine
			

	Endif

	lcNotValidFields = oDb.Validate(lcValidate, 'v_puudumine')
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

		Select v_puudumine
		lcJson = '{"id":' + Alltrim(Str(v_puudumine.Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_puudumine_id')

		If 	!lError And Used('v_puudumine_id') And Reccount('v_puudumine_id') > 0 And !Empty(v_puudumine_id.Id)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed' + Str(v_puudumine_id.Id) Timeout 1
			Select v_puudumine_id
			tnId = v_puudumine_id.Id
			Use In v_puudumine_id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	Dimension aCheckedFields(4)
	aCheckedFields[1] = 'PARENTID'
	aCheckedFields[2] = 'LEPINGID'
	aCheckedFields[3] = 'LIBID'
	aCheckedFields[4] = 'TYYP'
	
	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_puudumine')

		If 	!lError And Used('v_puudumine') And Reccount('v_puudumine') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		
		lError = check_fields_in_cursor(@aCheckedFields, 'v_puudumine') 


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
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_puudumine')

		If 	!lError And Used('v_puudumine') And Reccount('v_puudumine') > 0 And !Empty(v_puudumine.Id)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		If (lError)
* success
			Wait Window 'test model ' + lcModel + ', row -> passed' Timeout 1
*			Use In v_puudumine
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	With oDb
		Local lcWhere
		lcWhere = "isikukood ilike '%'"
		lcAlias = 'curPuudumine'
* parameters
		lError = oDb.readFromModel(lcModel, 'curPuudumine', 'gRekv, guserid', 'tmp', lcWhere)

		If 	!lError Or !Used('tmp') And Reccount('tmp') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', curPuudumine -> passed' Timeout 3
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
