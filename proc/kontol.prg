 PARAMETER tnId
 LOCAL csUccess, cmEssage, ctYyp, daLgus, dlOpp, ccOnnect, lnConn,  ;
       cvErsia, coManik
 SELECT keY
 ckEy = f_Key()
 IF VARTYPE(ckEy)<>'C'
      ckEy = ' '
 ENDIF
 lnFields = AFIELDS(akEy)
 CREATE CURSOR tmpKey FROM ARRAY akEy
 SELECT tmPkey
 APPEND FROM DBF('key') FOR id=tnId
 USE IN keY
 SELECT tmPkey
 = seCure('OFF')
 GOTO TOP
 CREATE CURSOR curkey (id INT, tyYp C (40), alGus D, loPp D, coNntype INT,  ;
        coNnect C (254), veRsia C (120), omAnik C (120), vfP C (254))
 lcTyyp = MLINE(tmPkey.tyYp, 1)
 ctYyp = deCrypt(ckEy,lcTyyp)
 caLgus = deCrypt(ckEy,MLINE(tmPkey.alGus, 1))
 caLgus = DATE(2001, 01, 01)
 clOpp = deCrypt(ckEy,MLINE(tmPkey.loPp, 1))
 clOpp = DATE(2012, 12, 31)
 lnConn = deCrypt(ckEy,MLINE(tmPkey.coNnect, 1))
 gvErsia = deCrypt(ckEy,MLINE(tmPkey.coNnect, 2))
 DO CASE
      CASE lnConn='ODBC'
           lnConn = 1
           lcPath = ''
      CASE lnConn='STRING'
           lnConn = 2
           lcPath = ''
      CASE lnConn='FOX'
           lnConn = 3
           lcPath = deCrypt(ckEy,MLINE(tmPkey.vfP, 1))
      OTHERWISE
           lnConn = 0
           lcPath = ''
 ENDCASE
 ccOnnect = deCrypt(ckEy,tmPkey.uhEnda)
 cvErsia = deCrypt(ckEy,MLINE(tmPkey.veRsia, 1))
 coManik = deCrypt(ckEy,MLINE(tmPkey.omAnik, 1))
 INSERT INTO curkey (id, tyYp, alGus, loPp, coNntype, coNnect, veRsia,  ;
        omAnik, vfP) VALUES (tnId, ctYyp, caLgus, clOpp, lnConn, ccOnnect,  ;
        cvErsia, coManik, lcPath)
 USE IN tmPkey
 DO CASE
*!*	      CASE clOpp<DATE()
*!*	           csUccess = .F.
*!*	           cmEssage = IIF(coNfig.keEl=2, 'LITSENS ON L�PPETATUD',  ;
*!*	                      '���� �������� �������� �������')
      CASE ctYyp='TRIAL' .AND. (caLgus+30)<=DATE()
           csUccess = .F.
           cmEssage = IIF(coNfig.keEl=2,  ;
                      'DEMO VERSIA, HELISTAGE 055 525880',  ;
                      '���� ������, 055 525880')
      OTHERWISE
           csUccess = .T.
           cmEssage = ''
 ENDCASE
 IF LEN(cmEssage)>1
      MESSAGEBOX(cmEssage, 'Kontrol')
 ENDIF
 RETURN csUccess
ENDFUNC
*
