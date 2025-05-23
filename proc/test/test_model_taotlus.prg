Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_taotlus'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'eelarve\taotlus'

* avame pusiandmed
lError = oDb.readFromModel('libs\libraries\artikkel', 'selectAsLibs', 'gRekv, guserid', 'comArtikkelRemote')

Select comArtikkelRemote
Go Bottom

lError = oDb.readFromModel('libs\libraries\allikas', 'selectAsLibs', 'gRekv, guserid', 'comAllikadRemote')

Select comAllikadRemote
Go Bottom

lError = oDb.readFromModel('libs\libraries\tegev', 'selectAsLibs', 'gRekv, guserid', 'comTegevusRemote')

Select comTegevusRemote
Go Bottom

lError = oDb.readFromModel('libs\libraries\rahavoog', 'selectAsLibs', 'gRekv, guserid', 'comRahavoogRemote')

Select comRahavoogRemote
Go Bottom


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
Set Step On
If lsuccess
	lsuccess = test_of_taotluse_allkiri()
Endif

If lsuccess
	lsuccess = test_of_taotluse_esita()
ENDIF

If lsuccess
	lsuccess = test_of_taotluse_aktsepteeri()
Endif

If lsuccess
	lsuccess = test_of_row_delete_model()
Endif


=SQLDISCONNECT(gnHandle)

Return lsuccess

Function test_of_taotluse_aktsepteeri

	lcJson = '{"doc_id":' + Alltrim(Str(tnId)) + ', "muud":"test eelarve.sp_taotlus_aktsepteeri"}'
	lcTask = 'eelarve.sp_taotlus_aktsepteeri'
	lError = oDb.readFromModel(lcModel, 'executeTask', 'guserid,lcJson,lcTask', 'tmpTaotlusTask')

	If !lError Or !Used('tmpTaotlusTask') Or tmpTaotlusTask.result = 0
		Messagebox('test test_of_taotluse_esita failed '  ,0 + 48,'Error')
		Set Step On
		Return .F.
	Endif
	Use In tmpTaotlusTask
	
	* kontrollime kas eelarve koostatud ja eelproj oli kinnitatud
	
	lError = oDb.readFromModel(lcModel, 'details', 'tnId,guserid', 'v_taotlus1')
	
	LOCATE FOR ISNULL(eelarveId) OR eelarveId = 0
	
	IF FOUND() 
		* eelarve read ei ole koostatud,
		tnId = v_taotlus.eelprojid
		lError = oDb.readFromModel('eelarve\eelproj', 'row', 'tnId,guserid', 'v_eelproj')
		
		IF !lError
			MESSAGEBOX('Viga')
			SET STEP ON 
			RETURN .f.
		ENDIF
		
		
		IF v_eelproj.status < 2 
			* projekt ei oli kinnitatud
			lError = oDb.readFromModel('eelarve\eelproj', 'row', 'tnId,guserid', 'v_eelproj')
			
		ENDIF
		
		
	ENDIF
	

	
	Return .T.

Endfunc


Function test_of_taotluse_esita
	lcJson = '{"doc_id":' + Alltrim(Str(tnId)) + '}'
	lcTask = 'eelarve.sp_taotlus_esita'
	lError = oDb.readFromModel(lcModel, 'executeTask', 'guserid,lcJson,lcTask', 'tmpTaotlusTask')

	If !lError Or !Used('tmpTaotlusTask') Or tmpTaotlusTask.result = 0
		Messagebox('test test_of_taotluse_esita failed '  ,0 + 48,'Error')
		Set Step On
		Return .F.
	Endif
	Use In tmpTaotlusTask
	Return .T.

Endfunc


Function test_of_taotluse_allkiri
	lcJson = '{"doc_id":' + Alltrim(Str(tnId)) + '}'
	lcTask = 'eelarve.sp_taotlus_allkiri'
	lError = oDb.readFromModel(lcModel, 'executeTask', 'guserid,lcJson,lcTask', 'tmpTaotlusTask')

	If !lError Or !Used('tmpTaotlusTask') Or tmpTaotlusTask.result = 0
		Messagebox('test test_of_taotluse_allkiri failed '  ,0 + 48,'Error')
		Set Step On
		Return .F.
	Endif
	Use In tmpTaotlusTask

* tuhistame
*	lcJson = '{"doc_id":' + Alltrim(Str(tnId)) + '}'
TEXT TO lcJson TEXTMERGE NOSHOW
				{"doc_id":<<Alltrim(Str(tnId))>>,"muud":"test","liik":"ALLKIRI"}
ENDTEXT

	lcTask = 'eelarve.sp_taotlus_tuhista'
	lError = oDb.readFromModel(lcModel, 'executeTask', 'guserid,lcJson,lcTask', 'tmpTaotlusTask')

	If lError
* check allkiri
		lError = oDb.readFromModel(lcModel, 'row', 'tnId,guserid', 'v_taotlus')
		If v_taotlus.allkiri = 1
			Messagebox('test test_of_taotluse_allkiri tuhistamine failed '  ,0 + 48,'Error')
			Set Step On
			Return .F.
		Endif
	Endif

	lcJson = '{"doc_id":' + Alltrim(Str(tnId)) + '}'

	lcTask = 'eelarve.sp_taotlus_allkiri'
	lError = oDb.readFromModel(lcModel, 'executeTask', 'guserid,lcJson,lcTask', 'tmpTaotlusTask')


	Return .T.

Endfunc



Function test_of_row_validate_model()
	lcAlias = 'validate'
	cursorName = 'v_taotlus'
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
		Select v_taotlus
		Replace Id With 0, rekvid With gRekv, ;
			aasta With 2018, kuu With 0,;
			Summa With 100, kpv With Date()


		Select v_taotlus1
		Insert Into v_taotlus1 (Summa,  kood1, kood2, kood5, selg) Values ;
			(100, comTegevusRemote.kood, comAllikadRemote.kood, comArtikkelRemote.kood, 'test')

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
		lcJson = ''
		lcAlias = 'saveDoc'
* parameters

		Select v_taotlus1
		Go Top
		lcJson = '"gridData":['+ oDb.getJson() + ']'

		Select v_taotlus
		lcJson = '{"id":' + Alltrim(Str(Id)) + ',"data": '+ oDb.getJson(lcJson) + '}'
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_taotlus_id')

		If 	!lError And Used('v_taotlus') And Reccount('v_taotlus') > 0 And v_taotlus_id.Id < 1
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Select(cursorName)
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed,' + Alltrim(Str(v_taotlus_id.Id)) Timeout 1
			Select v_taotlus
			tnId = v_taotlus_id.Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0
	cursorName = 'v_taotlus'
	With oDb
		lcAlias = 'row'

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', cursorName)
		If !lError Or !Used(cursorName) Or Reccount(cursorName) = 0
			Return .F.
		Endif

		Dimension aCheckedFields(5)
		aCheckedFields[1] = 'NUMBER'
		aCheckedFields[2] = 'KPV'
		aCheckedFields[3] = 'REKVID'
		aCheckedFields[4] = 'MUUD'
		aCheckedFields[5] = 'SUMMA'

		lError = check_fields_in_cursor(@aCheckedFields, cursorName)

		If !lError
			Return .F.
		Endif

* details

		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_taotlus1')

		If !lError Or !Used('v_taotlus1') Or !Used('v_taotlus1')
			lError = .F.
		Endif

		Dimension aCheckedFields(9)
		aCheckedFields[1] = 'KOOD4'
		aCheckedFields[2] = 'SUMMA'
		aCheckedFields[3] = 'TUNNUS'
		aCheckedFields[4] = 'PROJ'
		aCheckedFields[5] = 'KOOD1'
		aCheckedFields[6] = 'KOOD2'
		aCheckedFields[7] = 'KOOD3'
		aCheckedFields[8] = 'KOOD5'

		lError = check_fields_in_cursor(@aCheckedFields, 'v_taotlus1')

		If !lError
			Return .F.
		Endif

		If 	!lError  Or Reccount(cursorName) = 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ',  row new -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Function test_of_row_model

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_taotlus')
		lError = oDb.readFromModel(lcModel, 'details', 'tnId, guserid', 'v_taotlus1')

		Select v_taotlus1

		If 	!lError Or !Used('v_taotlus') Or Reccount('v_taotlus1') = 0 Or !Used('v_taotlus1') Or Reccount('v_taotlus1') = 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', row -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	Local cursorName
	Dimension aCheckedFields(9)
	aCheckedFields[1] = 'NUMBER'
	aCheckedFields[2] = 'KPV'
	aCheckedFields[3] = 'KOOD2'
	aCheckedFields[4] = 'NIMETUS'
	aCheckedFields[5] = 'SUMMA'
	aCheckedFields[6] = 'AMETNIK'
	aCheckedFields[7] = 'KOOD5'
	aCheckedFields[8] = 'KOOD1'
	aCheckedFields[9] = 'KOOSTAJAID'

	cursorName  = 'tmpTaotlus'

	Local lcWhere
	tnSumma1 = -9999
	tnSumma2 = 9999

TEXT TO lcWhere NOSHOW textmerge
	summa >= ?tnSumma1 and summa <= ?tnSumma2

ENDTEXT

	lcSubTotals = " sum (summa) OVER()  as summa_kokku, count(id) over() as read_kokku"

	lcAlias = 'curTaotlus'
* parameters
	lError = oDb.readFromModel(lcModel, 'curTaotlus', 'gRekv, guserid', cursorName, lcWhere, lcSubTotals)

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
