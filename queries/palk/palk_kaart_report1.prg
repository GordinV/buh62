Parameters tnid

TEXT TO lcWhere TEXTMERGE noshow
	isik ilike '%<<ALLTRIM(fltrPalkOper.isik)>>%'
ENDTEXT
l_kond = 1
lError = oDb.readFromModel('aruanned\palk\palk_kaart', 'palk_kaart', 'fltrPalkOper.kpv1,fltrPalkOper.kpv2, gRekv, l_kond', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Palgakaart')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT * from tmpReport ORDER BY isik INTO CURSOR palk_kaart_report1
USE IN tmpReport

SELECT palk_kaart_report1
RETURN 