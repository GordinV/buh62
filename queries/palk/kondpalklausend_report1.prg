Parameter tcWhere

l_where = ''

IF !EMPTY(fltrAruanne.OsakondId)
	TEXT TO l_where TEXTMERGE NOSHOW 
		osakondid = <<fltrAruanne.OsakondId>>
	ENDTEXT
ENDIF
 
lError = oDb.readFromModel('aruanned\palk\palk_lausend', 'palk_lausend', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv,fltrAruanne.kond', 'tmpReport', l_where)

If !lError
	Messagebox('Viga',0+16, 'Kondaruanne palk lausend')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT sum(summa) as summa, deebet, kreedit, tegev, allikas, rahavoog, artikkel, tunnus  ;
from tmpReport ;
GROUP BY deebet, kreedit, tegev, allikas, rahavoog, artikkel, tunnus  ;
ORDER BY deebet, kreedit, tegev, allikas, rahavoog, artikkel, tunnus  ;
INTO CURSOR kondpalklausend_report1

USE IN tmpReport 

select kondpalklausend_report1
