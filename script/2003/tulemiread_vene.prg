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
&&cdata = 'c:\buh50\dbase\buhdata5.dbc'
*!*	cdata = 'e:\files\buh52\dbase\buhdata5.dbc'
gnHandle = 1
gversia = 'VFP'
&&Open data (cdata)
grekv = 1
Local lError
If v_account.admin < 1
	Return .t.
Endif
CREATE cursor scrBilanss (nimetus c(254), rea c(20), konto c(20))
insert into scrBilanss (nimetus, rea, konto) values ('�����-������ ����������','1','' )
insert into scrBilanss (nimetus, rea, konto) values ('�����-���������� ����������. ���������','1.1','KK(46-1)')
insert into scrBilanss (nimetus, rea, konto) values ('�����-���������� �� ��������� �������','1.2','KK(46-2)')
insert into scrBilanss (nimetus, rea, konto) values ('�����-������ �� ������ ����������','1.3','KK(46-3)+KK(46-5)')
insert into scrBilanss (nimetus, rea, konto) values ('������ ������ �� �������������������','2','')
insert into scrBilanss (nimetus, rea, konto) values ('������ ������ �� �������������������','2.1','KK(48)')
insert into scrBilanss (nimetus, rea, konto) values ('���������� ���� � ������ �������������','2.2','KK(48-1)')
insert into scrBilanss (nimetus, rea, konto) values ('�������� ���ܨ, ��������','3','')
insert into scrBilanss (nimetus, rea, konto) values ('�����,�������� �� ������������','3.1','')
insert into scrBilanss (nimetus, rea, konto) values ('�����, �������� �� ���� ������ ','3.2','')
insert into scrBilanss (nimetus, rea, konto) values ('����� ��� �������','3.3','')
insert into scrBilanss (nimetus, rea, konto) values ('������','4','')
insert into scrBilanss (nimetus, rea, konto) values ('�����������-��������� �������','4.1','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �����','4.2','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ������ ��������','4.3','')
insert into scrBilanss (nimetus, rea, konto) values ('������ �����','4.4','')
insert into scrBilanss (nimetus, rea, konto) values ('������ ������','4.5','')
insert into scrBilanss (nimetus, rea, konto) values ('��������� ������� �� �������������������','5','')
insert into scrBilanss (nimetus, rea, konto) values ('��������������� �������','5.1','')
insert into scrBilanss (nimetus, rea, konto) values ('������������ �������','5.2','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ������������� ������� �/����������','5.3','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ������','5.4','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� �������','5.5','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ����� �����','5.6','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� �������','5.7','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ����������','5.8','')
insert into scrBilanss (nimetus, rea, konto) values ('������ ��������','5.9','')
insert into scrBilanss (nimetus, rea, konto) values ('������ ��������� ������� �� �������������������','5.10','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ������� ����','6','')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ��������','6.1','')
insert into scrBilanss (nimetus, rea, konto) values ('���������� ������','6.2','')
insert into scrBilanss (nimetus, rea, konto) values ('�����','7','')
insert into scrBilanss (nimetus, rea, konto) values ('����� ��������� ���������','7.1','')
insert into scrBilanss (nimetus, rea, konto) values ('������ ���������� ���������','7.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ ������� �� �������������������','8', '')
insert into scrBilanss (nimetus, rea, konto) values ('������, ���������� ��� ��������. ���������','8.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ ��������� ����-��','8.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('���������� ���� � ������ �������.','8.3', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ ������� ��� �����.� ���. �������','8.4', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ �� ������� � �������� ����� .������ � �������� �������','8.5', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ �������','8.6', '')
insert into scrBilanss (nimetus, rea, konto) values ('���������� ������','9', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ ������ �� ��������� � ���������� ������','9.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('���������� �������','10', '')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ���������','10.1', '')
insert into scrBilanss (nimetus, rea, konto) values ('������ ���������� �������','10.2', '')
insert into scrBilanss (nimetus, rea, konto) values ('���������','11', '')
insert into scrBilanss (nimetus, rea, konto) values ('������� �� ������������������� �����','11.1', 'REA(3)+REA(4)+REA(5)+REA(6)+REA(7)+REA(8)')
insert into scrBilanss (nimetus, rea, konto) values ('������ �� ������������������� �����','11.2', 'REA(1)+REA(2)')
insert into scrBilanss (nimetus, rea, konto) values ('������� (-������) �� �������������������','11.3', 'REA(11.2)-REA(11.1)')
insert into scrBilanss (nimetus, rea, konto) values ('������� (-������) �� ������������� ������������','11.4', 'REA(11.3)+REA(9)-REA(10)')

lError =  _alter_vfp()


*!*	Do case
*!*		Case gversia = 'VFP'
*!*			Select qryKey
*!*			Scan for mline(qryKey.connect,1) = 'FOX'
*!*				lcdata = mline(qryKey.vfp,1)
*!*				If file (lcdata)
*!*					Open data (lcdata)
*!*					lcdefault = sys(5)+sys(2003)
*!*					Set DEFAULT TO justpath (lcdata)
*!*					lError =  _alter_vfp()
*!*					Close data
*!*					Set default to (lcdefault)
*!*				Endif
*!*			Endscan
*!*			Use in qryKey
*!*		Case gversia = 'MSSQL'
*!*			=sqlexec (gnhandle,'begin transaction')
*!*			lError = _alter_mssql ()
*!*			If vartype (lError ) = 'N'
*!*				lError = iif( lError = 1,.t.,.f.)
*!*			Endif
*!*			If lError = .f.
*!*				=sqlexec (gnhandle,'rollback')
*!*			Else
*!*				=sqlexec (gnhandle,'commit')
*!*			Endif
*!*	Endcase

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
 FROM Library WHERE Library.library LIKE 'TULEM%' into cursor qry_bilanss

select qry_rekv
scan
	select scrBilanss
	scan
		wait window [kontroling..]+scrBilanss.rea timeout 1
		select qry_bilanss
		locate for alltrim(kood) = alltrim(qry_bilanss.kood) and;
			alltrim(upper(nimetus)) = alltrim(upper(qry_bilanss.nimetus))
		if !found ()
			wait window [inserting...]+scrBilanss.rea timeout 1
			
			lcString = " insert into library (rekvid, kood, nimetus, library, MUUD ) values ("+;
				str (qry_rekv.id)+",'"+ ltrim(rtrim(scrBilanss.REA))+"','"+;
				ltrim(rtrim(scrBilanss.nimetus))+"','"+;
				"TULEM%','"+ltrim(rtrim(scrBilanss.KONTO)) +"')"
			&lcString
		endif 
	endscan
endscan
use in qry_rekv
use in qry_bilanss
if used ('library')
	use in library
endif
=SETPROPVIEW()
Return

Function setpropview
	lnViews = adbobject (laView,'VIEW')
	For i = 1 to lnViews
		lError = dbsetprop(laView(i),'View','FetchAsNeeded',.t.)
	Endfor
	Return
Endproc
