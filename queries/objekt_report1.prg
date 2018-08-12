Parameter cWhere
IF !USED('curObjekt')
	SELECT 0
	RETURN .f.
ENDIF

SELECT curObjekt
lcTag = TAG()


TEXT TO lcSql TEXTMERGE NOSHOW 
	SELECT * from curObjekt ORDER BY <<lcTag>> into CURSOR objekt_report1
ENDTEXT

&lcSql


select objekt_report1