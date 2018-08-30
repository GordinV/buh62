Parameter cWhere


lcWhere = ''
lcWhere = Iif(Empty(fltrAruanne.kond),' rekv_id = ' + Str(gRekv), '')


lError = oDb.readFromModel('aruanned\raamatupidamine\pearaamat', 'pearaamat_report', 'alltrim(fltrAruanne.konto), fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Pearaamat')
	Set Step On
	Select 0
	Return .F.
Endif

Select (alg_saldo) As alg_saldo, (deebet) As deebet, (kreedit) As kreedit, (lopp_saldo) As lopp_saldo,;
	LEFT(konto,Iif(Left(konto, 6) = '100100', 6,Len(Alltrim(konto)) - Round(Len(Alltrim(konto))/2,0))) As pohikonto,;
	konto, korr_konto ;
	FROM tmpReport ;
	INTO Cursor qryReport

Select Sum(alg_saldo) As alg_saldo, Sum(deebet) As deebet, Sum(kreedit) As kreedit, Sum(lopp_saldo) As lopp_saldo,;
	pohikonto, 	konto, korr_konto ;
	FROM qryReport ;
	group By pohikonto, konto, korr_konto ;
	order By pohikonto, konto, korr_konto ;
	INTO Cursor pearaamat_report1

Use In 	qryReport
Use In 	tmpReport

Select pearaamat_report1
