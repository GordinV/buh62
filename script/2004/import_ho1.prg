Local lError
lcFile1 = 'c:\avpsoft\files\buh60\temp\haridus\agr2004palk.dbf'
lcFile2 = 'c:\avpsoft\files\buh60\temp\haridus\tp2004.dbf'
If !File(lcFile1) Or !File(lcFile2)
	Messagebox('Viga, failid ei leidnud')
	lError = .T.
Endif
Use (lcFile1) In 0 Alias lausend Excl
Use (lcFile2) In 0 Alias asutused Excl

Select Val(Alltrim(lausend.n11)) As asutusId, Val(Alltrim(asutused.n1)) As Id, asutused.n5 As nimetus, asutused.n6 As regkood, ;
	lausend.* From lausend Left Outer Join asutused On Val(Alltrim(asutused.n1)) = lausend.asutusId;
	INTO Cursor qryHO
*!*	SET STEP ON
*!*	scan
*!*		lcSumma = transdigit(ltrim(RTRIM(qryHo.n9)))
*!*	ENDSCAN
*!*	return

gnHandle = SQLConnect('narvalvpg','vlad','490710')
If gnHandle < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

lnSumma = 0
lnrec = 0
=SQLEXEC(gnHandle,'begin work')

Select qryHO
Scan
	Wait Window Str(Recno('qryHo'))+'-'+Str(Reccount('qryHo')) Nowait
	lcErr = ''

	lcdate = 'date('+Left(Alltrim(qryHO.n8),4)+','+Substr(Alltrim(qryHO.n8),5,2)+','+Right(Alltrim(qryHO.n8),2)+')'
	lcAsutusId = '4576'
	lcuserId = '199'
	lcSelg = Ltrim(Rtrim(qryHO.n13))+Space(1)+Ltrim(Rtrim(qryHO.n14))
	lcDok = Ltrim(Rtrim(qryHO.n15))
	lcMuud = ''
	lcUksus = Ltrim(Rtrim(qryHO.n3))

	lcDeebet = Ltrim(Rtrim(qryHO.n1))
	lcKreedit = Ltrim(Rtrim(qryHO.n2))

	lcDeebet = Iif(lcDeebet = '2020001','202000',lcDeebet)
	lcDeebet = Iif(lcDeebet = '202091','202090',lcDeebet)
	lcDeebet = Iif(lcDeebet = '202092','202090',lcDeebet)

	lcKreedit = Iif(lcKreedit = '2020001','202000',lcKreedit)
	lcKreedit = Iif(lcKreedit = '202091','202090',lcKreedit)
	lcKreedit = Iif(lcKreedit = '202092','202090',lcKreedit)


	lcTpd = Ltrim(Rtrim(qryHO.n10))
	lcTpk = Ltrim(Rtrim(qryHO.n10))
	lcSumma = transdigit(Ltrim(Rtrim(qryHO.n9)))
	lcKood1 = Ltrim(Rtrim(qryHO.n4))
	lcKood2 = ''
	lcKood3 = ''
	lcKood4 = ''
	lcKood5 = Ltrim(Rtrim(qryHO.n5))


* kontrol

	lcString = " SELECT id from library where library = 'KONTOD' AND kood = '"+lcDeebet+"'"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryKontoId')
	If lnresult > 0
		If Reccount('qryKontoid') <  1
			lnresult = -1
			lcErr = lcDeebet
		Endif
	Endif

	lcString = " SELECT id from library where library = 'KONTOD' AND kood = '"+lcKreedit+"'"
	lnresult = SQLEXEC(gnHandle,lcString, 'qryKontoId')
	If lnresult > 0
		If Reccount('qryKontoid') <  1
			lnresult = -1
			lcErr = lcKreedit
		Endif
	Endif
	If !Empty(lcKood1)
		lcString = " SELECT id from library where library = 'TEGEV' AND kood = '"+lcKood1+"'"
		lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
		If lnresult > 0
			If Reccount('qryKood') <  1
				lnresult = -1
				lcErr = lcKood1
			Endif
		Endif
	Endif
	If !Empty(lcKood2)
		lcString = " SELECT id from library where library = 'ALLIKAD' AND kood = '"+lcKood2+"'"
		lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
		If lnresult > 0
			If Reccount('qryKood') <  1
				lnresult = -1
				lcErr = lcKood2
			Endif
		Endif
	Endif
	If !Empty(lcKood3)
		lcString = " SELECT id from library where library = 'RAHA' AND kood = '"+lcKood3+"'"
		lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
		If lnresult > 0
			If Reccount('qryKood') <  1
				lnresult = -1
				lcErr = lcKood3
			Endif
		Endif
	Endif
	If !Empty(lcKood5)
		lcString = " SELECT id from library where library = 'TULUDEALLIKAD' AND kood = '"+lcKood5+"'"
		lnresult = SQLEXEC(gnHandle,lcString, 'qryKood')
		If lnresult > 0
			If Reccount('qryKood') <  1
				lnresult = -1
				lcErr = lcKood5
			Endif
		Endif
	Endif


* �������� �� ������� tunnus
	If lnresult > 0 And !Empty(lcUksus)
		lcString = " SELECT id from library where library = 'TUNNUS' and rekvid = 11 AND kood = '"+lcUksus+"'"
		lnresult = SQLEXEC(gnHandle,lcString, 'qryTun')
		If lnresult > 0
			If Reccount('qryTun') <  1
* insert new value
				lcInsert = "insert into library (rekvid, kood, nimetus,library) values ("+;
					"11,'"+lcUksus+"','"+lcUksus+"','TUNNUS')"
				lnresult = SQLEXEC(gnHandle,lcString)
			Endif
		Endif
	Endif

	If lcDeebet <> lcKreedit
		If lnresult > 0
			lcString = "insert into journal (kpv, asutusId, rekvId, userId, selg, dok, muud) values ("+;
				lcdate+","+lcAsutusId+",11,"+lcuserId+",'"+lcSelg+"','"+lcDok+"','"+lcMuud+"')"

			lnresult = SQLEXEC(gnHandle,lcString)

		Endif

		If lnresult > 0

			lcString = 'select id from journal where rekvid = 11 order by id desc limit 1'
			lnresult = SQLEXEC(gnHandle,lcString,'qrylastId')
		Endif

		If lnresult > 0

			lcString = "insert into journal1 (parentId, deebet, lisa_d, kreedit, lisa_k, summa, tunnus, kood1, kood2, kood3, kood4, kood5) values ("+;
				STR(qryLastid.Id)+",'"+lcDeebet+"','"+lcTpd+"','"+lcKreedit+"','"+lcTpk+"',"+lcSumma+",'"+;
				lcUksus+"','"+lcKood1+"','"+lcKood2+"','"+lcKood3+"','"+lcKood4+"','"+lcKood5+"')"

			lnSumma = lnSumma + VAL(lcSumma)
			lnrec = lnrec  + 1
			lnresult = SQLEXEC(gnHandle,lcString)
			
		Endif
	Endif
	If lnresult < 0
		Exit
	Endif
Endscan
Set Step On
If lnresult > 0
	=SQLEXEC(gnHandle,'commit work')
	MESSAGEBOX('Ok, summa:'+STR(lnSumma,12,2)+' kokku read:'+STR(lnRec))
Else
	Set Step On
	=SQLEXEC(gnHandle,'rollback work')
Endif




=SQLDISCONNECT(gnHandle)

Function transdigit
	Lparameters tcString
	lnQuota = At(',',tcString)
	lcKroon = Left(tcString,lnQuota-1)
	lcCent = Right(tcString,2)
	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	Endif
	Return lcKroon+'.'+lcCent
Endfunc

