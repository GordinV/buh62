Parameter cWhere
IF !USED('curReklluba')
	SELECT 0
	RETURN .f.
ENDIF

SELECT * from curReklluba INTO CURSOR load_report1
