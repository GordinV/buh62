Parameter tcKey, tcPass
Return tcPass
Local lhKeyhandle, lhExchangekeyhandle
Local lcSavetext
Local lpRoviderhandle, lcProvidername, lcContainername
Set Classlib To classes\crypapi
ocRypt = Createobject('crypapi')
With ocRypt
	lcProvidername = ''
	lcContainername = ''
	lhProviderhandle = 0
	.crEatecryptkeys(lcContainername,lcProvidername,1)
	If .geTlastapierror()<>0
		Messagebox('CSP could not be found or'+Chr(13)+Chr(10)+ ;
			'Failed to Create Key Container or'+Chr(13)+Chr(10)+ ;
			'Failed to Create Keys in CSP Container',  ;
			mb_applmodal+mb_iconexclamation+mb_ok, 'Error')
		Return .F.
	Endif
	.crYptacquirecontext(@lhProviderhandle,lcContainername, ;
		lcProvidername,1,0)
	lhKeyhandle = 0
	lhExchangekeyhandle = 0
	lcSavetext = ''
	.geTcryptsessionkeyhandle(lhProviderhandle,@lhKeyhandle,'S',Rtrim(tcKey))
	If lhKeyhandle<>0
		lcSavetext = .deCryptstr(tcPass,lhKeyhandle,.T.)
		If .geTlastapierror()=0
			lcSavetext = Strtran(lcSavetext, Chr(0), 'CHR(0)')
		Endif
		.reLeasecryptkeyhandle(lhKeyhandle)
	Endif
Endwith
Release ocRypt
Return lcSavetext
Endfunc
*
