" Vim syntax file
" Language:	Lua 5.1, Lua 5.2, Lua 5.3, Lua 5.4
" Maintainer:	Corey W <nerd1001001 'at' gmail.com>
" First Author:	Carlos Augusto Teixeira Mendes <cmendes 'at' inf puc-rio br>
" Last Change:	2020 May 8
" Options:	lua_subversion = 1, 2, 3, or 4
"               default: 3

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

if !exists("lua_subversion")
  let lua_subversion = 3
endif

syn case match

" syncing method
syn sync minlines=100

" Comments

" First line may start with #!
syn match   luaComment "\%^#!.*"
syn region  luaComment start="--" end="$" contains=luaTodo,luaDoc,@Spell

syn match luaDoc "@.*" contains=luaDoc3,luaDoc2,luaDoc1 contained transparent

syn match luaDoc1 "@\w\+"                 contained contains=luaDocAnnotation transparent
syn match luaDoc2 "@\w\+\s\+\S\+"         contained contains=luaDocAnnotation,luaDocType1 transparent
syn match luaDocType1 "\s\+\S\+"          contained

syn match luaDoc3 "@\w\+\s\+\S\+\s\+\S\+" contained contains=luaDocAnnotation,luaDocNameType transparent

syn match luaDocNameType "\S\+\s\+\S\+"   contained contains=luaDocName,luaDocType2 transparent

syn match luaDocName "\S\+\ze\s\+"        contained
syn match luaDocType2 "\s\+\S\+"          contained

syn match luaDocAnnotation "@\w\+"        contained

syn cluster luaDocComment contains=luaDoc,luaDoc1,luaDocAnnotation,luaDoc2,luaDocType1,luaDoc3,luaDocNameType,luaDocName,luaDocType2
hi def link luaDocType1 luaDocType
hi def link luaDocType2 luaDocType

syn region  luaComment matchgroup=luaComment start="--\[\z(=*\)\[" end="\]\z1\]" contains=luaTodo,@Spell
syn keyword luaTodo contained TODO FIXME XXX

" Function call
" needs to be defined before paren stuffs
syn match luaFuncCall +\zs\(\k\w*\)\ze\s*\n*\s*(+
syn match luaFuncCall +\zs\(\k\w*\)\ze\s*\n*\s*"+
syn match luaFuncCall +\zs\(\k\w*\)\ze\s*\n*\s*'+
syn match luaFuncCall +\zs\(\k\w*\)\ze\s*\n*\s*{+
syn match luaFuncCall +\zs\(\k\w*\)\ze\s*\n*\s*\[=*\[+
" function calls can have any whitespace between the func name and args
" including newlines

syn keyword luaSelf self

" catch errors caused by wrong parenthesis and wrong curly brackets or
" keywords placed outside their respective blocks
syn region luaParen      transparent                     start='(' end=')' contains=ALLBUT,@luaDocComment,luaParenError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement
syn region luaTableBlock transparent matchgroup=luaTable start="{" end="}" contains=ALLBUT,@luaDocComment,luaBraceError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement

syn match  luaParenError ")"
syn match  luaBraceError "}"
syn match  luaError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"

" function ... end
syn region luaFunctionBlock transparent matchgroup=luaFunction start="\<function\>" end="\<end\>" contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" if ... then
syn region luaIfThen transparent matchgroup=luaCond start="\<if\>" end="\<then\>"me=e-4           contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaElseifThen,luaElse,luaIn nextgroup=luaThenEnd skipwhite skipempty

" then ... end
syn region luaThenEnd contained transparent matchgroup=luaCond start="\<then\>" end="\<end\>" contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaThenEnd,luaIn

" elseif ... then
syn region luaElseifThen contained transparent matchgroup=luaCond start="\<elseif\>" end="\<then\>" contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" else
syn keyword luaElse contained else

" do ... end
syn region luaBlock transparent matchgroup=luaStatement start="\<do\>" end="\<end\>"          contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" repeat ... until
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<repeat\>" end="\<until\>"   contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaElseifThen,luaElse,luaThenEnd,luaIn

" while ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<while\>" end="\<do\>"me=e-2 contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaIn nextgroup=luaBlock skipwhite skipempty

" for ... do and for ... in ... do
syn region luaLoopBlock transparent matchgroup=luaRepeat start="\<for\>" end="\<do\>"me=e-2   contains=ALLBUT,@luaDocComment,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd nextgroup=luaBlock skipwhite skipempty

syn keyword luaIn contained in

" Strings
if lua_subversion == 1
  syn match  luaSpecial contained #\\[\\abfnrtv'"]\|\\[[:digit:]]\{,3}#
else " >=Lua 5.2
  syn match  luaSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}#
endif
syn region luaString2 matchgroup=luaString start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
syn region luaString  start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=luaSpecial,@Spell
syn region luaString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=luaSpecial,@Spell

if lua_subversion >= 4
  " local ... <attrib>
  syn match  luaLocalAttrib "<\zs\w*\ze>" containedin=luaLocalDec
  syn region luaLocalDec transparent start="\<local\>" end="\<=\>" contains=luaLocalAttrib
endif

" other keywords
syn keyword luaStatement return local break
syn keyword luaOperator and or not
syn keyword luaConstant nil
syn keyword luaConstant true false
if lua_subversion >= 2
  syn keyword luaStatement goto
  syn match luaLabel "::\I\i*::"
endif


" integer number
syn match luaNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match luaNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\=\>"
" floating point number, starting with a dot, optional exponent
syn match luaNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match luaNumber  "\<\d\+[eE][-+]\=\d\+\>"

" hex numbers
if lua_subversion == 1
  syn match luaNumber "\<0[xX]\x\+\>"
elseif lua_subversion >= 2
  syn match luaNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
endif

syn keyword luaFunc assert collectgarbage dofile error next
syn keyword luaFunc print rawget rawset tonumber tostring type _VERSION
syn keyword luaFunc getmetatable setmetatable
syn keyword luaFunc ipairs pairs
syn keyword luaFunc pcall xpcall
syn keyword luaFunc _G loadfile rawequal require
syn keyword luaFunc load select
syn match   luaFunc /\<package\.cpath\>/
syn match   luaFunc /\<package\.loaded\>/
syn match   luaFunc /\<package\.loadlib\>/
syn match   luaFunc /\<package\.path\>/
if lua_subversion == 1
  syn keyword luaFunc getfenv setfenv
  syn keyword luaFunc loadstring module unpack
  syn match   luaFunc /\<package\.loaders\>/
  syn match   luaFunc /\<package\.preload\>/
  syn match   luaFunc /\<package\.seeall\>/
elseif lua_subversion == 2
  syn keyword luaFunc _ENV rawlen
  syn match   luaFunc /\<package\.config\>/
  syn match   luaFunc /\<package\.preload\>/
  syn match   luaFunc /\<package\.searchers\>/
  syn match   luaFunc /\<package\.searchpath\>/
  syn match   luaFunc /\<bit32\.arshift\>/
  syn match   luaFunc /\<bit32\.band\>/
  syn match   luaFunc /\<bit32\.bnot\>/
  syn match   luaFunc /\<bit32\.bor\>/
  syn match   luaFunc /\<bit32\.btest\>/
  syn match   luaFunc /\<bit32\.bxor\>/
  syn match   luaFunc /\<bit32\.extract\>/
  syn match   luaFunc /\<bit32\.lrotate\>/
  syn match   luaFunc /\<bit32\.lshift\>/
  syn match   luaFunc /\<bit32\.replace\>/
  syn match   luaFunc /\<bit32\.rrotate\>/
  syn match   luaFunc /\<bit32\.rshift\>/
elseif lua_subversion == 3
  syn keyword luaFunc _ENV rawlen
elseif lua_subversion == 4
  syn keyword luaFunc _ENV rawlen warn
  syn match luaFunc /\<coroutine\.close\>/
endif
syn match   luaFunc /\<coroutine\.running\>/
syn match   luaFunc /\<coroutine\.create\>/
syn match   luaFunc /\<coroutine\.resume\>/
syn match   luaFunc /\<coroutine\.status\>/
syn match   luaFunc /\<coroutine\.wrap\>/
syn match   luaFunc /\<coroutine\.yield\>/
syn match   luaFunc /\<string\.byte\>/
syn match   luaFunc /\<string\.char\>/
syn match   luaFunc /\<string\.dump\>/
syn match   luaFunc /\<string\.find\>/
syn match   luaFunc /\<string\.format\>/
syn match   luaFunc /\<string\.gsub\>/
syn match   luaFunc /\<string\.len\>/
syn match   luaFunc /\<string\.lower\>/
syn match   luaFunc /\<string\.rep\>/
syn match   luaFunc /\<string\.sub\>/
syn match   luaFunc /\<string\.upper\>/
syn match   luaFunc /\<string\.gmatch\>/
syn match   luaFunc /\<string\.match\>/
syn match   luaFunc /\<string\.reverse\>/
if lua_subversion == 1
  syn match luaFunc /\<table\.maxn\>/
else
  syn match luaFunc /\<table\.pack\>/
  syn match luaFunc /\<table\.unpack\>/
endif
syn match   luaFunc /\<table\.concat\>/
syn match   luaFunc /\<table\.sort\>/
syn match   luaFunc /\<table\.insert\>/
syn match   luaFunc /\<table\.remove\>/
syn match   luaFunc /\<math\.abs\>/
syn match   luaFunc /\<math\.acos\>/
syn match   luaFunc /\<math\.asin\>/
syn match   luaFunc /\<math\.atan\>/
syn match   luaFunc /\<math\.atan2\>/
syn match   luaFunc /\<math\.ceil\>/
syn match   luaFunc /\<math\.sin\>/
syn match   luaFunc /\<math\.cos\>/
syn match   luaFunc /\<math\.tan\>/
syn match   luaFunc /\<math\.deg\>/
syn match   luaFunc /\<math\.exp\>/
syn match   luaFunc /\<math\.floor\>/
syn match   luaFunc /\<math\.log\>/
syn match   luaFunc /\<math\.max\>/
syn match   luaFunc /\<math\.min\>/
syn match   luaFunc /\<math\.huge\>/
syn match   luaFunc /\<math\.fmod\>/
syn match   luaFunc /\<math\.modf\>/
if lua_subversion == 1
  syn match luaFunc /\<math\.log10\>/
endif
if lua_subversion < 3
  syn match luaFunc /\<math\.cosh\>/
  syn match luaFunc /\<math\.sinh\>/
  syn match luaFunc /\<math\.tanh\>/
  syn match luaFunc /\<math\.frexp\>/
  syn match luaFunc /\<math\.ldexp\>/
else
  syn match luaFunc /\<math\.ult\>/
  syn match luaFunc /\<math\.tointeger\>/
  syn match luaFunc /\<math\.maxinteger\>/
  syn match luaFunc /\<math\.mininteger\>/
end
syn match   luaFunc /\<math\.pow\>/
syn match   luaFunc /\<math\.rad\>/
syn match   luaFunc /\<math\.sqrt\>/
syn match   luaFunc /\<math\.random\>/
syn match   luaFunc /\<math\.randomseed\>/
syn match   luaFunc /\<math\.pi\>/
syn match   luaFunc /\<io\.close\>/
syn match   luaFunc /\<io\.flush\>/
syn match   luaFunc /\<io\.input\>/
syn match   luaFunc /\<io\.lines\>/
syn match   luaFunc /\<io\.open\>/
syn match   luaFunc /\<io\.output\>/
syn match   luaFunc /\<io\.popen\>/
syn match   luaFunc /\<io\.read\>/
syn match   luaFunc /\<io\.stderr\>/
syn match   luaFunc /\<io\.stdin\>/
syn match   luaFunc /\<io\.stdout\>/
syn match   luaFunc /\<io\.tmpfile\>/
syn match   luaFunc /\<io\.type\>/
syn match   luaFunc /\<io\.write\>/
syn match   luaFunc /\<os\.clock\>/
syn match   luaFunc /\<os\.date\>/
syn match   luaFunc /\<os\.difftime\>/
syn match   luaFunc /\<os\.execute\>/
syn match   luaFunc /\<os\.exit\>/
syn match   luaFunc /\<os\.getenv\>/
syn match   luaFunc /\<os\.remove\>/
syn match   luaFunc /\<os\.rename\>/
syn match   luaFunc /\<os\.setlocale\>/
syn match   luaFunc /\<os\.time\>/
syn match   luaFunc /\<os\.tmpname\>/
syn match   luaFunc /\<debug\.debug\>/
syn match   luaFunc /\<debug\.gethook\>/
syn match   luaFunc /\<debug\.getinfo\>/
syn match   luaFunc /\<debug\.getlocal\>/
syn match   luaFunc /\<debug\.getupvalue\>/
syn match   luaFunc /\<debug\.setlocal\>/
syn match   luaFunc /\<debug\.setupvalue\>/
syn match   luaFunc /\<debug\.sethook\>/
syn match   luaFunc /\<debug\.traceback\>/
if lua_subversion == 1
  syn match luaFunc /\<debug\.getfenv\>/
  syn match luaFunc /\<debug\.setfenv\>/
  syn match luaFunc /\<debug\.getmetatable\>/
  syn match luaFunc /\<debug\.setmetatable\>/
  syn match luaFunc /\<debug\.getregistry\>/
else
  syn match luaFunc /\<debug\.getmetatable\>/
  syn match luaFunc /\<debug\.setmetatable\>/
  syn match luaFunc /\<debug\.getregistry\>/
  syn match luaFunc /\<debug\.getuservalue\>/
  syn match luaFunc /\<debug\.setuservalue\>/
  syn match luaFunc /\<debug\.upvalueid\>/
  syn match luaFunc /\<debug\.upvaluejoin\>/
endif
if lua_subversion > 2
  syn match luaFunc /\<utf8\.char\>/
  syn match luaFunc /\<utf8\.charpattern\>/
  syn match luaFunc /\<utf8\.codepoint\>/
  syn match luaFunc /\<utf8\.codes\>/
  syn match luaFunc /\<utf8\.len\>/
  syn match luaFunc /\<utf8\.offset\>/
end

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

hi def link luaStatement	Statement
hi def link luaRepeat		Repeat
hi def link luaFor		Repeat
hi def link luaString		String
hi def link luaString2		String
hi def link luaNumber		Number
hi def link luaOperator		Operator
hi def link luaIn		Operator
hi def link luaConstant		Constant
hi def link luaCond		Conditional
hi def link luaElse		Conditional
hi def link luaFunction		Keyword
hi def link luaFuncCall         Function
hi def link luaComment		Comment
hi def link luaTodo		Todo
hi def link luaTable		Structure
hi def link luaError		Error
hi def link luaParenError	Error
hi def link luaBraceError	Error
hi def link luaSpecial		SpecialChar
hi def link luaFunc		Identifier
hi def link luaLabel		Label
hi def link luaLocalAttrib      StorageClass
hi def link luaDocAnnotation    Keyword
hi def link luaDocName          Identifier
hi def link luaDocType          Type


let b:current_syntax = "lua"

let &cpo = s:cpo_save
unlet s:cpo_save
" vim: et ts=8 sw=2