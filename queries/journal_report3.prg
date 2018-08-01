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
	 and dok ilike ?cDok
	 and kpv >= ?dKpv1
	 and kpv <= ?dKpv2
	 and summa >= ?nSumma1 and summa <= ?nSumma2
	 and kasutaja ilike ?tcKasutaja
	 and tunnus ilike ?tcTunnus
	 and coalesce(muud,'') ilike ?tcMuud
	 and proj ilike ?tcProj
	 and kood4 ilike ?tcUritus
	 and objekt ilike ?tcObjekt
ENDTEXT
lError = oDb.readFromModel('raamatupidamine\journal', 'curJournal', 'gRekv, guserid', 'journal_report1', l_sql_where)


Select joUrnal_report1
Index On Id Tag Id
Index On kpV Tag kpV Additive
Index On Number Tag Number Additive
Index On deebet Tag deebet Additive
Index On kreedit Tag kreedit Additive
Index On kood1 Tag kood1 Additive
Index On kood2 Tag kood2 Additive
Index On kood3 Tag kood3 Additive
Index On koOd4 Tag koOd4 Additive
Index On kood5 Tag kood5 Additive
Index On liSa_d Tag liSa_d Additive
Index On liSa_k Tag liSa_k Additive
Index On Summa Tag Summa Additive
Index On Left(Upper(selg), 40) Tag selg Additive
Index On Left(Upper(dok), 40) Tag dok Additive
Index On Left(Upper(asutus), 40) Tag asutus Additive
Index On tunnus Tag tunnus Additive
If Used('curJournal')
	Select cuRjournal
	lcTag = Tag()
Else
	lcTag = 'KPV'
Endif
Select joUrnal_report1
Set Order To (lcTag)
RETURN .t.
