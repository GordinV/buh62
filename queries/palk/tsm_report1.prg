Parameter tcWhere

TEXT TO l_where TEXTMERGE noshow
	isik ilike '%<<ALLTRIM(fltrPalkOper.isik)>>%'
ENDTEXT


lError = oDb.readFromModel('aruanned\palk\tsm_toend', 'tsm_toend', 'fltrPalkoper.kpv1,fltrPalkoper.kpv2, gRekv', 'tmpReport', l_where)
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT * from tmpReport ORDER BY isik, tululiik INTO CURSOR tsm_report

USE IN tmpReport
SELECT tsm_report
RETURN 