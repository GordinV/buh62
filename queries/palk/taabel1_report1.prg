Parameter tcWhere

l_cursor = 'curTaabel1'
l_output_cursor = 'taabel1_report1'

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_cursor)
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR <<l_output_cursor>>
ENDTEXT

&lcSql

IF !USED(l_output_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_output_cursor)


