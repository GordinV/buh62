Set step on
Create cursor curKey (versia m)
Append blank
Replace versia with 'EELARVE' in curKey
Create cursor v_account (admin int default 1)
Append blank
*!*	gnhandle = sqlconnect ('narva','jelena','208')
*!*	&&,'zinaida','159')
*!*	gversia = 'MSSQL'
*!*	grekv = 2
&&cdata = 'c:\raama\avpsoft\buhdata5.dbc'
gnHandle = 1
gversia = 'VFP'
&&Open data (cdata)
grekv = 1
Local lError
If v_account.admin < 1
	Return .t.
Endif
CREATE cursor scrBilanss (nimetus c(254), rea c(20), konto c(20))
insert into scrBilanss (nimetus, rea, konto) values ('Raha ja pangakontod','1','' )
insert into scrBilanss (nimetus, rea, konto) values ('Sularaha kassas','1.1','111')
insert into scrBilanss (nimetus, rea, konto) values ('Pangakontod EEK','1.2','113')
insert into scrBilanss (nimetus, rea, konto) values ('Valuutakontod pangas','1.3','115')
insert into scrBilanss (nimetus, rea, konto) values ('Aktsiad ja muud v��rtpaberid','2','')
insert into scrBilanss (nimetus, rea, konto) values ('N�uded ostjate vastu','3','')
insert into scrBilanss (nimetus, rea, konto) values ('Ostjatelt laekumata arved','3.1','122')
insert into scrBilanss (nimetus, rea, konto) values ('Ostjate vekslid','3.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Ebat�n�oliselt laekuvad arved (miinus)','3.3','')
insert into scrBilanss (nimetus, rea, konto) values ('Mitmesugused n�uded','4','')
insert into scrBilanss (nimetus, rea, konto) values ('N�uded ema- ja t�tarettev�tete vastu','4.1','')
insert into scrBilanss (nimetus, rea, konto) values ('N�uded sidusettev�tete vastu','4.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Arveldused aktsion�ridega','4.3','')
insert into scrBilanss (nimetus, rea, konto) values ('Viitlaekumised (aruandeperioodi laekumata tulud)','5','')
insert into scrBilanss (nimetus, rea, konto) values ('Intressid','5.1','')
insert into scrBilanss (nimetus, rea, konto) values ('Dividendid','5.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Muud viitlaekumised','5.3','')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemaksud tulevaste perioodide kulud','6','')
insert into scrBilanss (nimetus, rea, konto) values ('Maksude ettemaksed ja tagasin�uded','6.1','')
insert into scrBilanss (nimetus, rea, konto) values ('Muud ettemakstud tulevatse perioodide kulud','6.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Varud','7','')
insert into scrBilanss (nimetus, rea, konto) values ('Tooraine ja material','7.1','')
insert into scrBilanss (nimetus, rea, konto) values ('L�petamata toodang','7.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Valmistoodang','7.3','')
insert into scrBilanss (nimetus, rea, konto) values ('Ostetud kaubad m��giks','7.4','')
insert into scrBilanss (nimetus, rea, konto) values ('Ettemaksed hankijatele','7.5','')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised finantsinvesteeringud (finantsp�hivara)','8','')
insert into scrBilanss (nimetus, rea, konto) values ('Aktsiad ja osad','8.1','')
insert into scrBilanss (nimetus, rea, konto) values ('V�lakirjad ja muud v��rtpaberid','8.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised n�uded','8.3','')
insert into scrBilanss (nimetus, rea, konto) values ('Materiaalne p�hivara','9','')
insert into scrBilanss (nimetus, rea, konto) values ('Maa ja ehitised (soetusmaksumus)','9.1','')
insert into scrBilanss (nimetus, rea, konto) values ('Masinad ja seadmed (soetamismaksumus)','9.2','')
insert into scrBilanss (nimetus, rea, konto) values ('Muu inventar, t��riistad, sisseseade ja muud (soetusmaksumus)','9.3','')
insert into scrBilanss (nimetus, rea, konto) values ('Pohivara kulum (miinusega)','9.3','')
insert into scrBilanss (nimetus, rea, konto) values ('L�petamata ehitus','9.4', '')
insert into scrBilanss (nimetus, rea, konto) values ('Materiaalsete p�hivarade ettemaksed','9.5', '')
insert into scrBilanss (nimetus, rea, konto) values ('Immateriaalne p�hivara','10', '')
insert into scrBilanss (nimetus, rea, konto) values ('Asutamisv�ljaminekud','10.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('Arenguv�ljaminekud','10.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('Ostetud patendid, litsentsid, kontsessioonid, kaubam�rgid, rendi�igus jne.','10.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused','11', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised laenud','11.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused asutustele','11.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajaliste kohustuste l�hiajaline osa','11.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajaline v�lakirjade emiteerimine','11.4', '')
insert into scrBilanss (nimetus, rea, konto) values ('V�lad tarnijatele','11.5', '')
insert into scrBilanss (nimetus, rea, konto) values ('Muud l�hiajalised kohustused','11.6', '')
insert into scrBilanss (nimetus, rea, konto) values ('Ostjate (tellijate) ettemaksed','12', '')
insert into scrBilanss (nimetus, rea, konto) values ('Maksuv�lad ja maksude ettemaksud','13', '')
insert into scrBilanss (nimetus, rea, konto) values ('Sotsiaalmaks','13.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('Isiku tulumaks','13.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('Erisoodustuse tulumaks','13.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('T��tuskindlustus','13.4', '')
insert into scrBilanss (nimetus, rea, konto) values ('K�ibemaks','13.5', '')
insert into scrBilanss (nimetus, rea, konto) values ('Muud','13.6', '')
insert into scrBilanss (nimetus, rea, konto) values ('Viitv�lad','14', '')
insert into scrBilanss (nimetus, rea, konto) values ('L�hiajalised kohustused','14.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('V�lad t��v�tjale','14.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('Puhkusetasu kohustus','14.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('Muud luhiajalised volad','14.4', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised v�lakohustused','15', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised deposiidid','15.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('V�lg liisingfirmadele','15.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised tarnijakrediidid','15.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajaliste v�lakirjade emiteerimine','15.4', '')
insert into scrBilanss (nimetus, rea, konto) values ('Pikaajalised laenud','15.5', '')
insert into scrBilanss (nimetus, rea, konto) values ('Muud pikaajalised kohustused','15.6', '')
insert into scrBilanss (nimetus, rea, konto) values ('Kapital','16', '')
insert into scrBilanss (nimetus, rea, konto) values ('Eelmiste perioodide tulem','17', '')
insert into scrBilanss (nimetus, rea, konto) values ('Aruandeaasta tulem','18', '')
If !used ('key')
	Use key in 0
Endif
Select key
lnFields = afields (aObjekt)
Create cursor qryKey from array aObjekt
Select qryKey
Append from dbf ('key')
Use in key
=secure('OFF')


Do case
	Case gversia = 'VFP'
		Select qryKey
		Scan for mline(qryKey.connect,1) = 'FOX'
			lcdata = mline(qryKey.vfp,1)
			If file (lcdata)
				Open data (lcdata)
				lcdefault = sys(5)+sys(2003)
				Set DEFAULT TO justpath (lcdata)
				lError =  _alter_vfp()
				Close data
				Set default to (lcdefault)
			Endif
		Endscan
		Use in qryKey
	Case gversia = 'MSSQL'
		=sqlexec (gnhandle,'begin transaction')
		lError = _alter_mssql ()
		If vartype (lError ) = 'N'
			lError = iif( lError = 1,.t.,.f.)
		Endif
		If lError = .f.
			=sqlexec (gnhandle,'rollback')
		Else
			=sqlexec (gnhandle,'commit')
		Endif
Endcase

*!*	If lError = .f.
*!*		Messagebox ('Viga')
*!*	Endif
If gversia <> 'VFP'
	=sqldisconnect (gnhandle)
Endif
Return lError

Function _alter_vfp
&& ������� ��������� ����.
select id from rekv into cursor qry_Rekv
&& ������� ��������� ����� �������
SELECT Library.kood, Library.nimetus, Library.library, Library.id,  Library.rekvid ;
 FROM Library WHERE Library.library LIKE 'BILANSS%' into cursor qry_bilanss

select qry_rekv
scan
	select scrBilanss
	scan
		select qry_bilanss
		locate for alltrim(kood) = alltrim(scrBilanss.konto) and;
			alltrim(upper(nimetus)) = alltrim(upper(qry_bilanss.nimetus))
		if !found ()
			lcString = " insert into library (rekvid, kood, nimetus, library ) values ("+;
				str (qry_rekv.id)+",'"+ ltrim(rtrim(scrBilanss.konto))+"','"+;
				ltrim(rtrim(scrBilanss.nimetus))+"','"+;
				"BILANSS"+LTRIM(RTRIM(scrBilanss.rea))+"')"
			&lcString
		endif 
	endscan
endscan
use in qry_rekv
use in qry_bilanss
if used ('library')
	use in library
endif
	Return

Function setpropview
	lnViews = adbobject (laView,'VIEW')
	For i = 1 to lnViews
		lError = dbsetprop(laView(i),'View','FetchAsNeeded',.t.)
	Endfor
	Return


Function _alter_mssql
	cString = "sp_help "
	lError = sqlexec (gnhandle,cString)
	If lError > 0
		If used ('sqlresult')
			Select sqlresult
			Locate for upper(name) = 'CURTOOD' and object_type = 'view'
			If !found ()
				cString = 'create view curtood as '+;
					'SELECT teenused.id, teenused.asutusid, left(ltrim(rtrim(asutus.nimetus))+space(1)+ltrim(rtrim(asutus.omvorm)),254) as asutus,'+;
					'asutus.regkood, teenused.rekvid, teenused.kpv,'+;
					'teenused.isikId, teenused.nomid, isikud.regkood AS isikukood, isikud.nimetus AS isik, nomenklatuur.kood, '+;
					'nomenklatuur.nimetus AS teenus, nomenklatuur.uhik, teenused.tundA, teenused.tundL, teenused.minA, teenused.minL,'+;
					'teenused.hind, teenused.kogus, teenused.kokku, teenused.arvid '+;
					'FROM  dbo.teenused INNER JOIN dbo.asutus ON teenused.asutusid = dbo.asutus.id '+;
					'INNER JOIN dbo.asutus isikud ON teenused.isikId = isikud.id '+;
					'INNER JOIN dbo.nomenklatuur ON teenused.nomid = dbo.nomenklatuur.id '

				lError = sqlexec(gnhandle, cString)
				If lError < 0
					Return .f.
				Endif


				cString = 'GRANT  SELECT  ON curtood  TO dbkasutaja'
				lError = sqlexec(gnhandle, cString)
				cString = 'GRANT  SELECT   ON curTood  TO dbpeakasutaja'
				lError = sqlexec(gnhandle, cString)
				lError = iif(lError > 0,.t.,.f.)
			Endif
		Endif
	Endif
	If used ('curKey') and 'EELARVE' $ curKey.versia
		cString = "SELECT id,kood from library where library = 'KONTOD' "
		lError = sqlexec (gnhandle,cString,'qryKnt')
		If lError < 0 or !used ('qryKnt')
			Return .f.
		Endif
&&		lError = sqlsetprop(gnhandle,'BatchMode',.f.)
		Select qryKnt
		Locate for kood = '1115'
		If !found ()
			cString = "insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1115','Elumajade osad (korterid)','KONTOD',"+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1117'
		If !found ()
			cString = "insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1117','Pikaajaliselt renditud maarajatised ja hooned � kapitalirent','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1240'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1240','Pikaajalised nouded asutustele','KONTOD', "+str(grekv)+")"
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1290'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1290','Finantsp�hivarade ettemaksed','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1519'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1519','Muud n�uded t��tajate vastu','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1521'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				" values ('1519','N�uded riigieelarvele liigendamata tulude osas ','KONTOD',"+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1522'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1522','N�uded riigieelarvele majandustegevusest teenitud tulude (omatulud) osas ','KONTOD',"+;
				str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1523'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1523','N�uded riigieelarvele sihtfinantseerimise osas  ','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1528'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1528','Laekumised riigieelarvesse (majandustegevusest, sihtfinantseerimisest)','KONTOD', "+;
				str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1529'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1529','Tasumised riigieelarvest (majandustegevusest, sihtfinantseerimisest)','KONTOD',"+;
				str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '1653'
		If found ()
			cString = "Update library set nimetus = 'Ettemakstud tootuskindlustuse maks' where id = "+str(qryKnt.id)
		Else
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('1653','Ettemakstud t��tuskindlustuse maks','KONTOD', "+str(grekv)+")"
		Endif
&&		lError = sqlsetprop(gnhandle,'BatchMode',.t.)
		lError = sqlexec (gnhandle,cString)
		If lError < 0
			Return .f.
		Endif
&&		lError = sqlsetprop(gnhandle,'BatchMode',.t.)
		Select qryKnt
		Locate for kood = '599'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('599','Siirded eelarvesse ','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '5991'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				" values ('5991','Kulud siiretest eelarvesse','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '6062'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('6062','Valitavate ja nimetatavate ametnike lisatasu','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '6063'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('6063','Valitavate ja nimetatavate ametnike esindustasu','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '7286'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('7286','V��rtpaberituru kutseliste osaliste, krediidiasutuste, kindlustusandjate ja "+;
				"-vahendajate, fondivalitsejate ja investeerimisfondidega seotud toimingute riigil�iv','KONTOD',"+;
				str( grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '7287'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				" values ('7287','Valla- ja linnaeelarvesse kauplemisloa v�ljastamise eest laekuv riigil�iv ','KONTOD', "+;
				str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
		Select qryKnt
		Locate for kood = '7288'
		If !found ()
			cString = "Insert into library (kood, nimetus, library, rekvid) "+;
				"values ('7288','Valla- ja linnaeelarvesse ehituslubade, kasutuslubade ja riikliku "+;
				"ehitusregistri andmete kinnitatud v�ljavotete eest laekuv riigil�iv','KONTOD', "+str(grekv)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 0
				Return .f.
			Endif
		Endif
&&		lError = sqlsetprop(gnhandle,'BatchMode',.t.)
		cString = "select rekv.id as rekvid, library.kood, library.id from rekv,library "+;
			"where library.id not in (select distinct parentid from kontoinf  )" +;
			" and library.library = 'KONTOD' "+;
			" order by rekv.id"
		lError = sqlexec (gnhandle,cString,'qryKontoinf')
		If lError < 0
			Return .f.
		Endif
&&		lError = sqlsetprop(gnhandle,'BatchMode',.f.)
		Select qryKontoinf
		Scan
			cString = " insert into kontoinf (parentid, type, formula, aasta, algsaldo, liik, rekvid) values ("+;
				str(qryKontoinf.id)+",1,0,2003,0,1,"+str(qryKontoinf.rekvid)+")"
			lError = sqlexec (gnhandle,cString)
			If lError < 1
				Exit
			Endif
		Endscan
		If lError < 1
&&			lError = sqlsetprop(gnhandle,'BatchMode',.t.)
			Return .f.
		Endif
	Endif


	Return lError
Endproc




Function secure
	Lparameters LCENCR
	maxno=100
	LCENCR=UPPER(ALLT(LCENCR))
	If LCENCR<>'ON' AND LCENCR<>'OFF'
		Return MESSAGEBOX("Pass ON or OFF for encryption/decryption!")
	Endif
&&SET PROC TO securedata ADDI
* loop through all fields in a table
	lnFields=FCOUNT()
	For J = 1 TO lnFields
		LCFIELD=FIELD(J)
		Do CASE
			Case TYPE(LCFIELD) $ 'CM'
* replace the all the contents of this particular field
				Repl ALL &LCFIELD WITH CONVRT(LCENCR,&LCFIELD)
		Endcase
	Endfor



Procedure CONVRT
	Lparameters lcencrypt,lcString
	If parameters()<2
		Messagebox('Pass two arguments, [On Off] and string')
		Return
	Endif
	lcencrypt=upper(allt(lcencrypt))
* encrypt data
* take a string and shift the data to the right one place
	If lcencrypt='ON'
		lnlen=len(allt(lcString))
		lcnewstring=''
* convert the string to the value of the current string + the position
* number of the char in the string.  A string of "ABC" would be converted
* to "BDF"

		For i = 1 to lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=chr(asc(substr(lcString,i,1))+i)
			Else
				lcchar=chr(asc(substr(lcString,i,1))+1)
			Endif
*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Else
		lnlen=len(allt(lcString))
		lcnewstring=''
		For i = 1 to lnlen
* asc(substring(lcstring,i,1)) for a "d" is 100
* so if the "d" were in the 1st position it would be converted
* to "e" via the following line
			If i<maxno
				lcchar=chr(asc(substr(lcString,i,1))-i)
			Else
				lcchar=chr(asc(substr(lcString,i,1))-1)
			Endif

*build new string from converted characters
			lcnewstring=lcnewstring+lcchar
		Endfor
		RETVAL=lcnewstring
	Endif
	Return (RETVAL)



