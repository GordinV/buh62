Parameter cWhere

Wait Window 'Päring...' Nowait
lError = oDb.readFromModel('aruanned\eelarve\voetud_kohustused', 'vk_report', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond', 'vk_report1')

If !lError
	Messagebox('Viga',0+16, 'Võetud kohustused')
	Set Step On
	Select 0
	Return .F.
Endif

SELECT vk_report1
