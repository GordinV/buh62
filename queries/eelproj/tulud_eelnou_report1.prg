Parameter cWhere

Wait Window 'Päring...' Nowait
lError = oDb.readFromModel('aruanned\eelarve\tulud_eelnou', 'tulud_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond', 'tulud_eelnou_report1')

If !lError
	Messagebox('Viga',0+16, 'Tulud eelarve eelnõu')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT tulud_eelnou_report1
