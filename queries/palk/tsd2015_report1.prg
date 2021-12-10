Parameter tcWhere

tdKpv1 = fltrAruanne.kpv1
tdKpv2 = fltrAruanne.kpv2
tnKond = Iif(!Empty(fltrAruanne.kond),Null,1)

LOCAL l_lisa1b_110 , l_lisa1b_115, l_lisa1b_117, l_lisa1b_116 
l_lisa1b_110  = 0
l_lisa1b_116  = 0
l_lisa1b_117  = 0
l_lisa1b_115 = 0 

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
ENDIF

lError = oDb.readFromModel('aruanned\palk\tsd_lisa1b', 'tsd_lisa1b', 'tdKpv1,tdKpv2, gRekv,tnKond', 'tsd_1b_report')
If !lError
	Messagebox('Viga',0+16, 'TSD')
	Set Step On
	Select 0
	Return .F.
ENDIF


Select Sum(Summa) As arv, ;
	sum(tm) As tm, ;
	max(sm_kokku ) As sm, ;
	Sum(tki) As tki,  Sum(pm) As pm, Sum(tulubaas) As tulubaas, Sum(tka) As tka, sum(eri_tm) as eri_tm, sum(eri_sm) as eri_sm ;
	from tmpReport ;
	into Cursor qryTsd

Use In tmpReport

SELECT sum(c_1480) as c110, sum(c_1410) as c115, sum(c_1420) as c117, sum(c_1440 + c_1450) as c116 ;
FROM tsd_1b_report ;
INTO CURSOR tsd_1b


if RECCOUNT('tsd_1b') > 0 
	l_lisa1b_110 = tsd_1b.c110
	l_lisa1b_115 = tsd_1b.c115
	l_lisa1b_116 = tsd_1b.c116
	l_lisa1b_117 = tsd_1b.c117
ENDIF

lnMaksud = 	(qryTsd.tm - l_lisa1b_110)+ (qryTsd.sm) + ;
	(qryTsd.tki + qryTsd.tka - l_lisa1b_116) + ;
	(qryTsd.pm - l_lisa1b_117) + qryTsd.eri_tm + qryTsd.eri_sm



Select tsd_report
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('110', 'Kinnipeetud tulumaks',qryTsd.tm - l_lisa1b_110 )
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('114', 'Erijuhtude tulumaks',qryTsd.eri_tm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('115', 'Sotsiaalmaks',qryTsd.sm + qryTsd.eri_sm)
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('116', 'Töötuskindlustusmakse',qryTsd.tki + qryTsd.tka - l_lisa1b_116 )
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('117', 'Kohustusliku kogumispensioni makse',qryTsd.pm - l_lisa1b_117  )
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('118', 'Maksukohustus kokku',Iif(lnMaksud >= 0, lnMaksud, 0))
Insert Into tsd_report (reanr, reanimi, Summa ) Values ('119', 'Kuulub tagastamisele',Iif(lnMaksud < 0, lnMaksud, 0))


Select tsd_report
*brow
