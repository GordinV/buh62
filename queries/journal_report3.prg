**
** journal_report3.fxp
**
Parameter cwHere


tcKood1 = Rtrim(Ltrim(fltrJournal.kood1))+'%'
tcKood2 = Rtrim(Ltrim(fltrJournal.kood2))+'%'
tcKood3 = Rtrim(Ltrim(fltrJournal.kood3))+'%'
tcKood5 = Rtrim(Ltrim(fltrJournal.kood5))+'%'
cSelg = '%'+Rtrim(Ltrim(fltrJournal.selg))+'%'
cDeebet = Rtrim(Ltrim(fltrJournal.deebet))+'%'
cKreedit = Rtrim(Ltrim(fltrJournal.kreedit))+'%'
cAsutus = '%'+Upper(Rtrim(Ltrim(fltrJournal.asutus)))+'%'
cDok = '%'+Upper(Ltrim(Rtrim(fltrJournal.dok)))+'%'
tcTunnus = Upper(Ltrim(Rtrim(fltrJournal.tunnus)))+'%'
dKpv1 = fltrJournal.kpv1
dKpv2 = Iif(Empty(fltrJournal.kpv2),Date()+365*10,fltrJournal.kpv2)
nSumma1 = Iif(Empty(fltrJournal.Summa1),-999999999,fltrJournal.Summa1)
nSumma2 = Iif(Empty(fltrJournal.Summa2),999999999,fltrJournal.Summa2)
tcTPD = Rtrim(Ltrim(fltrJournal.tpd))+'%'
tcTPK = Rtrim(Ltrim(fltrJournal.tpk))+'%'
tcKasutaja = Rtrim(Ltrim(fltrJournal.ametnik))+'%'
*!*	=dodefault()
tcMuud = '%'+Rtrim(Ltrim(fltrJournal.muud))+'%'
tcProj = Rtrim(Ltrim(fltrJournal.Proj))+'%'
tcUritus = Rtrim(Ltrim(fltrJournal.uritus))+'%'
tcValuuta = Rtrim(Ltrim(fltrJournal.valuuta))+'%'
tcObjekt = Rtrim(Ltrim(fltrJournal.objekt))+'%'



TEXT TO l_sql_where NOSHOW textmerge
	 kood1 ilike ?tcKood1 and kood2 ilike ?tcKood2 and kood3 ilike ?tcKood3 and kood5 ilike ?tcKood5
	 and coalesce(selg,'') ilike ?cSelg
	 and deebet ilike ?cDeebet and kreedit ilike ?cKreedit
	 and lisa_d ilike ?tcTPD and lisa_k ilike ?tcTPK
	 and coalesce(asutus,'') ilike ?cAsutus
	 and kpv >= ?dKpv1
	 and kpv <= ?dKpv2
	 and dok ilike '<<cDok>>'
	 and summa >= ?nSumma1 and summa <= ?nSumma2
	 and kasutaja ilike ?tcKasutaja
	 and tunnus ilike ?tcTunnus
	 and coalesce(muud,'') ilike ?tcMuud
	 and proj ilike ?tcProj
	 and kood4 ilike ?tcUritus
	 and objekt ilike ?tcObjekt
ENDTEXT

*l_months = MONTH(dKpv2) - MONTH(dKpv1) + 1

CREATE CURSOR  journal_report_ (created m, ;
	lastupdate m,;
	status c(20),;
	number i,;
	id integer,;
	kpv date,;
	journalid integer,;
	rekvId integer,;
	asutusid integer null,;
	kuu integer,;
	aasta integer,;
	selg c(254) null,;
	dok c(254) null,;
	objekt c(254) null,;
	muud c(254) null,;
	deebet c(20),;
	lisa_d c(20),;
	kreedit c(20),;
	lisa_k c(20),;
	summa n(12,2),;
	valsumma n(12,2),;
	valuuta c(3),;
	kuurs n(12,6) null,;
	kood1 c(20) null,;
	kood2 c(20) null,;
	kood3 c(20) null,;
	kood4 c(20) null,;
	kood5 c(20) null,;
	proj c(20) null,;
	asutus c(254) null,;
	tunnus c(20) null,;
	kasutaja c(254),;
	rekvAsutus c(254))
	

l_result = 0
l_finish = .f.
l_kpv = dKpv1
l_kpv2 = GOMONTH(DATE(YEAR(dkpv2), MONTH(dKpv2), 1),1) - 1

IF (gRekv = 63 OR gRekv = 119 ) AND (EMPTY(fltrJournal.kood1) OR EMPTY(fltrJournal.kood2) OR EMPTY(fltrJournal.kood3) OR EMPTY(fltrJournal.kood5) or EMPTY(fltrJournal.deebet) or EMPTY(fltrJournal.kreedit))

	DO WHILE l_kpv =< l_kpv2
		TEXT TO l_additional_where NOSHOW TEXTMERGE 		
			and kuu = <<MONTH(l_kpv)>>
			and aasta = <<year(l_kpv)>>
		ENDTEXT
		l_where = l_sql_where + l_additional_where 
		
		lError = oDb.readFromModel('raamatupidamine\journal', 'curJournal', 'gRekv, guserid', 'journal_report', l_where )
		
		SELECT journal_report_
		APPEND FROM DBF('journal_report')
		USE IN journal_report

		l_kpv = GOMONTH(l_kpv,1)		
	ENDDO
ELSE 
	l_where = l_sql_where 
	lError = oDb.readFromModel('raamatupidamine\journal', 'curJournal', 'gRekv, guserid', 'journal_report_', l_where )
ENDIF


Select created,;
	lastupdate,;
	status,;
	id,;
	number,;
	kpv,;
	journalid,;
	rekvId,;
	asutusid,;
	kuu,;
	aasta,;
	STRTRAN(STRTRAN(selg, CHR(13)," "),CHR(10)," ") as selg,;
	dok,;
	objekt,;
	STRTRAN(STRTRAN(muud, CHR(13)," "),CHR(10)," "),;
	deebet,;
	lisa_d,;
	kreedit,;
	lisa_k,;
	summa,;
	valsumma,;
	valuuta,;
	kuurs,;
	kood1,;
	kood2,;
	kood3,;
	kood4,;
	kood5,;
	proj,;
	asutus,;
	tunnus,;
	kasutaja,;
	rekvAsutus From journal_report_ ;
	ORDER BY rekvid, kpv ;
	INTO Cursor journal_report1

Use In journal_report_
Select journal_report1
Return .T.
