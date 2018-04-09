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

lcModel = 'palk\palk_config'

Wait Window 'test model ' + lcModel  Timeout 1

lsuccess = test_of_row_new_model()

If lsuccess
	lsuccess = test_of_row_save_model()
Endif

If lsuccess
	lsuccess = test_of_row_model()
Endif


=SQLDISCONNECT(gnHandle)
RETURN lsuccess

Clear All


Function test_of_row_save_model

	With oDb
		lcAlias = 'saveDoc'
* parameters
* cursor v_tunnus -> json

		Select v_palk_config
		lcJson = '{"id":' + Alltrim(Str(v_palk_config.Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_palk_config_id')

		If 	!lError or !Used('v_palk_config_id') or Reccount('v_palk_config_id') = 0 or Empty(v_palk_config_id.Id)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed' + Str(v_palk_config_id.Id) Timeout 1
			Select v_palk_config_id
			tnId = v_palk_config_id.Id
			Use In v_palk_config_id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 1
	Dimension aCheckedFields(1)
	aCheckedFields[1] = 'REKVID'
	
	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_palk_config')

		If 	!lError OR  !Used('v_palk_config') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		ENDIF
		
		IF Reccount('v_palk_config') = 0
			tnId = 0
			lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_palk_config')
		ENDIF
		
		If 	!lError OR  !Used('v_palk_config') 
			Messagebox('test failed',0 + 48,'Error')
			Return .F.		
		ENDIF
		
		
		lError = check_fields_in_cursor(@aCheckedFields, 'v_palk_config') 


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
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_palk_config')

		If 	!lError or !Used('v_palk_config') or Reccount('v_palk_config') = 0 or Empty(v_palk_config.Id)
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
