PARAMETERS tnid, tcTsekk
*SET STEP ON 
lcString = "select mk.number, mk.kpv,  (select sum(mk1.summa) from mk1 where parentid = mk.id) as panksumma ,"+;
	" arv.number as arvnr, arv.kbmta, arv.kbm as kbmkokku, arv.summa as skokku , n.nimetus, arv1.kogus, arv1.hind, arv1.kbm, arv1.summa as reasumma,"+;
	" userid.ametnik, "+;
	 " aa.nimetus as pank, "+;
	" rekv.regkood, rekv.nimetus as asutus, rekv.aadress, rekv.kbmkood as kmkr "+;
	 " from mk left outer join arv on mk.arvid = arv.id "+;
	" inner join userid on arv.userid = userid.id "+;
	 " inner join aa on aa.id = mk.aaid "+;
	 " inner join rekv on rekv.id = mk.rekvid "+;
	" left outer join arv1 on arv.id = arv1.parentid "+;
	 " left outer join nomenklatuur n on arv1.nomid = n.id "+ ;
	" where mk.id = "+(tnId)
	
lnError = SQLEXEC(gnHandle,lcString,'qryOrder')
IF lnError < 0
	MESSAGEBOX('Viga')
	RETURN .f.
ENDIF

SELECT qryOrder
IF !EMPTY(tcTsekk)
	cReport = 'reports\mk\mk_tsekk1.frx'
	Report form (cReport)   NOCONSOLE to PRINTER 
ENDIF


*!*	SET CONSOLE OFF
*!*	SET PRINTER on
*!*	? ALLTRIM(qryOrder.asutus)
*!*	? ALLTRIM(qryOrder.aadress)
*!*	? 'Reg.nr. '+qryOrder.regkood+'/'+qryOrder.kmkr
*!*	? 'Pank:'+qryOrder.pank
*!*	? 'Teenindaja:'+qryOrder.ametnik
*!*	?
*!*	? '     Arve nr.  '+qryOrder.arvnr
*!*	?
*!*	SELECT qryOrder
*!*	SCAN
*!*	? qryOrder.nimetus+' '+(STR(qryOrder.kogus,9,2))+' '+(STR(qryOrder.hind,9,2))+' '+(STR(qryOrder.reasumma,9,2))
*!*	ENDSCAN
*!*	SELECT qryOrder
*!*	GO top
*!*	? 'Summa kokku  :' +STR(qryOrder.skokku,12,2)
*!*	? 'K�ibemaks    :'+STR(QRYoRDER.KBMKOKKU,12,2)
*!*	? 'Summa ilma kb-ta :'+ STR(QRYoRDER.kbmta,12,2)
*!*	?
*!*	? 'Tasutud kokku:'+STR(qryOrder.panksumma,12,2)
*!*	? propis(qryOrder.panksumma,'EUR')

*!*	? 'T�name'
*!*	?
*!*	?? DTOC(DATE())+' '
*!*	?? TIME()

*!*	SET PRINTER to
*!*	SET PRINTER off
USE IN qryorder
