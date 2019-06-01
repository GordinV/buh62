Parameter tcWhere

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(konto,'') like '<<ALLTRIM(fltrAruanne.konto)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.tegev)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.allikas)>>%'
	and coalesce(rahavoo,'') like '<<ALLTRIM(fltrAruanne.rahavoog)>>%'
	and coalesce(tp,'') like '<<ALLTRIM(fltrAruanne.tp)>>%'
	and coalesce(asutus,'') like '<<IIF(!EMPTY(fltrAruanne.asutusId),ALLTRIM(comRekvAruanne.nimetus),'')>>%'
ENDTEXT

l_aasta = year(fltrAruanne.kpv2)
l_kuu = month(fltrAruanne.kpv2)
l_kond = fltrAruanne.kond

lError = oDb.readFromModel('aruanned\eelarve\paring', 'paring_report', 'gRekv,l_aasta,l_kuu, l_kond', 'saldoaruanne_report1', lcWhere)

If !lError
	Messagebox('Viga',0+16, 'Päring')
	Set Step On
	Select 0
	Return .F.
Endif
SELECT saldoaruanne_report1
RETURN .t.