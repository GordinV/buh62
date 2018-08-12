Parameter cWhere
local lnrecno
lnRecno = 0
tcKood = ltrim(rtrim(fltrKontod.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrKontod.nimetus))+'%'
oDb.use('printkontod')


l_cursor = 'curKontod'
l_output_cursor = 'konto_report1'

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
