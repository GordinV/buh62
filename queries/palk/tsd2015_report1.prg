Parameter tcWhere

tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnKond = Iif(!Empty(fltrAruanne.kond),Null,1)

Create Cursor tsd_report (aasta Int Default Year(fltrAruanne.kpv2), kuu Int Default Month(fltrAruanne.kpv2),;
	parandus Int Default 0, pohjus c(50), tm N(14,2) Default 0, tm_eri N(14,2) Default 0, sm N(14,2) Default 0,;
	tk N(14,2) Default 0, pm N(14,2) Default 0, tagastus N(14,2) Default 0,;
	reanr c(20), reanimi c(254), Summa N(14,2) Default 0)

l_where = 'summa is not null'

lError = oDb.readFromModel('aruanned\palk\tsd_lisa1', 'tsd_lisa1', 'tdKpv1,tdKpv2, gRekv,tnKond', 'tmpReport', l_where)
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
Endif

*!*	Select isikukood, isik, Sum(Summa) As Summa, Sum(puhkused) As puhkused, Sum(haigused) As haigused, Sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki, Sum(tka) As tka,;
*!*		sum(pm) As pm, Sum(tulubaas) As tulubaas, tululiik, '' as riik, sm_arv, tk_arv, ;
*!*		max(v1040) As v1040, Sum(puhkus) As puhkus, Max(lopp) As lopp, Max(tmpReport.arv_min_sots) As arv_min_sots, ;
*!*		max(tmpReport.min_sots_alus) As min_sots_alus;
*!*		FROM tmpReport ;
*!*		WHERE (!Isnull(tmpReport.tululiik) And  tmpReport.tululiik <> '') ;
*!*		GROUP By isikukood, isik, tululiik, riik, sm_arv, tk_arv ;
*!*		ORDER By isikukood, tululiik;
*!*		INTO Cursor curTSD
*!*	Select curTSD


Select Sum(Summa) As arv, ;
	sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki,  Sum(pm) As pm, Sum(tulubaas) As tulubaas, Sum(tka) As tka ;
	from tmpReport ;
	into Cursor qryTsd

Use In tmpReport

lnMaksud = 	qryTsd.tm + qryTsd.sm + qryTsd.tki + qryTsd.tka + qryTsd.pm

Select tsd_report
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('110', 'Kinnipeetud tulumaks',qryTsd.arv)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('114', 'Erijuhtude tulumaks',qryTsd.tm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('115', 'Sotsiaalmaks',qryTsd.sm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('116', 'Töötuskindlustusmakse',qryTsd.tki + qryTsd.tka)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('117', 'Kohustusliku kogumispensioni makse',qryTsd.pm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('118', 'Maksukohustus kokku',Iif(lnMaksud >= 0, lnMaksud, 0))
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('119', 'Kuulub tagastamisele',Iif(lnMaksud < 0, lnMaksud, 0))


Select tsd_report
*brow
