Parameter cWhere


IF !USED('curAllikad')
	SELECT 0
	RETURN .f.
ENDIF
SELECT curAllikad
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curAllikad ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR allikas_report1
ENDTEXT

&lcSql

IF !USED('allikas_report1')
	SELECT 0
	RETURN .f.
ENDIF
SELECT allikas_report1
