Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif

tnId = cWhere

lError = oDb.readFromModel('ladu\varv', 'row', 'tnId, guserid', 'qryArv')

IF !lError 
	SET STEP ON 
	RETURN .f.
ENDIF

lError = oDb.readFromModel('ladu\varv', 'details', 'tnId, guserid', 'qryArv1')

IF !lError 
	SET STEP ON 
	RETURN .f.
ENDIF

tnId = qryArv.journalid

lError = oDb.readFromModel('raamatupidamine\journal', 'details', 'tnId, guserid', 'qryJournal')

Create Cursor arve_report1 (Id Int,Number c(20), kpv d, lisa c(120) null,tahtaeg d Null, asutusid Int,;
	kood c(20), uhik c(20), doklausid Int, nomid Int, hind Y, kogus Y, soodus Y, kbm Y, Summa N(14,2), kbmta N(14,2), ;
	reamuud m Null, nomnimi c(254), arvkbmta N(14,2), arvkbm N(14,2), kokku N(14,2), ;
	muud m Null, regkood c(20) null, rk c(20), journalid Int null, asutus c(254), aadress m null, ;
	email c(120) null, reamark m Null, konto c(20),;
	lausend m Null, jaak N(14,2), arvperiod c(120) null, km c(2) null, ladu c(254) NULL )


Create Cursor arve_lausend (Id Int, lausend m)


Select qryArv
Go Top

Select qryArv1
Scan
	Insert Into arve_report1 (Id, Number, kpv, lisa, tahtaeg, asutusid, kood, uhik, hind , kogus , soodus , kbm , Summa, kbmta, ;
		nomnimi ,reamark, arvkbmta, arvkbm, kokku,	regkood, rk, km,;
		journalid, asutus, aadress, jaak, muud, ladu) ;
		VALUES (qryArv.Id, qryArv.Number, qryArv.kpv, qryArv.lisa, qryArv.tahtaeg, qryArv.asutusid, qryArv1.kood, qryArv1.uhik, ;
		qryArv1.hind, qryArv1.kogus, qryArv1.soodus, qryArv1.kbm, qryArv1.Summa, qryArv1.kbmta,;
		qryArv1.nimetus, IIF(ISNULL(qryArv1.muud),'',qryArv1.muud), qryArv.kbmta, qryArv.kbm, qryArv.Summa, qryArv.kmkr, qryArv.regkood, qryArv1.km,;
		qryArv.laus_nr, qryArv.asutus, qryArv.aadress, qryArv.jaak, qryArv.muud, qryArv.ladu)
Endscan

Insert Into arve_lausend (Id) Values (qryArv.laus_nr)

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

IF USED('qryArv')
	Use In qryArv
ENDIF
IF USED('qryArv1')
	Use In qryArv1
ENDIF
IF USED('qryJournal')
	Use In qryJournal
ENDIF

Select arve_report1
Go Top

Select curEestiKuu
Locate For Id =  Month(arve_report1.kpv)

lcPeriod = Alltrim(curEestiKuu.kuu)+' ' + Str(Year(arve_report1.kpv),4)
Use In curEestiKuu
Update arve_report1 Set arvperiod = lcPeriod

&&use (cQuery) in 0 alias arve_report1
Select arve_report1
Index On km Tag km
Set Order To km

