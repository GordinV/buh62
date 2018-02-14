SET CLASSLIB TO classes\classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = createobject('db')

gRekv = 1
guserid = 1
tnId = 0

gnHandle = SQLCONNECT('localPg', 'vlad','123')
IF gnHandle < 0
	MESSAGEBOX('Connection error',0+48,'Error')
	RETURN .t.
ENDIF

lcModel = 'libs\libraries\asutused'

WAIT WINDOW 'test model ' + lcModel  TIMEOUT 1
lsuccess = test_of_grid_model()
IF lsuccess 
	lsuccess = test_of_row_new_model()
ENDIF
IF lsuccess 
	lsuccess = test_of_row_validate_model()
ENDIF
IF lsuccess 
	lsuccess = test_of_row_save_model()
ENDIF

IF lsuccess 
	lsuccess = test_of_row_model()
ENDIF

IF lsuccess 
	lsuccess = test_of_row_delete_model()
ENDIF

IF lsuccess 
	lsuccess = test_of_selectAsLibs_model()
ENDIF

=SQLDISCONNECT(gnHandle)
clear all


FUNCTION test_of_selectAsLibs_model
	Dimension aCheckedFields(1)
	aCheckedFields[1] = 'TP'
			
WITH oDb
	lcAlias = 'selectAsLibs'
	* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', 'comAsutusRemote')

	IF 	!lError AND USED('comAsutusRemote') AND RECCOUNT('comAsutusRemote') > 0
		MESSAGEBOX('test failed',0 + 48,'Error')
		RETURN .f.
		
	ENDIF
	
	lError = check_fields_in_cursor(@aCheckedFields, 'comAsutusRemote')

	IF lError
		* success
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' TIMEOUT 1
		USE IN comAsutusRemote
	ENDIF
	RETURN lError
	

ENDWITH


endfunc


FUNCTION test_of_row_validate_model()
lcAlias = 'validate' 
SELECT v_model
LOCATE FOR !EMPTY(validate)

IF EOF()
* not found
	RETURN .t.
ENDIF

lcValidate = ALLTRIM(v_model.validate)
	lcNotValidFields = oDb.validate(lcValidate, 'v_asutus')
	* expect LIBRARY
	IF TYPE('lcNotValidFields') = 'C' 
		replace id WITH 0, regkood WITH '1234__test' + ALLTRIM(STR(RAND() * 10000)), nimetus WITH 'vfp test', omvorm WITH 'AS', kehtivus WITH DATE() IN v_asutus
	ENDIF
	
	lcNotValidFields = oDb.validate(lcValidate, 'v_asutus')
	* expect empty
	IF EMPTY(lcNotValidFields)
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + ' validate -> passed' TIMEOUT 1
		RETURN .t.
	ELSE
		MESSAGEBOX('test failed',0 + 48,'Error')
		SET STEP ON 
		RETURN .f.
	
	ENDIF

ENDFUNC


FUNCTION test_of_row_delete_model
	
WITH oDb
	lcAlias = 'deleteDoc'	
	* parameters
		
	lError = oDb.readFromModel(lcModel, lcAlias, 'gUserid,tnId','result')

	IF 	!lError or !USED('result') or !ISNULL(result.error_code)
			MESSAGEBOX('test failed',0 + 48,'Error')
		SET STEP ON 
		RETURN .f.
	ELSE 
		* success
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + ' delete -> passed' TIMEOUT 1
		SELECT result
		RETURN .t.
	ENDIF
	

ENDWITH


FUNCTION test_of_row_save_model
	
WITH oDb
	lcAlias = 'saveDoc'	
	* parameters
	* cursor v_tunnus -> json
	SELECT v_asutus
	lcJson = '{"id":' + ALLTRIM(STR(v_asutus.id)) + ',"data":'+ oDb.getJson() + '}'
	lError = oDb.readFromModel(lcModel, lcAlias, 'lcJson,gUserid,gRekv', 'v_asutus')

	IF 	!lError AND USED('v_asutus') AND RECCOUNT('v_asutus') > 0
		MESSAGEBOX('test failed',0 + 48,'Error')
		SET STEP ON 
		RETURN .f.
	ELSE 
		* success
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' TIMEOUT 1
		SELECT v_asutus
		tnId = v_asutus.id
		RETURN .t.
	ENDIF
	

ENDWITH



FUNCTION test_of_row_new_model
tnId = 0
	
WITH oDb
	lcAlias = 'row'
	* parameters
		CREATE CURSOR v_asutus (id int, regkood c(20) null, nimetus c(254) null,omvorm c(20) null, muud m null, kehtivus date null)
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_asutus')

	IF 	!lError AND USED('v_asutus') AND RECCOUNT('v_asutus') > 0
		MESSAGEBOX('test failed',0 + 48,'Error')
		RETURN .f.
	ELSE 
		* success
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' TIMEOUT 1
		RETURN .t.
	ENDIF
	

ENDWITH


FUNCTION test_of_row_model
		
WITH oDb
	lcAlias = 'row'
	* parameters
		CREATE CURSOR v_asutus (id int, regkood c(20), nimetus c(254), omvorm c(20), muud m null)
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_asutus')

	IF 	!lError AND USED('v_asutus') AND RECCOUNT('v_asutus') > 0
		MESSAGEBOX('test failed',0 + 48,'Error')
		RETURN .f.
	ELSE 
		* success
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' TIMEOUT 1
		USE IN v_asutus
		RETURN .t.
	ENDIF
	

ENDWITH


endfunc

FUNCTION test_of_grid_model
WITH oDb
	LOCAL lcWhere
	lcWhere = "regkood ilike 'test%'"
	lcAlias = 'curAsutused'
	* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', 'tmp', lcWhere)

	IF 	!lError OR !USED('tmp')
		MESSAGEBOX('test failed',0 + 48,'Error')
		RETURN .f.
	ELSE 
		* success
		WAIT WINDOW 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' TIMEOUT 3
		USE IN tmp
		RETURN .t.
	ENDIF
ENDWITH
endfunc



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
