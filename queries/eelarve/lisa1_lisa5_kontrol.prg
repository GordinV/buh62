
Wait Window 'Päring...' Nowait
SET STEP on
lError = oDb.readFromModel('aruanned\eelarve\lisa1_lisa5_kontrol', 'lisa1_lisa5_kontrol', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'eelarve_report1')
If !lError
	Messagebox('Viga',0+16, 'Lisa1 - Lisa5 kontrol')
	
	Set Step On
	Select 0
	Return .F.
ENDIF

SELECT eelarve_report1

