Parameter cWhere
IF !USED('curEttemaksud')
	SELECT 0
	RETURN .f.
ENDIF

SELECT * from curEttemaksud INTO CURSOR ettemaksud_report1
