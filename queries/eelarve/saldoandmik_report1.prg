 PARAMETER tcWhere
  

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and konto like '<<ALLTRIM(fltrAruanne.kood4)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and (deebet <> 0 or kreedit <> 0)
ENDTEXT

l_kpv1 = fltrAruanne.kpv1
l_kpv2 = fltrAruanne.kpv2
l_kond = IIF(EMPTY(fltrAruanne.kond), null, 1)
l_tunnus = '%'
IF (!EMPTY(fltrAruanne.tunnus))
	l_tunnus = ALLTRIM(fltrAruanne.tunnus) + '%'
ENDIF

lError = oDb.readFromModel('aruanned\eelarve\saldoandmik', 'saldoandmik_report', 'l_kpv2, gRekv, l_kond, l_tunnus', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
ENDIF

SELECT tmpReport

Select konto, tp, tegev, allikas, rahavoog, ;
	sum(deebet) as deebet, sum(kreedit) as kreedit;
	from tmpReport ;
	WHERE (deebet <> 0 OR kreedit <> 0 );
	GROUP By konto, tp, tegev, allikas, rahavoog ;
	ORDER By konto, tp, tegev, allikas, rahavoog ;
	INTO Cursor saldoaruanne_report1

Use In tmpReport
Select saldoaruanne_report1