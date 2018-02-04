************************************************************************************
* nfXMLread ( VFP XML PARSER  )
* Marco Plaza , 2013-2016  @nfTools
**************************************************************************************
parameters cxml,_arrayslist,xpathexp,_xpaths

#include nfxml.h
#define crlf chr(13)+chr(10)

_arrayslist = lower(','+evl(m._arrayslist,'')+',')

private all

stacklevels=astackinfo(aerrs)

if m.stacklevels > 1
	calledfrom = 'called From '+aerrs(m.stacklevels-1,4)+' line '+transform(aerrs(m.stacklevels-1,5))
else
	calledfrom = ''
endif

do case
case vartype(m.cxml) # 'C'
	error 'Must supply a valid Xml string or file name'
otherwise
	oxml = nfxmlread2( cxml,_arrayslist,xpathexp , @_xpaths )
endcase

if vartype(m.oxml) = 'O'
	if type('m.oxml.xml') = 'O'
		m.oxml = m.oxml.xml
	endif
	return m.oxml
else
	return .null.
endif


*---------------------------------------------------------------
procedure nfxmlread2( cxml,_arrayslist,xpathexp,_xpaths )
*---------------------------------------------------------------

omsxml = createobject('msXml.domdocument')
cerror = ''

with omsxml as msxml.domdocument

	.async = .f.

	if len(m.cxml) < 200 and file(m.cxml)
		.load( m.cxml )
	else
		.loadxml(m.cxml)
	endif

	if !empty(.parseerror.reason)

		cerror =  'msxml parseerror parsing XML line '+transform(.parseerror.line)+' : "'+rtrim(.parseerror.reason)+'"'
		lineno = 0

	else

		if vartype(m.xpathexp) = 'C'

			try

				oxmlnodes = .selectnodes(m.xpathexp)

			catch

				cerror =  ' invalid XPATH expression ('+m.xpathexp+')'
				lineno = 0

			endtry

		else

			oxmlnodes = .childnodes()

		endif

		if vartype(m.oxmlnodes) = 'O' and empty(m.cerror)

			try
				ovfp = createobject('empty')
				recnodo(m.oxmlnodes,m.ovfp,'',_arrayslist,@_xpaths)
			catch to oerr
				cerror = oerr.message
				lineno = oerr.lineno
			endtry

		endif


	endif

endwith

if !empty(m.cerror)
	error 'nfXML '+m.calledfrom+': '+m.cerror
	return .f.
else
	return m.ovfp
endif


*---------------------------------------------------------------------------------
procedure recnodo( onodos, esteo , _parentnode , _arrayslist , _xpaths )
*---------------------------------------------------------------------------------

private all

isarray = .f.
lastnodename = ''

for each nodo in onodos

	with nodo

		if .nodetype # 1 and .nodetype # 3
			loop
		endif

		estextnode = .nodetype = 3 or ( .childnodes.length = 1 and ( .firstchild.nodetype = 3 or .firstchild.nodetype = 4 ) )
		emptynode = .childnodes.length = 0

		tieneatributos = .attributes.length > 0

		do case
		case m.emptynode and !m.tieneatributos
			nuevovalor = ''
		case m.estextnode and !m.tieneatributos
			nuevovalor = .firstchild.nodevalue
		otherwise
			nuevovalor = createobject('empty')
		endcase

		if !m.isarray or ! .nodename == m.lastnodename

			lastnodename = .nodename
			propertyname = conv2asc(.nodename)

			if  lower(','+_parentnode+'/'+.nodename+'[]') $ m._arrayslist or .selectnodes('../'+.nodename).length >  1

				try
					addproperty(m.esteo,(m.propertyname+'(1)'))

				catch

					propertyname = '_'+m.propertyname

					addproperty(m.esteo,(m.propertyname+'(1)'))

				endtry

				esteo.&propertyname(1) = m.nuevovalor
				elemproc = 'esteo.'+m.propertyname+'(1)'
				isarray = .t.
				arrayindicator = '[]'

			else

				addproperty(m.esteo,m.propertyname,m.nuevovalor)
				elemproc = 'esteo.'+m.propertyname
				isarray = .f.
				arrayindicator = ''

			endif

		else

			nvoelem = alen(esteo.&propertyname)+1
			nelemx  = alen(esteo.&propertyname)

			dimension esteo.&propertyname( m.nvoelem )
			esteo.&propertyname( nvoelem ) = m.nuevovalor
			elemproc = 'esteo.'+m.propertyname+'('+transform(m.nvoelem)+')'

		endif

		if vartype(m._xpaths) = 'C'

			currentxpath = m._parentnode+'/'+.nodename+m.arrayindicator

			if not m.currentxpath $ m._xpaths
				_xpaths = m._xpaths+ m.currentxpath+crlf
			endif

		endif


		if m.tieneatributos

			if m.estextnode
				addproperty(&elemproc,nodetexttag,.firstchild.nodevalue)

				if vartype(m._xpaths) = 'C'
					currentxpath = m._parentnode
					if not m.currentxpath $ m._xpaths
						_xpaths = m._xpaths+m.currentxpath+crlf
					endif
				endif


			endif

			addproperty(&elemproc,attributetag,createobject('empty'))

			oa = m.elemproc+'.'+attributetag

			for each atributo in .attributes

				nombreatr = conv2asc(atributo.name)

				try
					addproperty(&oa,m.nombreatr,atributo.value)
				catch
					m.nombreatr = '_'+m.nombreatr
					addproperty(&oa,m.nombreatr,atributo.value)
				endtry

				if vartype(m._xpaths) = 'C'
					currentxpath = m._parentnode+'/'+.nodename+m.arrayindicator+'/@'+m.atributo.name
					if not m.currentxpath $ m._xpaths
						_xpaths = m._xpaths+m.currentxpath+crlf
					endif
				endif

			endfor

		endif

		if !m.estextnode and .childnodes.length > 0
			=recnodo( .childnodes(), &elemproc , _parentnode+'/'+.nodename+m.arrayindicator, _arrayslist , @_xpaths )
		endif

	endwith


endfor


*------------------------------
function conv2asc( ctag )
*------------------------------

local n

ctag = strtran(m.ctag,'_','__')

for n = 2 to escapecount*2 step 2
	m.ctag = strtran(m.ctag,getwordnum(escapelist,m.n-1,','), getwordnum(escapelist,m.n,',') )
endfor

return m.ctag
