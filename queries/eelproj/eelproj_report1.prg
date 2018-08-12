*!*	Parameter cWhere
*!*	If isdigit(alltrim(cWhere))
*!*		cWhere = val(alltrim(cWhere))
*!*	Endif

*!*	if used ('v_eelproj')
*!*		select *, left(IIF(staatus = 0,'Anulleritud',iif(staatus = 1,'Aktiivne','Kinnitatud')),20) as status from  v_eelproj into cursor eelproj_report1
*!*		
*!*		select eelproj_report1
*!*		
*!*	endif


Parameter cWhere

l_cursor = 'curEelProj'
l_output_cursor = 'eelproj_report1'

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_cursor)
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT *, left(IIF((ISNULL(status) OR EMPTY(status)) ,'Anulleritud',iif(status = 1,'Aktiivne','Kinnitatud')),20) as status from <<l_cursor>> ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR <<l_output_cursor>>
ENDTEXT

&lcSql

IF !USED(l_output_cursor)
	SELECT 0
	RETURN .f.
ENDIF
SELECT (l_output_cursor)
