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
