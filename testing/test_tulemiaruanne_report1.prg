Close data all
grekv = 1
gVersia = 'VFP'
gnhandle = 1
glError = .f.
&&cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
&&cData = 'e:\files\buh52\dbase\buhdata5.dbc'
cData = 'c:\dbase\buhdata5.dbc'
open data (cdata)
Use menuitem IN 0
Use menubar IN 0
Use config IN 0

Set classlib to classes\classlib
oDb = createobject('db')
oDb.login = 'VLAD'
oDb.pass = ''

Create cursor curKey (versia m)
Append blank
Replace versia with 'RAAMA' in curKey
Create cursor v_account (admin int default 1)

Create cursor fltrAruanne (kpv1 d default date (year (date()),month (date()),1),;
	kpv2 d default gomonth (fltrAruanne.kpv1,1) - 1,konto c(20), deebet c(20),;
	kreedit c(20), asutusId int, kood1 int, kood2 int,;
	kood3 int, kood4 int, tunnus int)

append blank
set procedure to proc\analise_formula
set step on
do queries\tulemiaruanne_report1 with ''
set proc to
if !empty (alias())
	brow
endif
