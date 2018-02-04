Define Class json As Custom


	nPos=0
	nLen=0
	cJson=''
	cError=''


*
* Genera el codigo cJson para parametro que se manda
*
	Function encode(xExpr)
		Local cTipo
* Cuando se manda una arreglo,
		If Type('ALen(xExpr)')=='N'
			cTipo = 'A'
		Else
			cTipo = Vartype(xExpr)
		Endif

		Do Case
			Case cTipo=='D'
				Return '"'+Dtos(xExpr)+'"'
			Case cTipo=='N'
				Return Transform(xExpr)
			Case cTipo=='L'
				Return Iif(xExpr,'true','false')
			Case cTipo=='X'
				Return 'null'
			Case cTipo=='C'
				xExpr = Allt(xExpr)
				xExpr = Strtran(xExpr, '\', '\\' )
				xExpr = Strtran(xExpr, '/', '\/' )
				xExpr = Strtran(xExpr, Chr(9),  '\t' )
				xExpr = Strtran(xExpr, Chr(10), '\n' )
				xExpr = Strtran(xExpr, Chr(13), '\r' )
				xExpr = Strtran(xExpr, '"', '\"' )
				Return '"'+xExpr+'"'

			Case cTipo=='O'
				Local cProp, cJsonValue, cRetVal, aProp[1]
				=Amembers(aProp,xExpr)
				cRetVal = ''
				For Each cProp In aProp
*?? cProp,','
*? cRetVal
					If Type('xExpr.'+cProp)=='U' Or cProp=='CLASS'
* algunas propiedades pueden no estar definidas
* como: activecontrol, parent, etc
						Loop
					Endif
					If Type( 'ALen(xExpr.'+cProp+')' ) == 'N'
*
* es un arreglo, recorrerlo usando los [ ] y macro
*
						Local i,nTotElem
						cJsonValue = ''
						nTotElem = Eval('ALen(xExpr.'+cProp+')')
						For i=1 To nTotElem
							cmd = 'cJsonValue=cJsonValue+","+ this.encode( xExpr.'+cProp+'[i])'
							&cmd.
						Next
						cJsonValue = '[' + Substr(cJsonValue,2) + ']'
					Else
*
* es otro tipo de dato normal C, N, L
*
						cJsonValue = This.encode( Evaluate( 'xExpr.'+cProp ) )
					Endif
					If Left(cProp,1)=='_'
						cProp = Substr(cProp,2)
					Endif
					cRetVal = cRetVal + ',' + '"' + Lower(cProp) + '":' + cJsonValue
				Next
				Return '{' + Substr(cRetVal,2) + '}'

			Case cTipo=='A'
				Local valor, cRetVal
				cRetVal = ''
				For Each valor In xExpr
					cRetVal = cRetVal + ',' +  This.encode( valor )
				Next
				Return  '[' + Substr(cRetVal,2) + ']'

		Endcase

		Return ''





*
* regresa un elemento representado por la cadena json que se manda
*

	Function decode(cJson)
		Local retValue
		cJson = Strtran(cJson,Chr(9),'')
		cJson = Strtran(cJson,Chr(10),'')
		cJson = Strtran(cJson,Chr(13),'')
		cJson = This.fixUnicode(cJson)
		This.nPos  = 1
		This.cJson = cJson
		This.nLen  = Len(cJson)
		This.cError = ''
		retValue = This.parsevalue()
		If Not Empty(This.cError)
			Return Null
		Endif
		If This.getToken()<>Null
			This.setError('Junk at the end of JSON input')
			Return Null
		Endif
		Return retValue


	Function parsevalue()
		Local token
		token = This.getToken()
		If token==Null
			This.setError('Nothing to parse')
			Return Null
		Endif
		Do Case
			Case token=='"'
				Return This.parseString()
			Case Isdigit(token) Or token=='-'
				Return This.parseNumber()
			Case token=='n'
				Return This.expectedKeyword('null',Null)
			Case token=='f'
				Return This.expectedKeyword('false',.F.)
			Case token=='t'
				Return This.expectedKeyword('true',.T.)
			Case token=='{'
				Return This.parseObject()
			Case token=='['
				Return This.parseArray()
			Otherwise
				This.setError('Unexpected token')
		Endcase
		Return


	Function expectedKeyword(cWord,eValue)
		For i=1 To Len(cWord)
			cChar = This.getChar()
			If cChar <> Substr(cWord,i,1)
				This.setError("Expected keyword '" + cWord + "'")
				Return ''
			Endif
			This.nPos = This.nPos + 1
		Next
		Return eValue


	Function parseObject()
		Local retval, cPropName, xValue
		retval = Createobject('myObj')
		This.nPos = This.nPos + 1 && Eat {
		If This.getToken()<>'}'
			Do While .T.
				cPropName = This.parseString()
				If Not Empty(This.cError)
					Return Null
				Endif
				If This.getToken()<>':'
					This.setError("Expected ':' when parsing object")
					Return Null
				Endif
				This.nPos = This.nPos + 1
				xValue = This.parsevalue()
				If Not Empty(This.cError)
					Return Null
				Endif
** Debug ? cPropName, type('xValue')
				retval.Set(cPropName, xValue)
				If This.getToken()<>','
					Exit
				Endif
				This.nPos = This.nPos + 1
			Enddo
		Endif
		If This.getToken()<>'}'
			This.setError("Expected '}' at the end of object")
			Return Null
		Endif
		This.nPos = This.nPos + 1
		Return retval


	Function parseArray()
		Local retval, xValue
		retval = Createobject('MyArray')
		This.nPos = This.nPos + 1	&& Eat [
		If This.getToken() <> ']'
			Do While .T.
				xValue = This.parsevalue()
				If Not Empty(This.cError)
					Return Null
				Endif
				retval.Add( xValue )
				If This.getToken()<>','
					Exit
				Endif
				This.nPos = This.nPos + 1
			Enddo
			If This.getToken() <> ']'
				This.setError('Expected ] at the end of array')
				Return Null
			Endif
		Endif
		This.nPos = This.nPos + 1
		Return retval


	Function parseString()
		Local cRetVal, c
		If This.getToken()<>'"'
			This.setError('Expected "')
			Return ''
		Endif
		This.nPos = This.nPos + 1 	&& Eat "
		cRetVal = ''
		Do While .T.
			c = This.getChar()
			If c==''
				Return ''
			Endif
			If c == '"'
				This.nPos = This.nPos + 1
				Exit
			Endif
			If c == '\'
				This.nPos = This.nPos + 1
				If (This.nPos>This.nLen)
					This.setError('\\ at the end of input')
					Return ''
				Endif
				c = This.getChar()
				If c==''
					Return ''
				Endif
				Do Case
					Case c=='"'
						c='"'
					Case c=='\'
						c='\'
					Case c=='/'
						c='/'
					Case c=='b'
						c=Chr(8)
					Case c=='t'
						c=Chr(9)
					Case c=='n'
						c=Chr(10)
					Case c=='f'
						c=Chr(12)
					Case c=='r'
						c=Chr(13)
					Otherwise
******* FALTAN LOS UNICODE
						This.setError('Invalid escape sequence in string literal')
						Return ''
				Endcase
			Endif
			cRetVal = cRetVal + c
			This.nPos = This.nPos + 1
		Enddo
		Return cRetVal


**** Pendiente numeros con E
	Function parseNumber()
		Local nStartPos,c, isInt, cNumero
		If Not ( Isdigit(This.getToken()) Or This.getToken()=='-')
			This.setError('Expected number literal')
			Return 0
		Endif
		nStartPos = This.nPos
		c = This.getChar()
		If c == '-'
			c = This.nextChar()
		Endif
		If c == '0'
			c = This.nextChar()
		Else
			If Isdigit(c)
				c = This.nextChar()
				Do While Isdigit(c)
					c = This.nextChar()
				Enddo
			Else
				This.setError('Expected digit when parsing number')
				Return 0
			Endif
		Endif

		isInt = .T.
		If c=='.'
			c = This.nextChar()
			If Isdigit(c)
				c = This.nextChar()
				isInt = .F.
				Do While Isdigit(c)
					c = This.nextChar()
				Enddo
			Else
				This.setError('Expected digit following dot comma')
				Return 0
			Endif
		Endif

		cNumero = Substr(This.cJson, nStartPos, This.nPos - nStartPos)
		Return Val(cNumero)



	Function getToken()
		Local char1
		Do While .T.
			If This.nPos > This.nLen
				Return Null
			Endif
			char1 = Substr(This.cJson, This.nPos, 1)
			If char1==' '
				This.nPos = This.nPos + 1
				Loop
			Endif
			Return char1
		Enddo
		Return



	Function getChar()
		If This.nPos > This.nLen
			This.setError('Unexpected end of JSON stream')
			Return ''
		Endif
		Return Substr(This.cJson, This.nPos, 1)

	Function nextChar()
		This.nPos = This.nPos + 1
		If This.nPos > This.nLen
			Return ''
		Endif
		Return Substr(This.cJson, This.nPos, 1)

	Function setError(cMsg)
		This.cError= 'ERROR parsing JSON at Position:'+Allt(Str(This.nPos,6,0))+' '+cMsg
		Return

	Function getError()
		Return This.cError


	Function fixUnicode(cStr)
		cStr = Strtran(cStr,'\u00e1','á')
		cStr = Strtran(cStr,'\u00e9','é')
		cStr = Strtran(cStr,'\u00ed','í')
		cStr = Strtran(cStr,'\u00f3','ó')
		cStr = Strtran(cStr,'\u00fa','ú')
		cStr = Strtran(cStr,'\u00c1','Á')
		cStr = Strtran(cStr,'\u00c9','É')
		cStr = Strtran(cStr,'\u00cd','Í')
		cStr = Strtran(cStr,'\u00d3','Ó')
		cStr = Strtran(cStr,'\u00da','Ú')
		cStr = Strtran(cStr,'\u00f1','ñ')
		cStr = Strtran(cStr,'\u00d1','Ñ')
		Return cStr



Enddefine

define class myObj as custom
Hidden ;
	ClassLibrary,Comment, ;
	BaseClass,ControlCount, ;
	Controls,Objects,Object,;
	Height,HelpContextID,Left,Name, ;
	Parent,ParentClass,Picture, ;
	Tag,Top,WhatsThisHelpID,Width
		
	function set(cPropName, xValue)
		cPropName = '_'+cPropName
		do case
		case type('ALen(xValue)')=='N'
			* es un arreglo
			local nLen,cmd,i
			this.addProperty(cPropName+'(1)')
			nLen = alen(xValue)
			cmd = 'Dimension This.'+cPropName+ ' [ '+Str(nLen,10,0)+']'
			&cmd.
			for i=1 to nLen
				cmd = 'This.'+cPropName+ ' [ '+Str(i,10,0)+'] = xValue[i]' 
				&cmd.
			next
			
		case type('this.'+cPropName)=='U'
			* la propiedad no existe, definirla
			this.addProperty(cPropName,@xValue)
			
		otherwise
			* actualizar la propiedad
			local cmd
			cmd = 'this.'+cPropName+'=xValue'
			&cmd
		endcase
	return
	
	procedure get (cPropName)
		cPropName = '_'+cPropName
		If type('this.'+cPropName)=='U'
			return ''
		Else
			local cmd
			cmd = 'return this.'+cPropName
			&cmd
		endif
	return ''

enddefine




* 
* class used to return an array
*
define class myArray as custom
	nSize = 0
	dimension array[1]

	function add(xExpr)
		this.nSize = this.nSize + 1
		dimension this.array[this.nSize]
		this.array[this.nSize] = xExpr
	return

	function get(n)
	return this.array[n]

	function getsize()
	return this.nSize

enddefine


