Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif

IF !EMPTY(cWhere)
	tnId = cWhere
ELSE
	IF USED('v_arv')
		tnId  = v_arv.id
	ENDIF	
ENDIF


lError = oDb.readFromModel('raamatupidamine\arv', 'row', 'tnId, guserid', 'qryArv')

If !lError
	Set Step On
	Return .F.
Endif

lError = oDb.readFromModel('raamatupidamine\arv', 'details', 'tnId, guserid', 'qryArv1')

If !lError
	Set Step On
	Return .F.
Endif

tnId = qryArv.journalid

lError = oDb.readFromModel('raamatupidamine\journal', 'row', 'tnId, guserid', 'qryLausend')
lError = oDb.readFromModel('raamatupidamine\journal', 'details', 'tnId, guserid', 'qryJournal')

Create Cursor arve_report1 (Id Int,Number c(20), aa c(20) Null, kpv d, lisa c(120),tahtaeg d Null, asutusid Int,;
	kood c(20), uhik c(20), doklausid Int, nomid Int, hind Y, kogus Y, soodus Y, kbm Y, Summa N(14,2), kbmta N(14,2), ;
	reamuud m Null, nomnimi c(254), arvkbmta N(14,2), arvkbm N(14,2), kokku N(14,2), ;
	muud m Null, regkood c(20) Null, rk c(20) Null, journalid Int Null, asutus c(254), aadress m Null, ;
	email c(120) Null, reamark m Null, konto c(20),viitenr c(20) Null,;
	lausend m Null, jaak N(14,2), arvperiod c(120) Null, km c(2) Null, kas_tulu l Default .T.,;
	taas_arveldus N(14,2) DEFAULT 0, idx i DEFAULT 0, kreedit_arve c(254) null)

Create Cursor arve_lausend (Id Int, lausend m, kpv d)

l_taskuraha  = 0
l_idx = 0

Select qryArv
Go Top

Select qryArv1
Scan
	If qryArv1.taskuraha =  0
* va taskuraha
		DO case 
			CASE qryArv1.allikas_85 > 0 
				l_idx = 1					
			CASE qryArv1.umardamine > 0 
				l_idx = 2					
			CASE qryArv1.muud = 'Hoolduskulu'
				l_idx = 3					
			CASE qryArv1.allikas_muud > 0 
				l_idx = 4					
			CASE qryArv1.allikas_vara > 0 
				l_idx = 5					
			CASE qryArv1.omavalitsuse_osa> 0 
				l_idx = 6
		ENDcase
		
		Insert Into arve_report1 (Id, Number, kpv, aa, lisa, tahtaeg, asutusid, kood, uhik, ;
			hind , kogus , soodus , kbm , Summa, kbmta, ;
			nomnimi ,reamark, arvkbmta, arvkbm, kokku,	regkood, rk, km,;
			journalid, asutus, aadress, jaak, muud, viitenr, ;
			kas_tulu, idx ) ;
			VALUES (qryArv.Id, qryArv.Number, qryArv.kpv, qryArv.aa, qryArv.lisa, qryArv.tahtaeg, qryArv.asutusid, qryArv1.kood, qryArv1.uhik, ;
			qryArv1.hind, qryArv1.kogus, qryArv1.soodus, qryArv1.kbm, qryArv1.Summa, qryArv1.kbmta,;
			qryArv1.nimetus, Iif(Isnull(qryArv1.muud),'',qryArv1.muud), qryArv.kbmta, qryArv.kbm, qryArv.Summa, Alltrim(qryArv.regkood), qryArv.kmkr,  qryArv1.km,;
			qryArv.laus_nr, qryArv.asutus, qryArv.aadress, qryArv.jaak, qryArv.muud, qryArv.viitenr,;
			EMPTY(qryArv.liik), l_idx)
	Endif
	l_idx = 0
Endscan
Update 	arve_report1  Set taas_arveldus  = qryArv.taskuraha_kov


Insert Into arve_lausend (Id, kpv) Values (qryArv.laus_nr, qryLausend.kpv)

If Reccount ('qryJournal') > 0
	Select qryJournal
	Scan
		lcString =  'D '+Ltrim(Rtrim(qryJournal.deebet))+Space(1)+;
			'K '+Ltrim(Rtrim(qryJournal.kreedit)) + Space(1)+;
			alltrim(Str (qryJournal.Summa,12,2)) + Chr(13)
		Replace arve_lausend.lausend With lcString Additive In arve_lausend
	Endscan

Endif

Select arve_report1
IF !ISNULL(qryArv.kr_number) AND !EMPTY(qryArv.kr_number) 
	UPDATE arve_report1 SET kreedit_arve = '(Kreeditarve arvele Nr.' + ALLTRIM(qryArv.kr_number) + ')'
ENDIF


lcPeriod = ''
Dimension aKuu(12)

aKuu(1) = 'Jaanuar'
aKuu(2) = 'Veebruar'
aKuu(3) = 'Marts'
aKuu(4) = 'Aprill'
aKuu(5) = 'Mai'
aKuu(6) = 'Juuni'
aKuu(7) = 'Juuli'
aKuu(8) = 'August'
aKuu(9) = 'September'
aKuu(10) = 'Oktoober'
aKuu(11) = 'November'
aKuu(12) = 'Detsember'


Create Cursor curEestiKuu (Id Int, kuu c(40))
For i = 1 To 12
	Insert Into curEestiKuu (Id, kuu)  Values (i,aKuu(i))
Endfor
aKuu = Null

If Used('qryArv')
	Use In qryArv
Endif
If Used('qryArv1')
	Use In qryArv1
Endif
If Used('qryJournal')
	Use In qryJournal
Endif

Select arve_report1
Go Top

Select curEestiKuu
Locate For Id =  Month(arve_report1.kpv)

lcPeriod = Alltrim(curEestiKuu.kuu)+' ' + Str(Year(arve_report1.kpv),4)
Use In curEestiKuu
Update arve_report1 Set arvperiod = lcPeriod

&&use (cQuery) in 0 alias arve_report1
Select arve_report1
Index ON(km + STR(idx)) Tag km
Set Order To km

