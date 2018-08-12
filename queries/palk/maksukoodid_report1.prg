Parameter cWhere

IF !USED('curMaksukoodid')
	SELECT 0
	RETURN .f.
ENDIF
SELECT curMaksukoodid
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curMaksukoodid ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR maksukoodid_report1
ENDTEXT

&lcSql

IF !USED('maksukoodid_report1')
	SELECT 0
	RETURN .f.
ENDIF
SELECT maksukoodid_report1
