Local lnError, lTSD, lnTMkokku
lnError = 1

Wait Window 'TSD Lisa 1a päring ...' Nowait
Do queries\palk\tsd2015_report2.fxp
If !Used('tsd_report')
	Select 0
	Return .F.
Endif

Select Distinct isikukood As v1000, nimi As v1010, kas_pensionar, v1020 , v1030, v1040, v1050, v1060, ;
	v1070, v1080, v1090,v1100, v1110,	v1120, v1130, v1140,v1170, ;
	v1160_610,	v1160_620, v1160_630, v1160_640, v1160_650 ;
	from tsd_report ;
	ORDER By isikukood ;
	into Cursor qryTSD

Select Distinct v1020 As kood From tsd_report Into Cursor tmpTululiik

Use In tsd_report

* lisa 1b
Wait Window 'TSD Lisa 1b päring ...' Nowait

Do queries\palk\tsd2015_report3.fxp
If !Used('tsd_report')
	Select 0
	Return .F.
Endif

Select * From tsd_report  Into Cursor tsd_lisa1b

*!*	grekv = 119
*!*	=test()

cFail = 'c:\temp\buh60\EDOK\tsd_lisa1a.xml'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'tsd'+Sys(2015)+'.bak'
If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif
Set Null On


* 110 - kinnipeetud tulumaks
Select Sum(v1170) As v110_tm, Sum(v1100) As v115_sm, Sum(v1130 + v1140) As c116_Tk, Sum(v1110) As c117_Kp ;
	FROM qryTSD Into Cursor tsd_kokku



Set Textmerge On

TEXT TO lcString ADDITIVE NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<tsd_vorm>
<c108_Aasta><<YEAR(fltrAruanne.kpv1)>></c108_Aasta>
<c109_Kuu><<MONTH(fltrAruanne.kpv1)>></c109_Kuu>
<c110_Tm><<round(tsd_kokku.v110_tm,2)>></c110_Tm>
<c115_Sm><<ROUND(tsd_kokku.v115_sm,2)>></c115_Sm>
<c116_Tk><<ROUND(tsd_kokku.c116_Tk,2)>></c116_Tk>
<c117_Kp><<ROUND(tsd_kokku.c117_Kp,2)>></c117_Kp>
<c118_KohustKokku><<round((tsd_kokku.v110_tm + tsd_kokku.v115_sm + tsd_kokku.c116_Tk + tsd_kokku.c117_Kp),2)>></c118_KohustKokku>
<laadimisViis>L</laadimisViis>
<regKood><<ALLTRIM(qryRekv.regkood)>></regKood>
<vorm>TSD</vorm>
<tsd_L1_0>
<aIsikList>

ENDTEXT
* lisa 1
Select qryTSD

Select Distinct v1000, v1010 From qryTSD Into Cursor tmpIsikList
Select tmpIsikList

Scan

TEXT TO lcString NOSHOW ADDITIVE

<tsd_L1_A_Isik>
<c1000_Kood><<ALLTRIM(tmpIsikList.v1000)>></c1000_Kood>
<c1010_Nimi><<ALLTRIM(convert_to_utf(tmpIsikList.v1010))>></c1010_Nimi>
<vmList>

ENDTEXT
	Select tmpTululiik
	Scan
		lcVMKood = 	get_tululiik_kood(tmpTululiik.kood,tmpIsikList.v1000)
		If !Empty(lcVMKood)
TEXT TO lcString NOSHOW ADDITIVE
<<lcVMKood>>

ENDTEXT
		Endif
	Endscan

TEXT TO lcString NOSHOW ADDITIVE

</vmList>
</tsd_L1_A_Isik>

ENDTEXT
Endscan

Use In tmpTululiik
Use In tmpIsikList

TEXT TO lcString NOSHOW ADDITIVE
</aIsikList>

ENDTEXT

* lisa 1b
If Reccount('tsd_lisa1b') > 0
	Select Distinct tsd_lisa1b.c_1300, tsd_lisa1b.c_1310 ;
		FROM tsd_lisa1b ;
		order By tsd_lisa1b.c_1300 ;
		INTO Cursor tmpIsikud
TEXT TO lcString NOSHOW additive
<bIsikList>

ENDTEXT

	Select tmpIsikud
	Scan
TEXT TO lcString NOSHOW additive
<tsd_L1_B_Isik>
<c1300_Kood><<ALLTRIM(tmpIsikud.c_1300)>></c1300_Kood>
<c1310_Nimi><<ALLTRIM(tmpIsikud.c_1310)>></c1310_Nimi>
<vmList>
ENDTEXT

		Select tsd_lisa1b
		Scan For Alltrim(tsd_lisa1b.c_1300) = Alltrim(tmpIsikud.c_1300)
TEXT TO lcString NOSHOW additive
<tsd_L1_B_Vm>
<c1320_ValiKood><<ALLTRIM(tsd_lisa1b.c_1320)>></c1320_ValiKood>
<c1330_Summa><<ROUND(tsd_lisa1b.c_1330,2)>></c1330_Summa>
<c1340_Aasta><<tsd_lisa1b.c_1340>></c1340_Aasta>
<c1350_Kuu><<tsd_lisa1b.c_1350>></c1350_Kuu>
<c1360_Pohjus><<ALLTRIM(tsd_lisa1b.c_1360)>></c1360_Pohjus>
<c1370_Smvm><<ROUND(tsd_lisa1b.c_1370,2)>></c1370_Smvm>
<c1410_Sm><<ROUND(tsd_lisa1b.c_1410,2)>></c1410_Sm>
<c1420_Kp><<ROUND(tsd_lisa1b.c_1420,2)>></c1420_Kp>
<c1430_Tkvm><<ROUND(tsd_lisa1b.c_1430,2)>></c1430_Tkvm>
<c1440_Tk><<ROUND(tsd_lisa1b.c_1440,2)>></c1440_Tk>
<c1450_Ttk><<ROUND(tsd_lisa1b.c_1450,2)>></c1450_Ttk>

ENDTEXT

			If !Empty(tsd_lisa1b.c_1470)
TEXT TO lcString NOSHOW additive
<mvtList>
<tsd_L1_B_Mvt>
<c1460_TuliKood><<ALLTRIM(tsd_lisa1b.c_1460)>></c1460_TuliKood>
<c1470_Summa><<ROUND(tsd_lisa1b.c_1470,2)>></c1470_Summa>
</tsd_L1_B_Mvt>
</mvtList>
ENDTEXT
			Endif

TEXT TO lcString NOSHOW additive
<c1480_Tm><<tsd_lisa1b.c_1480>></c1480_Tm>

ENDTEXT
		If !Isnull(tsd_lisa1b.pohjus_selg)	And !Empty(tsd_lisa1b.pohjus_selg)
TEXT TO lcString NOSHOW additive
<pohjusSelgitus><<ALLTRIM(tsd_lisa1b.pohjus_selg)>></pohjusSelgitus>

ENDTEXT

		Else
TEXT TO lcString NOSHOW additive
<pohjusSelgitus/>

ENDTEXT

		Endif
TEXT TO lcString NOSHOW additive

</tsd_L1_B_Vm>

ENDTEXT

	Endscan
TEXT TO lcString NOSHOW additive
</vmList>
</tsd_L1_B_Isik>

ENDTEXT
Endscan
TEXT TO lcString NOSHOW additive
</bIsikList>

ENDTEXT



Endif



TEXT TO lcString NOSHOW ADDITIVE
</tsd_L1_0>
</tsd_vorm>
ENDTEXT

*!*	SELECT v_memo
*!*	INSERT INTO v_memo (xml) VALUES (lcString)

*!*	MODIFY MEMO v_memo.xml


lnHandle = Fcreate(cFail)  && If not create it
If lnHandle < 0     && Check for error opening file
	Messagebox(Iif(This.eesti=.T.,'Ei saa kirjutada faili','Íå ìîãó ñîçäàòü ôàéë'),'Kontrol')
	Return .F.
Endif

=Fputs(lnHandle,Alltrim(lcString))
=Fclose(lnHandle)
Wait Window 'Valmis' Nowait

Set Null Off

Return cFail


Function get_tululiik_kood
	Lparameters tcKood, tcIsikukood
	Local lcStr
	lcStr = ''
	lcAlias = Alias()
	Select Distinct * From qryTSD ;
		where v1020 = tcKood ;
		AND v1000 = tcIsikukood;
		INTO Cursor qryTSDtululiik

	Select qryTSDtululiik

	Scan
		lc1160 = ''
*	v1160_610,	v1160_620, v1160_630, v1160_640

		If qryTSDtululiik.v1160_610 + qryTSDtululiik.v1160_620 +  qryTSDtululiik.v1160_630 +  qryTSDtululiik.v1160_640 + qryTSDtululiik.v1160_650 > 0
TEXT TO lc1160 NOSHOW
<mvtList>

ENDTEXT

			If qryTSDtululiik.v1160_610 > 0
			l_liik = '610'
TEXT TO lc1160 NOSHOW ADDITIVE
<tsd_L1_A_Mvt>
<c1150_TuliKood><<l_liik>></c1150_TuliKood>
<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_610),0,qryTSDtululiik.v1160_610)>></c1160_Summa>
</tsd_L1_A_Mvt>

ENDTEXT
			Endif

			If qryTSDtululiik.v1160_620 > 0
TEXT TO lc1160 NOSHOW ADDITIVE

<tsd_L1_A_Mvt>
<c1150_TuliKood>620</c1150_TuliKood>
<c1160_Summa><<ROUND(IIF(ISNULL(qryTSDtululiik.v1160_620),0,qryTSDtululiik.v1160_620),2)>></c1160_Summa>
</tsd_L1_A_Mvt>
ENDTEXT
			Endif
			If qryTSDtululiik.v1160_630 > 0
TEXT TO lc1160 NOSHOW ADDITIVE

<tsd_L1_A_Mvt>
<c1150_TuliKood>630</c1150_TuliKood>
<c1160_Summa><<ROUND(IIF(ISNULL(qryTSDtululiik.v1160_630),0,qryTSDtululiik.v1160_630),2)>></c1160_Summa>
</tsd_L1_A_Mvt>
ENDTEXT
			Endif
			If qryTSDtululiik.v1160_640 > 0
TEXT TO lc1160 NOSHOW ADDITIVE

<tsd_L1_A_Mvt>
<c1150_TuliKood>640</c1150_TuliKood>
<c1160_Summa><<ROUND(IIF(ISNULL(qryTSDtululiik.v1160_640),0,qryTSDtululiik.v1160_640),2)>></c1160_Summa>
</tsd_L1_A_Mvt>
ENDTEXT
			Endif
			If qryTSDtululiik.v1160_650 > 0
TEXT TO lc1160 NOSHOW ADDITIVE

<tsd_L1_A_Mvt>
<c1150_TuliKood>650</c1150_TuliKood>
<c1160_Summa><<ROUND(IIF(ISNULL(qryTSDtululiik.v1160_650),0,qryTSDtululiik.v1160_650),2)>></c1160_Summa>
</tsd_L1_A_Mvt>
ENDTEXT
			Endif

TEXT TO lc1160 NOSHOW ADDITIVE

</mvtList>

ENDTEXT

		Endif

TEXT TO lcStr NOSHOW

<tsd_L1_A_Vm>
<c1020_ValiKood><<ALLTRIM(qryTSDtululiik.v1020)>></c1020_ValiKood>
<c1030_Summa><<ROUND(IIF(ISNULL(qryTSDtululiik.v1030),0,qryTSDtululiik.v1030),2)>></c1030_Summa>

ENDTEXT

		If Val(tcKood) < 13
TEXT TO lcStr NOSHOW ADDITIVE

<c1040_OtMaar><<qryTSDtululiik.v1040>></c1040_OtMaar>

ENDTEXT

		Endif
		If !Empty(qryTSDtululiik.v1050)
TEXT TO lcStr NOSHOW ADDITIVE
<c1050_RiikKood><<ALLTRIM(qryTSDtululiik.v1050)>></c1050_RiikKood>

ENDTEXT
		Endif

TEXT TO lcStr NOSHOW ADDITIVE
<c1060_Smvm><<ROUND(IIF(ISNULL(qryTSDtululiik.v1060),0,qryTSDtululiik.v1060),2)>></c1060_Smvm>
<c1070_TvpVah><<ROUND(IIF(ISNULL(qryTSDtululiik.v1070), 0, qryTSDtululiik.v1070),2)>></c1070_TvpVah>
<c1080_KuumVah><<ROUND(IIF(ISNULL(qryTSDtululiik.v1080), 0, qryTSDtululiik.v1080),2)>></c1080_KuumVah>
<c1090_KuumSuur><<ROUND(IIF(ISNULL(qryTSDtululiik.v1090), 0, qryTSDtululiik.v1090),2)>></c1090_KuumSuur>

ENDTEXT
		If qryTSDtululiik.v1020 <> '24'
TEXT TO lcStr NOSHOW ADDITIVE

<c1100_Sm><<ROUND(IIF(ISNULL(qryTSDtululiik.v1100),0,qryTSDtululiik.v1100),2)>></c1100_Sm>
<c1110_Kp><<ROUND(IIF(ISNULL(qryTSDtululiik.v1110),0,qryTSDtululiik.v1110),2)>></c1110_Kp>
<c1130_Tk><<ROUND(IIF(ISNULL(qryTSDtululiik.v1130),0,qryTSDtululiik.v1130),2)>></c1130_Tk>
<c1140_Ttk><<ROUND(IIF(ISNULL(qryTSDtululiik.v1140),0,qryTSDtululiik.v1140),2)>></c1140_Ttk>
<c1170_Tm><<ROUND(IIF(ISNULL(qryTSDtululiik.v1170),0,qryTSDtululiik.v1170),2)>></c1170_Tm>

ENDTEXT

		Endif

TEXT TO lcStr NOSHOW ADDITIVE

<c1120_Tkvm><<IIF(ISNULL(qryTSDtululiik.v1120),0,qryTSDtululiik.v1120)>></c1120_Tkvm>
<<lc1160>>
</tsd_L1_A_Vm>

ENDTEXT

	Endscan
	Use In qryTSDtululiik
	Select (lcAlias)
	Return lcStr
Endfunc


Function test
	If !Used('tsd_report')
		Use tsd_report In 0
	Endif
	Create Cursor qryRekv (regkood c(20))
	Insert Into qryRekv (regkood) Values ('987654321')

	Create Cursor fltrAruanne (kpv1 Date Default Date(2017,01,01),  kpv2 Date Default Date(2017,01,31))
	Append Blank

	Create Cursor v_memo (XML m)
Endfunc

