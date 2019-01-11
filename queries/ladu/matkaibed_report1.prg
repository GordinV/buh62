Parameter cWhere

TEXT TO l_where
	grupp ilike '% <<ALLTRIM(fltrAruanne.grupp)>> %'
ENDTEXT

lError = oDb.readFromModel('aruanned\ladu\materialide_kaibed', 'materialide_kaibed_aruanne', 'fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv, fltrAruanne.ladu_id, fltrAruanne.vara_id', 'tmpReport')
If !lError
	Messagebox('Viga',0+16, 'Eelarve tulud')
	Set Step On
	Select 0
	Return .F.
Endif

Select * ;
	from tmpReport ;
	ORDER By ladu_kood, grupp, kood ;
	INTO Cursor matkaibed_report1

Use In tmpReport
Select matkaibed_report1

