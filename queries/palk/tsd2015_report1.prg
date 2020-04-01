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


Select Sum(Summa) As arv, ;
	sum(tm) As tm, Sum(sm) As sm, Sum(tki) As tki,  Sum(pm) As pm, Sum(tulubaas) As tulubaas, Sum(tka) As tka, sum(eri_tm) as eri_tm, sum(eri_sm) as eri_sm ;
	from tmpReport ;
	into Cursor qryTsd

Use In tmpReport

lnMaksud = 	qryTsd.tm + qryTsd.sm + qryTsd.tki + qryTsd.tka + qryTsd.pm + qryTsd.eri_tm + qryTsd.eri_sm

Select tsd_report
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('110', 'Kinnipeetud tulumaks',qryTsd.tm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('114', 'Erijuhtude tulumaks',qryTsd.eri_tm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('115', 'Sotsiaalmaks',qryTsd.sm + qryTsd.eri_sm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('116', 'Töötuskindlustusmakse',qryTsd.tki + qryTsd.tka)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('117', 'Kohustusliku kogumispensioni makse',qryTsd.pm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('118', 'Maksukohustus kokku',Iif(lnMaksud >= 0, lnMaksud, 0))
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('119', 'Kuulub tagastamisele',Iif(lnMaksud < 0, lnMaksud, 0))


Select tsd_report
*brow
