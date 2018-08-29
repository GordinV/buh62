Parameter cWhere

lcWhere = ''
lcWhere = Iif(Empty(fltrAruanne.kond),' rekv_id = ' + Str(gRekv), '')

lError = oDb.readFromModel('aruanned\raamatupidamine\kontoasutusandmik', 'kontoasutusandmik_report',;
	'alltrim(fltrAruanne.konto), fltrAruanne.asutusid, fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)

If !lError
	Messagebox('Viga',0+16, 'Kontoasutus andmik')
	Set Step On
	Select 0
	Return .F.
Endif

Select alg_saldo As algsaldo, lopp_saldo As loppsaldo, deebet, kreedit, NIMETUS, ;
	kpv, regkood, asutus_id as asutusid, asutus, tp, rekv_nimetus, rekv_id, Number, ;
	konto, korr_konto, dok, kood1, kood2, kood3, kood4, kood5, Proj, tunnus ;
	From tmpReport ;
	Order By konto, asutus, rekv_nimetus, kpv ;
	where !Empty (alg_saldo) Or !Empty (deebet) Or !Empty (kreedit) Or !Empty (lopp_saldo);
	into Cursor KontoAsutusAndmik_report1
Use In tmpReport

Select KontoAsutusAndmik_report1
