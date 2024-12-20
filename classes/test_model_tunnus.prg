SET CLASSLIB TO classes\classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = createobject('db')

model = 'libs\library\tunnus'
alias = 'curTunnus'

tnId = 1
tnUserId = 1

gnHandle = SQLCONNECT('localPg')
IF gnHandle < 0
	MESSAGEBOX('Connection error',0+48,'Error')
	RETURN .t.
ENDIF

WAIT WINDOW 'test model ' + model + ', ' + alias TIMEOUT 1
lsuccess = test_of_Sql()

=SQLDISCONNECT(gnHandle)


FUNCTION test_of_Sql
	
WITH oDb
	* parameters
	lcParams = 'gRekv, tnUser'
	gRekv = 1
	tnUser = 1
	lError = .readFromModel(model, alias, lcParams, alias)
	IF 	!lError 
		MESSAGEBOX('test failed',0 + 48,'Error')
		RETURN .f.
	ELSE 
		* success
		SELECT curTunnus
		brow
		WAIT WINDOW 'test model ' + model + ', ' + alias + ' -> passed' TIMEOUT 3
		USE
		RETURN .t.
	ENDIF
	
	
ENDWITH


endfunc
