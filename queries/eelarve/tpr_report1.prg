Parameter cWhere

IF !USED('curTpr')
	SELECT 0
	RETURN .f.
ENDIF
SELECT curTpr
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curTpr ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR tpr_report1
ENDTEXT

&lcSql

IF !USED('tpr_report1')
	SELECT 0
	RETURN .f.
ENDIF
SELECT tpr_report1
