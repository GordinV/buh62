Parameter cWhere

If !USED('v_pv_kaart') OR !USED('v_pv_oper')
	SELECT 0
	Return .f.
ENDIF

Create cursor pvoper_report1 (pvkood c(20) DEFAULT v_pv_kaart.kood, pvnimetus c(120) DEFAULT v_pv_kaart.nimetus,; 
	soetmaks y DEFAULT v_pv_kaart.soetmaks, jaak y DEFAULT v_pv_kaart.jaak, kulum y DEFAULT v_pv_kaart.kulum,;
	kood c(20), nimetus c(254), kpv d, summa y, liik c(40))
Select v_pv_oper
Scan
	cLiik = ''
	do case
		case v_pv_oper.liik = 1
			cLiik = 'PAIGUTUS'
		case v_pv_oper.liik = 2
			cLiik = 'KULUM'
		case v_pv_oper.liik = 3
			cLiik = 'PARANDAMINE (PLUUS)'
		case v_pv_oper.liik = 4
			cLiik = 'PARANDAMINE (MINUUS)'
		case v_pv_oper.liik = 5
			cLiik = 'MAHAKANDMINE'
	endcase
	select pvoper_report1
	Append blank
	Replace kood with v_pv_oper.kood,;
		nimetus with v_pv_oper.nimetus,;
		summa with v_pv_oper.summa,;
		kpv with v_pv_oper.kpv,;
		liik with cLiik in pvoper_report1
Endscan

Select pvoper_report1
