Parameter tcWhere
lError = oDb.readFromModel('aruanned\eelarve\saldo_vordlemine', 'saldo_vordlemine', 'fltrAruanne.kpv2, gRekv', 'tmpReport')
If !lError
	Messagebox('Viga',0+16, 'Saldo võrdlemine')
	Set Step On
	Select 0
	Return .F.
Endif

Select * ;
	from tmpReport ;
	ORDER By tp ;	
	INTO Cursor saldov_report1

Use In tmpReport
Select saldov_report1
