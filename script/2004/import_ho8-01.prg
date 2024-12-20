*!*		Create Cursor qryasutus( Id Int,rekvId Int,regkood c(20),nimetus c(254), omvorm c(20),;
*!*			aadress m, kontakt m,  tel c(20),  faks c(60), email c(60),  muud m,  tp c(20))

CLEAR all

CREATE CURSOR qrykontrol (summa m)
APPEND BLANK


lcFile = 'c:\avpsoft\haridus\alg\algHO.dbf'

If !Used('qryAlg')
	Use (lcFile) In 0 Alias qryAlg_
ENDIF
SET STEP ON 

CREATE CURSOR qryAlg (summa n(12,2), konto c(20) DEFAULT qryAlg_.konto, asutuse_ko c(20) DEFAULT qryAlg_.asutuse_ko,  ;
	asutus c(120) DEFAULT  qryAlg_.asutus, KOOD c(20) DEFAULT qryAlg_.kood)

SELECT qryAlg_
SCAN
	lnSumma = transdigit(qryAlg_.summa)
	IF lnSumma <> 0
		SELECT qryAlg
		APPEND BLANK
		replace summa WITH lnSumma IN qryAlg
	ENDIF
	
ENDSCAN

*!*	INSERT INTO qryAlg ( summa, konto, asutuse_ko, asutus, KOOD );
*!*	SELECT transdigit(summa) as summa, konto, asutuse_ko, asutus, KOOD FROM qryAlg_ 

*!*	Select qryAlg
*!*	BROWSE
*!*	MODIFY STRUCTURE
*!*	RETURN


gnhandle = SQLConnect('narvalvpg', 'vlad','490710')
If gnhandle < 1
	Messagebox('Viga, uhendus')
	Return .F.
Endif


If gnhandle > 0
	lError = SQLEXEC(gnhandle,'begin work')


	If lError > 0
* update algsaldo
		lcString = 'update  kontoinf set algsaldo = 0 where rekvid = 11 '
		lError = SQLEXEC(gnhandle,lcString)


	Endif

	If lError > 0
* update algsaldo subkonto
		lcString = 'update  subkonto set algsaldo = 0 where rekvid = 11 '
		lError = SQLEXEC(gnhandle,lcString)

	Endif
	If lError > 0
* update algsaldo tunnusinf
		lcString = 'update  tunnusId set algsaldo = 0 where rekvid = 11 '
		lError = SQLEXEC(gnhandle,lcString)

	Endif

	Select konto, Sum(Summa) As Summa From qryAlg Group By konto Order By konto Into Cursor qryKontod
	Select qryKontod
	
	lnSumma = 0
	lnDok = 0
	
	Scan
		Wait Window 'Konto:'+qryKontod.konto Nowait
		replace qrykontrol.summa WITH 'Konto:'+qryKontod.konto+STR(qryKontod.summa,14,2)+CHR(13)  ADDITIVE IN qryKontrol
		
		

		lcString = "select id from library where library = 'KONTOD' and kood = '"+Alltrim(qryKontod.konto)+"'"
		lError = SQLEXEC(gnhandle,lcString,'qryKontoId')
		If Reccount('qryKontoId') < 1
* puudub konto
			Set Step On
			lError = -1
		Endif
		If lError > 0
			lcString = "update kontoinf set algsaldo = "+Str(qryKontod.Summa,14,4)+" where rekvid = 11 and parentid = "+Str(qryKontoId.Id,9)
			lError = SQLEXEC(gnhandle,lcString)

		Endif



		If lError > 0
			Select IIF(asutuse_ko='179','0179',asutuse_ko) As tunnus, Sum(Summa) As Summa From qryAlg Where !Empty(asutuse_ko) Or asutuse_ko <> '0' And konto = qryKontod.konto Group By asutuse_ko Order By asutuse_ko Into Cursor qryTunnus
			Select qryTunnus
			SCAN FOR !EMPTY(qryTunnus.tunnus ) and ALLTRIM(qryTunnus.tunnus) <> '0'
				Wait Window 'Konto:'+qryKontod.konto + 'tunnus :'+qryTunnus.tunnus Nowait

				lcString = "select id from library where rekvid = 11 and library = 'TUNNUS' and kood = '"+Alltrim(qryTunnus.tunnus)+"'"
				lError = SQLEXEC(gnhandle,lcString,'qryTunnusId')

				If Reccount('qryTunnusId') < 1
* puudub tunnus
					Set Step On
					lError = -1
					Exit
				Else
					lcString = "select id from tunnusinf where rekvid = 11 and kontoid = "+Str(qryKontoId.Id,9)+" and tunnusid = "+Str(qryTunnusId.Id,9)
					lError = SQLEXEC(gnhandle,lcString,'qryTuninfId')
					If Reccount('qryTuninfId') < 1
						lcString = "insert into tunnusId (kontoid, tunnusId, rekvId, algsaldo) values ("+;
							STR(qryKontoId.Id,9)+","+Str(qryTunnusId.Id,9)+",11,"+Str(qryTunnus.Summa,14,2)+")"

						lError = SQLEXEC(gnhandle,lcString)
					Else
						lcString = " UPDATE tunnusInf SET algsaldo = "+Str(qryTunnus.Summa,14,2)+" where rekvid = 11 and id = "+Str(qryTunInfId.Id,9)
						lError = SQLEXEC(gnhandle,lcString)

					Endif
				Endif
				If lError < 0
					Exit
				Endif

			ENDSCAN
			SELECT qryTunnus
			SUM summa TO lnTunSumma
			replace qrykontrol.summa WITH '�ksused'+STR(lnTunsumma,14,2)+CHR(13)  ADDITIVE IN qryKontrol


		Endif

		If lError > 0

			Select asutus, KOOD, Sum(Summa) As Summa From qryAlg ;
				Where (!Empty(asutus) Or asutus <> "'" OR asutus <> '0') And konto = qryKontod.konto ;
				Group By asutus, kood Order By asutus Into Cursor qryAsutus
			Select qryAsutus
			SCAN FOR !EMPTY(asutus) AND ALLTRIM(asutus) <> '0'
				Wait Window 'Konto:'+qryKontod.konto + 'asutus :'+qryAsutus.asutus Nowait
				lcregkood = Alltrim(qryasutus.KOOD)
				IF UPPER(qryAsutus.asutus) = 'BALTIC TOURS AS'
					lcregkood= '10101032'
				ENDIF
				
				IF (!EMPTY(lcregkood) AND lcregkood <> '#N/A') 
				
					lcString = "select id from asutus where regkood = '"+lcregkood+"'"
				ELSE
					lcString = "select id from asutus where UPPER(nimetus) = '"+UPPER(LTRIM(rtrim(qryasutus.asutus)))+"'"
				ENDIF

				lError = SQLEXEC(gnhandle,lcString,'qryAsutusId')

				IF RECCOUNT('qryAsutusId') <  1
					SET STEP ON 
					lError = -1
					exit
				ELSE

					lcString = "select id from subkonto where rekvid = 11 and kontoid = "+Str(qryKontoId.Id,9)+" and asutusid = "+Str(qryAsutusId.Id,9)
					lError = SQLEXEC(gnhandle,lcString,'qrySubkontoId')
					If Reccount('qrySubkontoId') < 1
						lcString = "insert into subkonto (kontoid, asutusid, rekvId, algsaldo) values ("+;
							STR(qryKontoId.Id,9)+","+Str(qrySubkontoId.Id,9)+",11,"+Str(qryAsutus.Summa,14,2)+")"

						lError = SQLEXEC(gnhandle,lcString)
					Else
						lcString = " UPDATE Subkonto SET algsaldo = "+Str(qryAsutus.Summa,14,2)+" where rekvid = 11 and id = "+Str(qrySubkontoId.Id,9)
						lError = SQLEXEC(gnhandle,lcString)

					Endif
				Endif
				If lError < 0
					Exit
				Endif

			Endscan
			SELECT qryAsutus
			SUM summa TO lnAsuSumma
			replace qrykontrol.summa WITH 'Subkontod'+STR(lnAsusumma,14,2)+CHR(13) ADDITIVE  IN qryKontrol



		Endif


		

		If lError < 1
			Exit
		ELSE
			lnSumma = lnSumma + qryKontod.summa
			lnDok = lnDok + 1

		Endif

	Endscan



Endif
If lError > 0
	=SQLEXEC(gnhandle,'commit work')
	Messagebox('Ok, summa:'+STR(lnSumma,14,2)+' dok:'+STR(lnDok,4))
	SELECT QRYkontrol
	MODIFY MEMO summa save
	COPY MEMO QRYkontrol.summa TO HOAlg.prn
Else
	=SQLEXEC(gnhandle,'rollback work')
	Messagebox('Viga')
Endif
=SQLDISCONNECT(gnhandle)



Function transdigit
	Lparameters tcString
	lnQuota = At(',',ALLTRIM(tcString))
	IF lnQuota > 0
	lcKroon = Left(ALLTRIM(tcString),lnQuota-1)
	lcCent = Right(ALLTRIM(tcString),2)
	DO WHILE At(Space(1),lcKroon) > 0
*	If At(Space(1),lcKroon) > 0
* on probel
		lcKroon = Stuff(lcKroon,At(Space(1),lcKroon),1,'')
	ENDDO
	
		RETURN VAL(lcKroon+'.'+lcCent)
	ELSE
		RETURN VAL(ALLTRIM(tcString))
	ENDIF
	
	
Endfunc
