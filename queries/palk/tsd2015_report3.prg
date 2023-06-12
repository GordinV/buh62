Parameter tcWhere
* TSD 2015 lisa 1b

tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnKond = fltrAruanne.kond
SET STEP ON
lError = oDb.readFromModel('aruanned\palk\tsd_lisa1b', 'tsd_lisa1b', 'tdKpv1,tdKpv2, gRekv,tnKond', 'tsd_report')
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT tsd_report
