Parameter nId
cOmaPank = ''
If Vartype (nId) = 'C'
	tnId = Val(Alltrim(nId))
Endif

Create Cursor mk_report1 (Id Int, kpv d, asutus c(254), maksepaev d, Number c(20),;
	omapank c(120), ;
	omaarve c(20),;
	pank c(3), aa c(20),;
	selg m, nimetus c(254), viitenr c(120),kokku Y, Summa Y, fin c(20), tulu c(20),regkood c(11),;
	kulu c(20), tegev c(20), eelallikas c(20), panknimi c(120), lausnr i, lausend c(254))


l_model = 'raamatupidamine\smk'

If Used ('curMk') And !Used('v_mk')
	If curMk.opt = 1
		l_model = 'raamatupidamine\vmk'
	Else
		l_model = 'raamatupidamine\smk'
	Endif
Else
	If v_mk.opt = 1 Then
		l_model = 'raamatupidamine\vmk'
	Else
		l_model = 'raamatupidamine\smk'
	Endif

Endif



lError = oDb.readFromModel(l_model , 'row', 'tnId, guserid', 'qryMK')

If !lError
	Set Step On
	Return .F.
Endif

lError = oDb.readFromModel(l_model , 'details', 'tnId, guserid', 'qryMk1')

If !lError
	Set Step On
	Return .F.
ENDIF

	* omapank
l_pank_code = Substr(qryMk.omaarve, 5, 2)
l_omapank = get_pank(l_pank_code )	

l_kokku = 0
Select qryMk1
Scan
	l_pank = 'AS SEB Pank'
	l_pank_code = Substr(qryMk1.aa, 5, 2)
	l_pank = get_pank(l_pank_code )
	
	Insert Into mk_report1 (Id, kpv, asutus, maksepaev, Number, aa, selg, viitenr, Summa, panknimi, omapank, omaarve, lausnr, lausend, nimetus);
		values (qryMk.Id, qryMk.kpv, qryMk1.asutus, qryMk.maksepaev, qryMk.Number,qryMk1.aa, qryMk.selg,;
		qryMk.viitenr, qryMk1.Summa, l_pank, l_omapank , qryMk.omaarve, qryMk1.lausnr, qryMk1.lausend, qryMk1.nimetus )
		
	l_kokku  = l_kokku + qryMk1.Summa
ENDSCAN

UPDATE mk_report1 SET kokku = l_kokku   

Use In qryMk1
Use In qryMk
Select mk_report1
GO top

FUNCTION get_pank
LPARAMETERS l_pank_code
	Do Case
		Case l_pank_code = '10'
			l_pank = 'AS SEB Pank'
		Case l_pank_code = '42'
			l_pank = 'Coop Pank AS'
		Case l_pank_code = '16'
			l_pank = 'Eesti Pank'
		Case l_pank_code = '22'
			l_pank = 'Swedpank AS'
		Case l_pank_code = '96' Or  l_pank_code = '17'
			l_pank = 'Luminor Bank AS'
		Case l_pank_code = '12'
			l_pank = 'AS Citadele banka Eesti filiaal'
		Case l_pank_code = '83'
			l_pank = 'Svenska Handelsbanken AB Eesti filiaal'
		Case l_pank_code = '00'
			l_pank = 'AS TBB pank'
		Case l_pank_code = '51'
			l_pank = 'OP Corporate Bank plc Eesti filiaal'
		Case l_pank_code = '77'
			l_pank = 'LHV Pank AS'
		Case l_pank_code = '75'
			l_pank = 'Bigbank AS'
		Otherwise
			l_pank = ''
	Endcase
RETURN l_pank


