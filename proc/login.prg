**
** login.fxp
**
*
Define Class login As dokument
	Name = "login"
	asUtusid = 0
	Userid = 0
	Width = 440
	Caption = 'Login'
	Height = 100
	AutoCenter = .T.
	ShowWindow = 2
	WindowType = 1
	AlwaysOnTop = .T.
	Key = ''
	Message = ''
	Connection = 'test_server'
	Add Object txTkasutaja As myTxt With Top = 5, Left = 100, Width = 200,  ;
		naMe = "txtKasutaja"
	Add Object txTparool As myTxt With Top = 35, Left = 100, Width = 200,  ;
		naMe = "txtParool", PasswordChar = '*'
	Add Object btNok As myBtn With Caption = '', Top = 5, Left = 325, Width =  ;
		100, Name = "btnOk", Picture = "pictures\btok.bmp"
	Add Object btNcancel As myBtn With Caption = '', Top = 40, Left = 325,  ;
		wiDth = 100, Name = "btnCancel", Picture = "pictures\btExit.bmp"
	Add Object lbLkasutaja As myLbl With Top = 5, Left = 5, Name =  ;
		"lblKasutaja", Caption = "Kasutaja nimi:"
	Add Object lbLparool As myLbl With Top = 35, Left = 5, Name =  ;
		"lblParool", Caption = "Parool:"
*
	Procedure btNok.Click
		Set Classlib To Logo
		olOgo = Createobject('logo')
		olOgo.Show()
		With Thisform
			.Visible = .F.
			ocOnnect = Newobject('connect', 'connect')
			leRror = ocOnnect.odB(Thisform.Connection, Alltrim(.txTkasutaja.Value), ;
				RTRIM(Ltrim(.txTparool.Value)),Thisform.Key,.T.)

			If leRror=.T.
				On Key Label CTRL+A Do ONKEY With ('CTRL+A')
				On Key Label CTRL+S Do ONKEY With ('CTRL+S')
				On Key Label CTRL+P Do ONKEY With ('CTRL+P')
				_Screen.Visible = .T.
			Else
				Messagebox('Vale parool või kasutaja nimi',0+16,'Login')
				Clear Events
			Endif
			Release olOgo
		Endwith
		Release Thisform
	Endproc
*
	Procedure btNcancel.Click
		Clear Events
		Release Thisform
	Endproc

	Procedure Init
		On Error Do ERR With Program(), Lineno(1)

* read and open config
		l_config = read_config()
		If !Empty(l_config)
			This.Connection = Alltrim(v_config.Name)
		Else

		Endif


	Endproc
*
	Procedure Unload
		With This
			If Empty(grEkv)
				Clear Events
			Endif
		Endwith
	Endproc
*
	Procedure viGa
		Local lcString
		This.Message = "Login ebaonestus"
		lcString = "messagebox('"+This.Message+"','Viga')"
		&lcString
		Release Thisform
	Endproc
*
Enddefine
*
