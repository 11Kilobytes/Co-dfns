﻿:Namespace codfns
⍝ === VARIABLES ===

AF∆LIB←'cuda'

AF∆PREFIX←'/opt/arrayfire'

N∆←' ABCEFGKLMNOPSVZ'

VERSION←4 1 0

VS∆PATH←'\Program Files\Microsoft Visual Studio\2022\Community'

f∆←'ptknfsrdx'


⍝ === End of variables definition ===

(⎕IO ⎕ML ⎕WX)←0 1 3

 CC←{
   vsbat←VS∆PATH,'\VC\Auxiliary\Build\vcvarsall.bat'
   tie←{0::⎕SIGNAL ⎕EN ⋄ 22::⍵ ⎕NCREATE 0 ⋄ 0 ⎕NRESIZE ⍵ ⎕NTIE 0}
   put←{s←(¯128+256|128+'UTF-8'⎕UCS ⍺)⎕NAPPEND(t←tie ⍵)83 ⋄ 1:r←s⊣⎕NUNTIE t}
   opsys←{⍵⊃⍨'Win' 'Lin' 'Mac'⍳⊂3↑⊃'.'⎕WG'APLVersion'}
   soext←{opsys'.dll' '.so' '.dylib'}
   ccf←{' -o ''',⍵,'.',⍺,''' ''',⍵,'.c'' -laf',AF∆LIB,' > ',⍵,'.log 2>&1'}
   cci←{'-I''',AF∆PREFIX,'/include'' -L''',AF∆PREFIX,opsys''' ' '/lib64'' ' '/lib'' '}
   cco←'-std=c99 -Ofast -g -Wall -fPIC -shared -Wno-parentheses '
   cco,←'-Wno-misleading-indentation '
   ucc←{⍵⍵(⎕SH ⍺⍺,' ',cco,cci,ccf)⍵}
   gcc←'gcc'ucc'so'
   clang←'clang'ucc'dylib'
   vsco←{z←'/W3 /wd4102 /wd4275 /O2 /Zc:inline /Zi /FS /Fd"',⍵,'.pdb" '
     z,←'/WX /MD /EHsc /nologo '
     z,'/I"%AF_PATH%\include" /D "NOMINMAX" /D "AF_DEBUG" '}
   vslo←{z←'/link /DLL /OPT:REF /INCREMENTAL:NO /SUBSYSTEM:WINDOWS '
     z,←'/LIBPATH:"%AF_PATH%\lib" /OPT:ICF /ERRORREPORT:PROMPT /TLBID:1 '
     z,'/DYNAMICBASE "af',AF∆LIB,'.lib" "codfns.lib" '}
   vsc0←{~⎕NEXISTS vsbat:'VISUAL C?'⎕SIGNAL 99 ⋄ '""',vsbat,'" amd64'}
   vsc1←{' && cd "',(⊃⎕CMD'echo %CD%'),'" && cl ',(vsco ⍵),' "',⍵,'.c" '}
   vsc2←{(vslo ⍵),'/OUT:"',⍵,'.dll" > "',⍵,'.log""'}
   vsc←{⎕CMD('%comspec% /C ',vsc0,vsc1,vsc2)⍵}
   _←(⍎opsys'vsc' 'gcc' 'clang')⍺⊣⍵ put ⍺,'.c'⊣1 ⎕NDELETE f←⍺,soext ⍬
   ⎕←⍪⊃⎕NGET(⍺,'.log')1
   ⎕NEXISTS f:f ⋄ 'COMPILE ERROR'⎕SIGNAL 22}

 D2P←{0=≢⍵:⍬ ⋄ p⊣2{p[⍵]←⍺[⍺⍸⍵]}⌿⊢∘⊂⌸⍵⊣p←⍳≢⍵}

 Fix←{n NS{⍵⊣⍞←'L'}⍺ CC{⍵⊣⍞←'B'}GC{⍵⊣⍞←'G'}TT{⍵⊣⍞←'C'}a n s src←PS ⍵⊣⍞←'P'}

 GC←{
   p t k n fr sl rf fd xn sym←⍵ ⋄ A B C E F G K L M N O P S V Z←1+⍳15
     
   syms←,¨'+' '-' '×' '÷' '*' '⍟' '|' '○' '⌊' '⌈' '!'
   nams←'add' 'sub' 'mul' 'div' 'exp' 'log' 'res' 'cir' 'min' 'max' 'fac'
   syms,←,¨'<' '≤' '=' '≥' '>' '≠' '~' '∧' '∨' '⍲' '⍱'
   nams,←'lth' 'lte' 'eql' 'gte' 'gth' 'neq' 'not' 'and' 'lor' 'nan' 'nor'
   syms,←,¨'⌷' '[' '⍳' '⍴' ',' '⍪' '⌽' '⍉' '⊖' '∊' '⊃'
   nams,←'sqd' 'brk' 'iot' 'rho' 'cat' 'ctf' 'rot' 'trn' 'rtf' 'mem' 'dis'
   syms,←,¨'≡' '≢' '⊢' '⊣' '⊤' '⊥' '/' '⌿' '\' '⍀' '?'
   nams,←'eqv' 'nqv' 'rgt' 'lft' 'enc' 'dec' 'red' 'rdf' 'scn' 'scf' 'rol'
   syms,←,¨'↑' '↓' '¨' '⍨' '.' '⍤' '⍣' '∘' '∪' '∩' '←'
   nams,←'tke' 'drp' 'map' 'com' 'dot' 'rnk' 'pow' 'jot' 'unq' 'int' 'get'
   syms,←,¨'⍋' '⍒' '∘.' '⍷' '⊂' '⌹' '⎕FFT' '⎕IFFT' '%s' '⊆' '⎕CONV'
   nams,←'gdu' 'gdd' 'oup' 'fnd' 'par' 'mdv' 'fft' 'ift' 'scl' 'nst' 'conv'
   syms,←,¨'∇' ';' '%u'
   nams,←'this' 'span' ''
     
   gck←(A 1)(A 6)
   gcv←'Aa' 'As'
   gck,←(B 1)(B 2)(B 3)(B 4)
   gcv,←'Bv' 'Bf' 'Bo' 'Bo'
   gck,←(E ¯2)(E ¯1)(E 0)(E 1)(E 2)(E 4)(E 6)
   gcv,←'Ec' 'Ek' 'Er' 'Em' 'Ed' 'Eb' 'Ei'
   gck,←(F 0)(F 2)(F 3)(F 4)
   gcv,←'Fz' 'Fn' 'Fn' 'Fn'
   gck,←(G 0)(N 1)
   gcv,←'Gd' 'Na'
   gck,←(O 1)(O 2)(O 4)(O 5)(O 7)(O 8)
   gcv,←'Ov' 'Of' 'Ovv' 'Ofv' 'Ovf' 'Off'
   gck,←(P 0)(P 1)(P 2)(P 3)(P 4)
   gcv,←'Pv' 'Pv' 'Pf' 'Po' 'Po'
   gck,←(V 0)(V 1)(V 2)(V 3)(V 4)
   gcv,←'Va' 'Va' 'Vf' 'Vo' 'Vo'
   gcv,←⊂'{''/* Unhandled '',(⍕⍺),'' */'',NL}'
   NL←⎕UCS 13 10
     
   xi←⍸(t=B)∧k[rf]=0 ⋄ d i←P2D p
   I←{(⊂⍵)⌷⍺} ⋄ com←{⊃{⍺,',',⍵}/⍵} ⋄ ks←{⍵⊂[0]⍨(⊃⍵)=⍵[;0]}
   nam←{'∆'⎕R'__'∘⍕¨sym[|⍵]}
   ast←(⍉↑d p t k n(⍳≢p)fr sl fd)[i;]
   NOTFOUND←{('[GC] UNSUPPORTED NODE TYPE ',N∆[⊃⍵],⍕⊃⌽⍵)⎕SIGNAL 16}
   dis←{0=2⊃h←,1↑⍵:'' ⋄ (≢gck)=i←gck⍳⊂h[2 3]:NOTFOUND h[2 3] ⋄ h(⍎i⊃gcv)ks 1↓⍵}
   z←'#include "codfns.h"',NL
   z}

∇ Z←Help _
 Z←'Usage: <object> <target> [-af={cpu,opencl,cuda}]'
∇

∇ r←List
 r←⎕NS¨1⍴⊂⍬ ⋄ r.Name←,¨⊂'Compile' ⋄ r.Group←⊂'CODFNS'
 r[0].Desc←'Compile an object using Co-dfns'
 r.Parse←⊂'2S -af=cpu opencl cuda '
∇

 NS←{
   MKA←{mka⊂⍵} ⋄ EXA←{exa ⍬ ⍵}
   Display←{⍺←'Co-dfns' ⋄ W←w_new⊂⍺ ⋄ 777::w_del W
     w_del W⊣W ⍺⍺{w_close ⍺:⍎'⎕SIGNAL 777' ⋄ ⍺ ⍺⍺ ⍵}⍣⍵⍵⊢⍵}
   LoadImage←{⍺←1 ⋄ ~⎕NEXISTS ⍵:⎕SIGNAL 22 ⋄ loadimg ⍬ ⍵ ⍺}
   SaveImage←{⍺←'image.png' ⋄ saveimg ⍵ ⍺}
   Image←{~2 3∨.=≢⍴⍵:⎕SIGNAL 4 ⋄ (3≠⊃⍴⍵)∧3=≢⍴⍵:⎕SIGNAL 5 ⋄ ⍵⊣w_img ⍵ ⍺}
   Plot←{2≠≢⍴⍵:⎕SIGNAL 4 ⋄ ~2 3∨.=1⊃⍴⍵:⎕SIGNAL 5 ⋄ ⍵⊣w_plot(⍉⍵)⍺}
   Histogram←{⍵⊣w_hist ⍵,⍺}
   Rtm∆Init←{
     _←'w_new'⎕NA'P ',⍵,'|w_new   <C[]'
     _←'w_close'⎕NA'I ',⍵,'|w_close P'
     _←'w_del'⎕NA ⍵,'|w_del   P'
     _←'w_img'⎕NA ⍵,'|w_img   <PP P'
     _←'w_plot'⎕NA ⍵,'|w_plot  <PP P'
     _←'w_hist'⎕NA ⍵,'|w_hist  <PP F8   F8 P'
     _←'loadimg'⎕NA ⍵,'|loadimg >PP <C[] I'
     _←'saveimg'⎕NA ⍵,'|saveimg <PP <C[]'
     _←'exa'⎕NA ⍵,'|exarray >PP P'
     _←'mka'⎕NA'P ',⍵,'|mkarray <PP'
     _←'FREA'⎕NA ⍵,'|frea    P'
     _←'Sync'⎕NA ⍵,'|cd_sync'
     0 0⍴⍬}
   mkna←{⍺,'|',('∆'⎕R'__'⊢⍵),'_cdf P P P'}
   mkf←{fn←⍺,'|',('∆'⎕R'__'⊢⍵),'_dwa ' ⋄ mon dya←⍵∘,¨'_mon' '_dya'
     z←('Z←{A}',⍵,' W')(':If 0=⎕NC''⍙.',mon,'''')
     z,←(mon dya{'''',⍺,'''⍙.⎕NA''',fn,⍵,' <PP'''}¨'>PP P' '>PP <PP'),⊂':EndIf'
     z,':If 0=⎕NC''A'''('Z←⍙.',mon,' 0 0 W')':Else'('Z←⍙.',dya,' 0 A W')':EndIf'}
   ns←#.⎕NS ⍬ ⋄ _←'∆⍙'ns.⎕NS¨⊂⍬ ⋄ ∆ ⍙←ns.(∆ ⍙) ⋄ ∆.names←(0⍴⊂''),(2=1⊃⍺)⌿0⊃⍺
   fns←'Rtm∆Init' 'MKA' 'EXA' 'Display' 'LoadImage' 'SaveImage' 'Image' 'Plot'
   fns,←'Histogram' 'soext' 'opsys' 'mkna'
   _←∆.⎕FX∘⎕CR¨fns ⋄ ∆.(decls←⍵∘mkna¨names) ⋄ _←ns.⎕FX¨(⊂''),⍵∘mkf¨∆.names
   _←∆.⎕FX'Z←Init'('Z←Rtm∆Init ''',⍵,'''')'→0⌿⍨0=≢names' 'names ##.⍙.⎕NA¨decls'
   ns}

 P2D←{z←⍪⍳≢⍵ ⋄ d←⍵≠,z ⋄ _←{p⊣d+←⍵≠p←⍺[z,←⍵]}⍣≡⍨⍵ ⋄ d(⍋(-1+d)↑⍤0 1⊢⌽z)}

 PS←{IN←⍵ ⋄ A B C E F G K L M N O P S V Z←1+⍳15
   I←{(⊂⍵)⌷⍺} ⋄ U←{0=⎕NC'⍺':⍵⍵⍣¯1 ⍺⍺ ⍵⍵ ⍵ ⋄ ⍵⍵⍣¯1⊢(⍵⍵ ⍺)⍺⍺ ⍵⍵ ⍵}
   assert←{⍺←'assertion failure' ⋄ 0∊⍵:⍎'⍺ ⎕SIGNAL 8' ⋄ shy←0}
     
   1<≢⍴IN:'PARSER REQUIRES A SCALAR/VECTOR INPUT'⎕SIGNAL 11
   2<|≡IN:'PARSER REQUIRES A SIMPLE OR VECTOR OF VECTOR INPUT'⎕SIGNAL 11
   IN←∊(⊆IN),¨⎕UCS 10
   0≠10|⎕DR IN:'PARSER REQUIRES A CHARACTER ARRAY'⎕SIGNAL 11
     
     ⍝ Line and error reporting utilities
   CR LF←⎕UCS 13 10
   linestarts←(⍸1⍪2>⌿IN∊CR LF)⍪≢IN
   mkdm←{⍺←2 ⋄ line←linestarts⍸⍵ ⋄ no←'[',(⍕1+line),'] '
     i←(~IN[i]∊CR LF)⌿i←beg+⍳linestarts[line+1]-beg←linestarts[line]
     (⎕EM ⍺)(no,IN[i])(' ^'[i∊⍵],⍨' '⍴⍨≢no)}
   quotelines←{
     lines←∪linestarts⍸⍵
     nos←(1 0⍴⍨2×≢lines)⍀'[',(⍕⍪1+lines),⍤1⊢'] '
     beg←linestarts[lines] ⋄ end←linestarts[lines+1]
     m←∊∘⍵¨i←beg+⍳¨end-beg
     ¯1↓∊nos,(~∘CR LF¨⍪,(IN∘I¨i),⍪' ▔'∘I¨m),CR}
   SIGNAL←{⍺←2 '' ⋄ en msg←⍺ ⋄ EN∘←en ⋄ DM∘←en mkdm⊃⍵
     dmx←('EN'en)('Category' 'Compiler')('Vendor' 'Co-dfns')
     dmx,←⊂'Message'(msg,CR,quotelines ⍵)
     ⎕SIGNAL⊂dmx}
     
     ⍝ Group input into lines as a nested vector
   pos←(⍳≢IN)⊆⍨~IN∊CR LF
     
     ⍝ Mask strings
   0≠≢lin←⍸⊃∘⌽¨msk←≠⍀¨''''=IN∘I¨pos:{
     EM←'SYNTAX ERROR: UNBALANCED STRING',('S'⌿⍨2≤≢lin),CR
     EM,←quotelines∊(msk⌿¨pos)[lin]
     EM ⎕SIGNAL 2}⍬
     
     ⍝ Remove comments
   pos msk⌿¨⍨←⊂∧⍀¨(~msk←msk∨¯1⌽¨msk)⍲'⍝'=IN∘I¨pos
     
     ⍝ Remove leading and trailing whitespace
   WS←⎕UCS 9 32 ⋄ pos msk⌿¨⍨←⊂~(∧⍀∨∧⍀U⌽)∘(WS∊⍨IN∘I)¨pos
     
     ⍝ Flatten and separate lines and ⋄ with Z type
   t←⊃0⍴⊂pos ⋄ t pos msk(∊,∘⍪⍨)←Z(⊃¨pos)0 ⋄ t[⍸'⋄'=IN[pos]]←Z
     
     ⍝ Tokenize Strings
   end←1+pos ⋄ t[i←⍸2<⌿0⍪msk]←C ⋄ end[i]←end[⍸2>⌿msk⍪0]
   t pos end⌿⍨←⊂(t≠0)∨~msk
     
     ⍝ Verify that all open characters are part of the valid character set
   alp←'ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz'
   alp,←'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝßàáâãäåæçèéêëìíîïðñòóôõöøùúûüþ'
   alp,←'∆⍙ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏ'
   num←⎕D
   synb←'¯[]{}()'':⍺⍵⋄;'
   syna←'⍬⎕⍞#'
   prmfs←'+-×÷|⌈⌊*⍟○!?~∧∨⍲⍱<≤=>≥≠≡≢⍴,⍪⌽⊖⍉↑↓⊂⊆⊃∊⍷∩∪⍳⍸⌷⍋⍒⍎⍕⊥⊤⊣⊢⌹∇←→'
   prmdo←'∘.⍣⍠⌺⍤⍥@' ⋄ prmmo←'¨⍨&⌶⌸' ⋄ prmfo←'/⌿\⍀'
   prms←prmfs,prmdo,prmmo,prmfo
   x←' '@{t≠0}IN[pos] ⍝ The spaces produce nice invariants
   ∨⌿msk←~x∊alp,num,syna,synb,prms,WS:{
     EM←'SYNTAX ERROR: INVALID CHARACTER(S) IN SOURCE',CR
     EM,←quotelines⍸msk
     EM ⎕SIGNAL 2}⍬
     
     ⍝ Tokenize numbers
   _←{dm[⍵]←∧⍀dm[⍵]}¨(dm∨x∊alp)⊆⍳≢dm←x∊num
   dm∨←('.'=x)∧(¯1⌽dm)∨1⌽dm
   dm∨←('¯'=x)∧1⌽dm
   dm∨←(x∊'EeJj')∧(¯1⌽dm)∧1⌽dm
   ∨⌿msk←(dm=0)∧x='¯':2 'ORPHANED ¯'SIGNAL pos⌿⍨msk
   ∨⌿{1<+⌿⍵='j'}¨dp←⎕C¨dm⊆x:'MULTIPLE J IN NUMBER'⎕SIGNAL 2
   ∨⌿{1<+⌿⍵='e'}¨dp←⊃⍪/{⍵⊆⍨⍵≠'j'}¨dp:'MULTIPLE E IN NUMBER'⎕SIGNAL 2
   ∨⌿'e'=⊃¨dp:'MISSING MANTISSA'⎕SIGNAL 2
   ∨⌿'e'=⊃∘⌽¨dp:'MISSING EXPONENT'⎕SIGNAL 2
   mn ex←↓⍉↑{2↑(⍵⊆⍨⍵≠'e'),⊂''}¨dp
   ∨⌿{1<+⌿'.'=⍵}¨mn,ex:'MULTIPLE . IN NUMBER'⎕SIGNAL 2
   ∨⌿'.'∊¨ex:'REAL NUMBER IN EXPONENT'⎕SIGNAL 2
   ∨⌿{∨⌿1↓⍵∊'¯'}¨mn,ex:'MISPLACED ¯'⎕SIGNAL 2
   t[i←⍸2<⌿0⍪dm]←N ⋄ end[i]←end⌿⍨2>⌿dm⍪0
     
     ⍝ Tokenize Variables
   t[i←⍸2<⌿0⍪vm←(~dm)∧x∊alp,num]←V ⋄ end[i]←end⌿⍨2>⌿vm⍪0
     
     ⍝ Tokenize ⍺, ⍵ formals
   fm←{mm←⌽⊃(>∘⊃,⊢)⌿⌽m←⍺=' ',⍵ ⋄ 1↓¨(mm∧~m1)(mm∧m1←1⌽m)}
   am aam←'⍺'fm x ⋄ wm wwm←'⍵'fm x
   ((am∨wm)⌿t)←A ⋄ ((aam∨wwm)⌿t)←P ⋄ ((aam∨wwm)⌿end)←end⌿⍨¯1⌽aam∨wwm
     
     ⍝ Tokenize Primitives, Atoms
   t[⍸(~dm)∧x∊prms]←P ⋄ t[⍸x∊syna]←A
     
     ⍝ Compute dfns regions and type, include } as a child
   t[⍸'{'=x]←F ⋄ 0≠⊃d←¯1⌽+⍀1 ¯1 0['{}'⍳x]:'UNBALANCED DFNS'⎕SIGNAL 2
     
     ⍝ Check for out of context dfns formals
   ∨⌿(d=0)∧(t=P)∧IN[pos]∊'⍺⍵':'DFN FORMAL REFERENCED OUTSIDE DFNS'⎕SIGNAL 2
     
     ⍝ Compute trad-fns regions
   ∨⌿Z≠t⌿⍨1⌽msk←(d=0)∧'∇'=x:'TRAD-FNS START/END LINES MUST BEGIN WITH ∇'⎕SIGNAL 2
   0≠⊃tm←¯1⌽≠⍀(d=0)∧'∇'=x:'UNBALANCED TRAD-FNS'⎕SIGNAL 2
   ∨⌿Z≠t⌿⍨⊃1 ¯1∨.⌽⊂(2>⌿tm)⍪0:'TRAD-FNS END LINE MUST CONTAIN ∇ ALONE'⎕SIGNAL 2
     
     ⍝ Identify Label colons versus others
   t[⍸tm∧(d=0)∧∊((~⊃)∧(<⍀∨⍀))¨':'=(t=Z)⊂IN[pos]]←L
     
     ⍝ Tokenize Keywords
   ki←⍸(t=0)∧(d=0)∧(':'=IN[pos])∧1⌽t=V
   t[ki]←K ⋄ end[ki]←end[ki+1] ⋄ t[ki+1]←0
   ERR←'EMPTY COLON IN NON-DFNS CONTEXT, EXPECTED LABEL OR KEYWORD'
   ∨⌿(t=0)∧(d=0)∧':'=IN[pos]:ERR ⎕SIGNAL 2
     
     ⍝ Tokenize System Variables
   si←⍸('⎕'=IN[pos])∧1⌽t=V
   t[si]←S ⋄ end[si]←end[si+1] ⋄ t[si+1]←0
     
     ⍝ Delete all characters we no longer need from the tree
   d tm t pos end(⌿⍨)←⊂(t≠0)∨x∊'()[]{}:;'
     
     ⍝ Tokenize Labels
   ERR←'LABEL MUST CONSIST OF A SINGLE NAME'
   ∨⌿(Z≠t[li-1])∨(V≠t[li←⍸1⌽msk←t=L]):ERR ⎕SIGNAL 2
   t[li]←L ⋄ end[li]←end[li+1]
   d tm t pos end(⌿⍨)←⊂~msk
     
     ⍝ Now that all compound data is tokenized, reify n field before tree-building
   n←{1↓⍎¨'0',⍵}@{t=N}(⊂'')@{t∊Z F}1 ⎕C@{t∊K S}IN∘I¨pos+⍳¨end-pos
     
     ⍝ Verify that keywords are defined and scoped correctly
   KW←'NAMESPACE' 'ENDNAMESPACE' 'END' 'IF' 'ELSEIF' 'ANDIF' 'ORIF' 'ENDIF'
   KW,←'WHILE' 'ENDWHILE' 'UNTIL' 'REPEAT' 'ENDREPEAT' 'LEAVE' 'FOR' 'ENDFOR'
   KW,←'IN' 'INEACH' 'SELECT' 'ENDSELECT' 'CASE' 'CASELIST' 'ELSE' 'WITH'
   KW,←'ENDWITH' 'HOLD' 'ENDHOLD' 'TRAP' 'ENDTRAP' 'GOTO' 'RETURN' 'CONTINUE'
   KW,←'SECTION' 'ENDSECTION' 'DISPOSABLE' 'ENDDISPOSABLE'
   KW,¨⍨←':'
   msk←~KW∊⍨kws←n⌿⍨km←t=K
   ∨⌿msk:('UNRECOGNIZED KEYWORD ',kws⊃⍨⊃⍸msk)⎕SIGNAL 2
   msk←kws∊':NAMESPACE' ':ENDNAMESPACE'
   ∨⌿msk∧km⌿tm:'NAMESPACE SCRIPTS MUST APPEAR AT THE TOP LEVEL'⎕SIGNAL 2
   msk←kws∊KW~':NAMESPACE' ':ENDNAMESPACE' ':SECTION' ':ENDSECTION'
   ∨⌿msk←msk∧~km⌿tm:{msg←2 'STRUCTURED STATEMENTS MUST APPEAR WITHIN TRAD-FNS'
     msg SIGNAL∊{x+⍳end[⍵]-x←pos[⍵]}¨⍸km⍀msk}⍬
     
     ⍝ Verify system variables are valid
   SYSV←,¨'Á' 'A' 'AI' 'AN' 'AV' 'AVU' 'BASE' 'CT' 'D' 'DCT' 'DIV' 'DM'
   SYSV,←,¨'DMX' 'EXCEPTION' 'FAVAIL' 'FNAMES' 'FNUMS' 'FR' 'IO' 'LC' 'LX'
   SYSV,←,¨'ML' 'NNAMES' 'NNUMS' 'NSI' 'NULL' 'PATH' 'PP' 'PW' 'RL' 'RSI'
   SYSV,←,¨'RTL' 'SD' 'SE' 'SI' 'SM' 'STACK' 'TC' 'THIS' 'TID' 'TNAME' 'TNUMS'
   SYSV,←,¨'TPOOL' 'TRACE' 'TRAP' 'TS' 'USING' 'WA' 'WSID' 'WX' 'XSI'
   SYSF←,¨'ARBIN' 'ARBOUT' 'AT' 'C' 'CLASS' 'CLEAR' 'CMD' 'CONV' 'CR' 'CS' 'CSV'
   SYSF,←,¨'CY' 'DF' 'DL' 'DQ' 'DR' 'DT' 'ED' 'EM' 'EN' 'EX' 'EXPORT'
   SYSF,←,¨'FAPPEND' 'FCHK' 'FCOPY' 'FCREATE' 'FDROP' 'FERASE' 'FFT' 'IFFT'
   SYSF,←,¨'FHIST' 'FHOLD' 'FIX' 'FLIB' 'FMT' 'FPROPS' 'FRDAC' 'FRDCI' 'FREAD'
   SYSF,←,¨'FRENAME' 'FREPLACE' 'FRESIZE' 'FSIZE' 'FSTAC' 'FSTIE' 'FTIE'
   SYSF,←,¨'FUNTIE' 'FX' 'INSTANCES' 'JSON' 'KL' 'LOAD' 'LOCK' 'MAP' 'MKDIR'
   SYSF,←,¨'MONITOR' 'NA' 'NAPPEND' 'NC' 'NCOPY' 'NCREATE' 'NDELETE' 'NERASE'
   SYSF,←,¨'NEW' 'NEXISTS' 'NGET' 'NINFO' 'NL' 'NLOCK' 'NMOVE' 'NPARTS'
   SYSF,←,¨'NPUT' 'NQ' 'NR' 'NREAD' 'NRENAME' 'NREPLACE' 'NRESIZE' 'NS'
   SYSF,←,¨'NSIZE' 'NTIE' 'NUNTIE' 'NXLATE' 'OFF' 'OR' 'PFKEY' 'PROFILE'
   SYSF,←,¨'REFS' 'SAVE' 'SH' 'SHADOW' 'SIGNAL' 'SIZE' 'SR' 'SRC' 'STATE'
   SYSF,←,¨'STOP' 'SVC' 'SVO' 'SVQ' 'SVR' 'SVS' 'TCNUMS' 'TGET' 'TKILL' 'TPUT'
   SYSF,←,¨'TREQ' 'TSYNC' 'UCS' 'VR' 'VFI' 'WC' 'WG' 'WN' 'WS' 'XML' 'XT'
   SYSD←,¨'OPT' 'R' 'S'
   ∨⌿msk←(t=S)∧~n∊'⎕',¨SYSV,SYSF,SYSD:{
     ERR←2 'INVALID SYSTEM VARIABLE, FUNCTION, OR OPERATOR'
     ERR SIGNAL∊pos[⍵]{⍺+⍳⍵-⍺}¨end[⍵]
   }⍸msk
     
     ⍝ Compute parent vector from d
   p←D2P d
     
     ⍝ Compute nameclass of dfns
   k←2×t∊F ⋄ k[∪p⌿⍨(t=P)∧n∊⊂'⍺⍺']←3 ⋄ k[∪p⌿⍨(t=P)∧n∊⊂'⍵⍵']←4
     
     ⍝ We will often wrap a set of nodes as children under a Z node
   gz←{z←⍵↑⍨-0≠≢⍵ ⋄ ks←¯1↓⍵
     t[z]←Z ⋄ p[ks]←⊃z ⋄ pos[z]←pos[⊃⍵] ⋄ end[z]←end[⊃⌽z,ks] ⋄ z}
     
     ⍝ Nest top-level root lines as Z nodes
   _←(gz 1⌽⊢)¨(t[i]=Z)⊂i←⍸d=0
   'Non-Z top-level node'assert t[⍸p=⍳≢p]=Z:
     
     ⍝ Nest all dfns expression bodies as Z nodes
   _←p[i]{end[⍺]←end[⊃⌽⍵] ⋄ gz¨⍵⊂⍨1,¯1↓t[⍵]=Z}⌸i←⍸t[p]=F
   'Non-Z dfns body node'assert t[⍸t[p]=F]=Z:
     
     ⍝ Drop/eliminate any Z nodes that are empty or blank
   _←p[i]{msk[⍺,⍵]←~∧⌿IN[pos[⍵]]∊WS}⌸i←⍸(t[p]=Z)∧p≠⍳≢p⊣msk←t≠Z
   tm n t k pos end(⌿⍨)←⊂msk ⋄ p←(⍸~msk)(⊢-1+⍸)msk⌿p
     
     ⍝ Parse Keyword structures
   nss←n∊⊂':NAMESPACE' ⋄ nse←n∊⊂':ENDNAMESPACE'
   ERR←':NAMESPACE KEYWORD MAY ONLY APPEAR AT BEGINNING OF A LINE'
   Z∨.≠t⌿⍨1⌽nss:ERR ⎕SIGNAL 2
   ERR←'NAMESPACE DECLARATION MAY HAVE ONLY A NAME OR BE EMPTY'
   ∨⌿(Z≠t⌿⍨¯1⌽nss)∧(V≠t⌿⍨¯1⌽nss)∨Z≠t⌿⍨¯2⌽nss:ERR ⎕SIGNAL 2
   ERR←':ENDNAMESPACE KEYWORD MUST APPEAR ALONE ON A LINE'
   ∨⌿Z≠t⌿⍨⊃1 ¯1∨.⌽⊂nse:ERR ⎕SIGNAL 2
   t[nsi←⍸1⌽nss]←M ⋄ t[nei←⍸1⌽nse]←-M
   n[i]←n[1+i←⍸(t=M)∧V=1⌽t] ⋄ end[nsi]←end[nei]
   x←⍸p=⍳≢p ⋄ d←+⍀(t[x]=M)+-t[x]=-M
   0≠⊃⌽d:':NAMESPACE KEYWORD MISSING :ENDNAMESPACE PAIR'⎕SIGNAL 2
   p[x]←x[D2P ¯1⌽d]
     
     ⍝ Delete unnecessary namespace nodes from the tree, leave only M's
   msk←~nss∨((¯1⌽nss)∧t=V)∨nse∨1⌽nse
   t k n pos end⌿⍨←⊂msk ⋄ p←(⍸~msk)(⊢-1+⍸)msk⌿p
     
     ⍝ PARSE LABELS ∘∘∘
     
     ⍝ Map guard statements to (G (Z ...) (Z ...))
   _←p[i]{
     0=+⌿m←':'=IN[pos[⍵]]:⍬
     ⊃m:'EMPTY GUARD TEST EXPRESSION'⎕SIGNAL 2
     1<+⌿m:'TOO MANY GUARDS'⎕SIGNAL 2
     t[⍺]←G ⋄ p[ti←gz⊃tx cq←2↑(⊂⍬)⍪⍨⍵⊂⍨1,¯1↓m]←⍺ ⋄ k[ti]←1
     ci←≢p ⋄ p,←⍺ ⋄ t k pos end⍪←0 ⋄ n,←⊂'' ⋄ k[gz cq,ci]←1
     0}⌸i←⍸t[p[p]]=F
     
     ⍝ Parse brackets and parentheses into ¯1 and Z nodes
   _←p[i]{
     x←IN[pos[⍵]] ⋄ bd←+⍀bm←(bo←'['=x)+-bc←']'=x ⋄ pd←+⍀pm←(po←'('=x)+-pc←')'=x
     0≠⊃⌽bd:2 'UNBALANCED BRACKETS'SIGNAL pos[⍵]{x+⍳(⌈⌿⍵)-x←⌊⌿⍺}⍥{⍵⌿⍨0≠bd}end[⍵]
     0≠⊃⌽pd:2 'UNBALANCED PARENTHESES'SIGNAL pos[⍵]{x+⍳(⌈⌿⍵)-x←⌊⌿⍺}⍥{⍵⌿⍨0≠pd}end[⍵]
     (po⌿bd)∨.≠⌽pc⌿bd:'OVERLAPPING BRACKETS AND PARENTHESES'⎕SIGNAL 2
     p[⍵]←(⍺,⍵)[1+¯1@{⍵=⍳≢⍵}D2P+⍀¯1⌽bm+pm] ⋄ t[bo⌿⍵]←¯1 ⋄ t[po⌿⍵]←Z
     end[po⌿⍵]←end[⌽pc⌿⍵] ⋄ end[bo⌿⍵]←end[⌽bc⌿⍵]
     0}⌸i←⍸(t[p]=Z)∧p≠⍳≢p
   t k n pos end⌿⍨←⊂msk←~IN[pos]∊')' ⋄ p←(⍸~msk)(⊢-1+⍸)msk⌿p
     
     ⍝ Convert semi-colon indexing into Z nodes in the ¯1 nodes
   _←p[i]{k[z←⊃⍪⌿gz¨g←⍵⊂⍨¯1⌽IN[pos[⍵]]∊';]']←1 ⋄ t[z]←Z P[1=≢¨g]}⌸i←⍸t[p]=¯1
     
     ⍝ Mark bindable nodes
   bm←(t=V)∨(t=A)∧n∊,¨'⎕⍞'
   bm←{bm⊣p[i]{bm[⍺]←(V ¯1≡t[⍵])∨∧⌿bm[⍵]}⌸i←⍸(~bm[p])∧t[p]=Z}⍣≡bm
     
     ⍝ Binding nodes
   _←p[i]{
     t[⍵⌿⍨(n[⍵]∊⊂,'←')∧0,¯1↓bm[⍵]]←B
     b v←{(⊃¨x)(1↓¨x←⍵⌿⍨{t[⊃⍵]=B}¨⍵)}¯1⌽¨⍵⊂⍨1,¯1↓t[⍵]∊P B
     ∨⌿~bm[∊v]:'CANNOT BIND ASSIGNMENT VALUE'⎕SIGNAL 2
     p[⍵]←(⍺,b)[0,¯1↓+⍀t[⍵]=B]
     n[b]←n[∊v] ⋄ t[∊v]←¯7 ⋄ pos[b]←pos[∊v] ⋄ end[b]←end[⊃⌽⍵]
     0}⌸i←⍸(t[p]=Z)∧p≠⍳≢p
   t k n pos end⌿⍨←⊂msk←t≠¯7 ⋄ p←(⍸~msk)(⊢-1+⍸)msk⌿p
     
     ⍝ Mark unambiguous primitive kinds
   k[⍸(t=S)∧n∊'⎕',¨SYSV]←1 ⋄ k[⍸(t=S)∧n∊'⎕',¨SYSF]←2 ⋄ k[⍸(t=S)∧n∊'⎕',¨SYSD]←4
   t[⍸t=S]←P
   k[⍸t∊A C N]←1 ⋄ k[⍸n∊,¨prmfs]←2 ⋄ k[⍸n∊,¨prmmo]←3 ⋄ k[⍸n∊,¨prmdo]←4
   k[⍸n∊,¨prmfo]←5
   k[i←⍸msk←(n∊⊂,'∘')∧1⌽n∊⊂,'.']←3 ⋄ end[i]←end[i+1] ⋄ n[i]←⊂,'∘.'
   t k n pos end⌿⍨←⊂msk←~¯1⌽msk ⋄ p←(⍸~msk)(⊢-1+⍸)msk⌿p
     
     ⍝ Anchor variables to earliest binding in matching frame
   rf←¯1@{~t[⍵]∊F G M}p[rz←I@{~(t[⍵]=Z)∧(t[p[⍵]]∊F G M)∨p[⍵]=⍵}⍣≡⍨p]
   rf[i]←p[i←⍸t=G] ⋄ rz[i]←i ⋄ rf←rf I@{rz∊p[i]⊢∘⊃⌸i←⍸t[p]=G}rf
   mk←{⍺[⍵],⍪n[⍵]}
   fr←rf mk⊢fb←fb[⍳⍨rf mk⊢fb←fb I∘(⍳⍨)U⊖rz mk⊢fb←⍸t=B] ⋄ fb,←¯1
   vb←fb[fr⍳rf mk i]@(i←⍸t=V)⊢¯1⍴⍨≢p
   vb[i⌿⍨(rz[i]<rz[b])∨(rz[i]=rz[b])∧i≥b←vb[i←i⌿⍨vb[i]≠¯1]]←¯1
   _←{z/⍨¯1=vb[1⌷z]←fb[fr⍳⍉n I@1⊢z←rf I@0⊢⍵]}⍣≡⍉{rf[⍵],⍪⍵}⍸(t=V)∧vb=¯1
   ∨⌿msk←(t=V)∧vb=¯1:{
     6 'ALL VARIABLES MUST REFERENCE A BINDING'SIGNAL∊pos[⍵]{⍺+⍳⍵-⍺}¨end[⍵]
   }⍸msk
     
     ⍝ ⍺/⍵ → V ; M → F0 ; ⍺⍺/⍵⍵ → P2
   t←V@(i←⍸(t=A)∧n∊,¨'⍺⍵')⊢F@{t=M}t ⋄ vb[i]←i ⋄ k[⍸(t=P)∧n∊'⍺⍺' '⍵⍵']←2
     
     ⍝ Infer types of bindings, groups, and variables
   z x←↓⍉p[i]{⍺ ⍵}⌸i←⍸(t[p]∊B Z)∧p≠⍳≢p
   x←{⍵⌿⍨~∧⍀t[⍵]=¯1}U⌽¨x
   0∨.=≢¨x:'BRACKET SYNTAX REQUIRES FUNCTION OR ARRAY TO ITS LEFT'⎕SIGNAL 2
   _←{
     k[msk⌿z]←k[x⌿⍨msk←(k[⊃¨x]≠0)∧1=≢¨x] ⋄ z x⌿⍨←⊂~msk
     k[z⌿⍨msk←k[⊃¨x]=4]←3 ⋄ z x⌿⍨←⊂~msk
     k[z⌿⍨msk←{(2 3 5∊⍨k[⊃⍵])∨4=(⍵,≢k)[0⍳⍨∧⍀k[⍵]=1]⌷k,0}∘⌽¨x]←2 ⋄ z x⌿⍨←⊂~msk
     k[z⌿⍨msk←k[⊃∘⌽¨x]=1]←1 ⋄ z x⌿⍨←⊂~msk
     k[i]←k[vb[i←⍸t=V]]
     ≢z}⍣(=∨0=⊣)≢z
   'FAILED TO INFER ALL BINDING TYPES'assert 0=≢z:
     
     ⍝ Strand arrays into atoms
   i←|i⊣km←0<i←i[⍋|(i,⍨←-∪p[i]),p[i←⍸t[p]∊B Z]]
   msk←(t[i]∊C N)∨msk∧⊃1 ¯1∨.⌽⊂msk←km∧(t[i]∊A C N V Z)∧k[i]=1
   np←(≢p)+⍳≢ai←i⌿⍨am←2>⌿msk⍪0 ⋄ p←(np@ai⍳≢p)[p] ⋄ p,←ai ⋄ km←2<⌿0⍪msk
   t k n pos end(⊣,I)←⊂ai ⋄ k[ai]←1 6[∨⌿¨msk⊆t[i]≠N]
   t n pos(⊣@ai⍨)←A(⊂'')(pos[km⌿i]) ⋄ p[msk⌿i]←ai[(msk←msk∧~am)⌿¯1++⍀km]
   i←⍸(t[p]=A)∧(k[p]=6)∧t=N
   p,←i ⋄ t k n pos end(⊣,I)←⊂i ⋄ t k n(⊣@i⍨)←A 1(⊂'')
     
     ⍝ PARSE B←D...
     ⍝ PARSE B←...D
     
     ⍝ Rationalize F[X]
   _←p[i]{
     ⊃m←t[⍵]=¯1:'SYNTAX ERROR:NOTHING TO INDEX'⎕SIGNAL 2
     k[⍵⌿⍨m∧¯1⌽(k[⍵]∊2 3 5)∨¯1⌽k[⍵]=4]←4
     0}⌸i←⍸(t[p]∊B Z)∧(p≠⍳≢p)∧k[p]∊1 2
   i←⍸(t=¯1)∧k=4 ⋄ j←⍸(t[p]=¯1)∧k[p]=4
   (≢i)≠≢j:{
     2 'AXIS REQUIRES SINGLE AXIS EXPRESSION'SIGNAL∊pos[⍵]+⍳¨end[⍵]-pos[⍵]
   }⊃⍪⌿{⊂⍺⌿⍨1<≢⍵}⌸p[j]
   ∨⌿msk←t[j]≠Z:{
     2 'AXIS REQUIRES NON-EMPTY AXIS EXPRESSION'SIGNAL∊pos[⍵]+⍳¨end[⍵]-pos[⍵]
   }msk⌿p[j]
   p[j]←p[i] ⋄ t[i]←P ⋄ end[i]←1+pos[i]
     
     ⍝ Group function and value expressions
   i km←⍪⌿p[i]{(⍺⍪⍵)(0,1∨⍵)}⌸i←⍸(t[p]∊B Z)∧(p≠⍳≢p)∧k[p]∊1 2
     
     ⍝ Mask and verify dyadic operator right operands
   (dm←¯1⌽(k[i]=4)∧t[i]∊F P V Z)∨.∧(~km)∨k[i]∊0 3 4:{
     'MISSING RIGHT OPERAND'⎕SIGNAL 2
   }⍬
     
     ⍝ Refine schizophrenic types
   k[i⌿⍨(k[i]=5)∧dm∨¯1⌽(~km)∨(~dm)∧k[i]∊1 6]←2 ⋄ k[i⌿⍨k[i]=5]←3
     
     ⍝ Rationalize ∘.
   jm←(t[i]=P)∧n[i]∊⊂,'∘.'
   jm∨.∧1⌽(~km)∨k[i]∊3 4:'MISSING OPERAND TO ∘.'⎕SIGNAL 2
   p←((ji←jm⌿i)@(jj←i⌿⍨¯1⌽jm)⍳≢p)[p] ⋄ t[ji,jj]←t[jj,ji] ⋄ k[ji,jj]←k[jj,ji]
   n[ji,jj]←n[jj,ji] ⋄ pos[ji,jj]←pos[ji,ji] ⋄ end[ji,jj]←end[jj,jj]
     
     ⍝ Mask and verify monadic and dyadic operator left operands
   ∨⌿msk←(dm∧¯2⌽~km)∨(¯1⌽~km)∧mm←(k[i]=3)∧t[i]∊F P V Z:{
     2 'MISSING LEFT OPERAND'SIGNAL∊pos[⍵]+⍳¨end[⍵]-pos[⍵]
   }i⌿⍨msk
   msk←dm∨mm
     
     ⍝ Parse function expressions
   np←(≢p)+⍳xc←≢oi←msk⌿i ⋄ p←(np@oi⍳≢p)[p] ⋄ p,←oi ⋄ t k n pos end(⊣,I)←⊂oi
   p[g⌿i]←oi[(g←(~msk)∧(1⌽msk)∨2⌽dm)⌿xc-⌽+⍀⌽msk]
   p[g⌿oi]←(g←msk⌿(1⌽mm)∨2⌽dm)⌿1⌽oi ⋄ t[oi]←O ⋄ n[oi]←⊂''
   pos[oi]←pos[g⌿i][msk⌿¯1++⍀g←(~msk)∧(1⌽mm)∨2⌽dm]
   ol←1+(k[i⌿⍨(2⌽mm)∨3⌽dm]=4)∨k[i⌿⍨(1⌽mm)∨2⌽dm]∊2 3
   or←(msk⌿dm)⍀1+k[dm⌿i]=2
   k[oi]←3 3⊥↑or ol
     
     ⍝ Wrap all assignment values as Z nodes
   i km←⍪⌿p[i]{(⍺⍪⍵)(0,1∨⍵)}⌸i←⍸(t[p]∊B Z)∧(p≠⍳≢p)∧k[p]∊1
   j←i⌿⍨msk←(t[i]=P)∧n[i]∊⊂,'←' ⋄ nz←(≢p)+⍳zc←+⌿msk
   p,←nz ⋄ t k n,←zc⍴¨Z 1(⊂'') ⋄ pos,←1+pos[j] ⋄ end,←end[p[j]]
   zm←¯1⌽msk ⋄ p[km⌿i]←(zpm⌿(i×~km)+zm⍀nz)[km⌿¯1++⍀zpm←zm∨~km]
     
     ⍝ This is the definition of a function value at this point
   isfn←{(t[⍵]∊O F)∨(t[⍵]∊B P V Z)∧k[⍵]=2}
     
     ⍝ Parse modified assignment to E4(V, F, Z)
   j←i⌿⍨m←msk∧(¯1⌽isfn i)∧¯2⌽(t[i]=V)∧k[i]=1 ⋄ p[zi←nz⌿⍨msk⌿m]←j
   p[i⌿⍨(1⌽m)∨2⌽m]←2⌿j ⋄ t k(⊣@j⍨)←E 4 ⋄ pos end n{⍺[⍵]@j⊢⍺}←vi zi,⊂vi←i⌿⍨2⌽m
     
     ⍝ Parse bracket modified assignment to E4(E6, O2(F, P3(←)), Z)
   j←i⌿⍨m←msk∧(¯1⌽isfn i)∧(¯2⌽t[i]=¯1)∧¯3⌽(t[i]=V)∧k[i]=1
   p[zi←nz⌿⍨msk⌿m]←ei←i⌿⍨3⌽m ⋄ t k end(⊣@ei⍨)←E 4(end[zi])
   p t k n(⊣@(i⌿⍨2⌽m)⍨)←ei E 6(⊂'')
   p,←j ⋄ t,←P⍴⍨≢j ⋄ k,←3⍴⍨≢j ⋄ n,←(≢j)⍴⊂,'←' ⋄ pos,←pos[j] ⋄ end,←end[j]
   p t k n pos(⊣@j⍨)←ei O 2(⊂'')(pos[fi←i⌿⍨1⌽m]) ⋄ p[fi]←j
     
     ⍝ Parse bracket assignment to E4(E6, P2(←), Z)
   j←i⌿⍨m←msk∧(¯1⌽t[i]=¯1)∧¯2⌽(t[i]=V)∧k[i]=1 ⋄ p[zi←nz⌿⍨msk⌿m]←ei←i⌿⍨2⌽m
   t k end(⊣@ei⍨)←E 4(end[zi]) ⋄ p t k n(⊣@(i⌿⍨1⌽m)⍨)←ei E 6(⊂'')
   p t k(⊣@j⍨)←ei P 2
     
     ⍝ Parse modified strand assignment
     ⍝ Parse strand assignment
     
     ⍝ SELECTIVE MODIFIED ASSIGNMENT
     ⍝ SELECTIVE ASSIGNMENT
     
     ⍝ Enclose V[X;...] for expression parsing
   i←i[⍋p[i←⍸(t[p]∊B Z)∧(k[p]=1)∧p≠⍳≢p]] ⋄ j←i⌿⍨jm←t[i]=¯1
   t[j]←A ⋄ k[j]←¯1 ⋄ p[i⌿⍨1⌽jm]←j
     
     ⍝ TRAINS
     
     ⍝ Parse expression sequences
   i km←⍪⌿p[i]{(⍺⍪⍵)(0,(2≤≢⍵)∧1∨⍵)}⌸i←⍸(t[p]∊B Z)∧(k[p]=1)∧p≠⍳≢p
   msk←m2∨fm∧~¯1⌽m2←km∧(1⌽km)∧~fm←(t[i]=O)∨(t[i]≠A)∧k[i]=2
   t,←E⍴⍨xc←+⌿msk ⋄ k,←msk⌿msk+m2 ⋄ n,←xc⍴⊂''
   pos,←pos[msk⌿i] ⋄ end,←end[p[msk⌿i]]
   p,←msk⌿¯1⌽(i×~km)+km×x←¯1+(≢p)++⍀msk ⋄ p[km⌿i]←km⌿x
     
     ⍝ Rationalize V[X;...]
   i←i[⍋p[i←⍸(t[p]=A)∧k[p]=¯1]] ⋄ msk←~2≠⌿¯1,ip←p[i] ⋄ ip←∪ip ⋄ nc←2×≢ip
   t[ip]←E ⋄ k[ip]←2 ⋄ n[ip]←⊂'' ⋄ p[msk⌿i]←msk⌿(≢p)+1+2×¯1++⍀~msk
   p,←2⌿ip ⋄ t,←nc⍴P E ⋄ k,←nc⍴2 6 ⋄ n,←nc⍴,¨'[' ''
   pos,←2⌿pos[ip] ⋄ end,←∊(1+pos[ip]),⍪end[ip] ⋄ pos[ip]←pos[i⌿⍨~msk]
     
     ⍝ Sanity check
   ERR←'INVARIANT ERROR: Z node with multiple children'
   ERR assert(+⌿(t[p]=Z)∧p≠⍳≢p)=+⌿t=Z:
     
     ⍝ Count parentheses in source information
   ip←p[i←⍸(t[p]=Z)∧n[p]∊⊂,'('] ⋄ pos[i]←pos[ip] ⋄ end[i]←end[ip]
     
     ⍝ VERIFY Z/B NODE TYPES MATCH ACTUAL TYPE
     
     ⍝ Eliminate Z nodes from the tree
   zi←p I@{t[p[⍵]]=Z}⍣≡ki←⍸msk←(t[p]=Z)∧t≠Z
   p←(zi@ki⍳≢p)[p] ⋄ t k n pos end(⊣@zi⍨)←t k n pos end I¨⊂ki
   t k n pos end⌿⍨←⊂msk←~msk∨t=Z ⋄ p←(⍸~msk)(⊢-1+⍸)msk⌿p
     
     ⍝ Compute Exports
   msk←(t=B)∧k[I@{t[⍵]≠F}⍣≡⍨p]=0
   xn←(0⍴⊂''),msk⌿n ⋄ xt←msk⌿k
     
   d i←P2D p ⋄ d n t k pos end I∘⊢←⊂i ⋄ sym←∪('')(,'⍵')(,'⍺')'⍺⍺' '⍵⍵',n
   (d t k(-sym⍳n)pos end)(xn xt)sym IN}

∇ Run(C I);Convert;in;out
     ⍝ Parameters
     ⍝  AF∆LIB  ArrayFire backend to use
 Convert←{⍺(⎕SE.SALT.Load'[SALT]/lib/NStoScript -noname').ntgennscode ⍵}
 in out←I.Arguments ⋄ AF∆LIB←I.af''⊃⍨I.af≡0
 S←(⊂':Namespace ',out),2↓0 0 0 out Convert ##.THIS.⍎in
 →0⌿⍨'Compile'≢C
 {##.THIS.⍎out,'←⍵'}out Fix S⊣⎕EX'##.THIS.',out
∇

 TT←{((d t k n ss se)exp sym src)←⍵ ⋄ I←{(⊂⍵)⌷⍺}
   A B C E F G K L M N O P S V Z←1+⍳15
     
     ⍝ Compute parent vector and reference scope
   r←I@{t[⍵]≠F}⍣≡⍨p⊣2{p[⍵]←⍺[⍺⍸⍵]}⌿⊢∘⊂⌸d⊣p←⍳≢d
     
     ⍝ Lift Functions to top-level
   p,←n[i]←(≢p)+⍳≢i←⍸(t=F)∧p≠⍳≢p ⋄ t k n r(⊣,I)←⊂i ⋄ p r I⍨←⊂n[i]@i⊢⍳≢p
   t[i]←V
     
     ⍝ Wrap expressions as binding or return statements
   i←(⍸(~t∊F G)∧t[p]=F),{⍵⌿⍨2|⍳≢⍵}⍸t[p]=G ⋄ p t k n r⌿⍨←⊂m←2@i⊢1⍴⍨≢p
   p r i I⍨←⊂j←(+⍀m)-1 ⋄ n←j I@(0≤⊢)n ⋄ p[i]←j←i-1
   k[j]←-(k[r[j]]=0)∨0@({⊃⌽⍵}⌸p[j])⊢(t[j]=B)∨(t[j]=E)∧k[j]=4 ⋄ t[j]←E
     
     ⍝ Lift guard tests
   p[i]←p[x←¯1+i←{⍵⌿⍨~2|⍳≢⍵}⍸t[p]=G] ⋄ t[i,x]←t[x,i] ⋄ k[i,x]←k[x,i]
   n[x]←n[i] ⋄ p←((x,i)@(i,x)⊢⍳≢p)[p]
     
     ⍝ Count strand and indexing children
   n[⍸(t∊A E)∧k=6]←0 ⋄ n[p⌿⍨(t[p]∊A E)∧k[p]=6]+←1
     
     ⍝ Lift and flatten expressions
   p[i]←p[x←p I@{~t[p[⍵]]∊F G}⍣≡i←⍸t∊G A B E O P V] ⋄ j←(⌽i)[⍋⌽x]
   p t k n r{⍺[⍵]@i⊢⍺}←⊂j ⋄ p←(i@j⊢⍳≢p)[p]
     
     ⍝ Compute slots for each frame
   s←¯1,⍨∊⍳¨n[∪x]←⊢∘≢⌸x←0⌷⍉e←∪I∘⍋⍨rn←r[b],⍪n[b←⍸t=B]
     
     ⍝ Compute frame depths
   d←(≢p)↑d ⋄ d[i←⍸t=F]←0 ⋄ _←{z⊣d[i]+←⍵≠z←r[⍵]}⍣≡i ⋄ f←d[0⌷⍉e],¯1
     
     ⍝ Record exported top-level bindings
   xn←n⌿⍨(t=B)∧k[r]=0
     
     ⍝ Anchor variables to appropriate frame depth and slot
   v←⍸(n<¯4)∧(t=V)∨(t=E)∧k=4 ⋄ x←n[y←v,b] ⋄ n[b]←s[e⍳rn] ⋄ i←(≢x)⍴c←≢e
   _←{z/⍨c=i[1⌷z]←e⍳⍉x I@1⊢z←r I@0⊢⍵}⍣≡(v,r[b])⍪⍉⍪⍳≢x
   f s←(f s I¨⊂i)⊣@y¨⊂¯1⍴⍨≢r
     
   p t k n f s r d xn sym}

 Xml←{⍺←0 ⋄ ast←⍺{d i←P2D⊃⍵ ⋄ i∘{⍵[⍺]}¨(⊂d),1↓⍺↓⍵}⍣(0≠⍺)⊢⍵ ⋄ d t k n←4↑ast
   cls←N∆[t],¨('-..'[1+×k]),¨⍕¨|k ⋄ fld←{((≢⍵)↑3↓f∆),⍪⍵}¨↓⍉↑3↓ast
   ⎕XML⍉↑d cls(⊂'')fld}

 dwh←{⍵('┬'dlk 1)' │├┌└─'(0⌷⍉)dct,⊃⍪/((≢¨⍺),¨⊂⌈/≢∘⍉¨⍺)↑¨⍺}

 dwv←{⍵('├'dlk 0)' ─┬┌┐│'(0⌷⊢)dct(⊣⍪1↓⊢)⊃{⍺,' ',⍵}/(1+⌈/≢¨⍺){⍺↑⍵⍪⍨'│'↑⍨≢⍉⍵}¨⍺}

 lb3←{⍺←⍳≢⊃⍵
   '(',¨')',¨⍨{⍺,';',⍵}⌿⍕¨(N∆{⍺[⍵]}@2⊢(2⊃⍵){⍺[|⍵]}@{0>⍵}@4↑⊃⍵)[⍺;]}

 dct←{⍺[(2×2≠/n,0)+(1↑⍨≢m)+m+n←⌽∨\⌽m←' '≠⍺⍺ ⍵]⍵⍵ ⍵}


 dlk←{((x⌷⍴⍵)↑[x←2|1+⍵⍵]⍺),[⍵⍵]⍺⍺@(⊂0 0)⍣('┌'=⊃⍵)⊢⍵}


 pp3←{⍺←'○' ⋄ d←(⍳≢⍵)≠⍵ ⋄ _←{z⊣d+←⍵≠z←⍺[⍵]}⍣≡⍨⍵ ⋄ lbl←⍺⍴⍨≢⍵
   lyr←{i←⍸⍺=d ⋄ k v←↓⍉⍵⍵[i],∘⊂⌸i ⋄ (⍵∘{⍺[⍵]}¨v)⍺⍺¨@k⊢⍵}⍵
   (⍵=⍳≢⍵)⌿⊃⍺⍺ lyr⌿(1+⍳⌈/d),⊂⍉∘⍪∘⍕¨lbl}


:Namespace FNS
(⎕IO ⎕ML ⎕WX)←0 1 3

 Xml←{⍺←0 ⋄ ast←⍺{d i←P2D⊃⍵ ⋄ i∘{⍵[⍺]}¨(⊂d),1↓⍺↓⍵}⍣(0≠⍺)⊢⍵ ⋄ d t k n←4↑ast
   cls←N∆[t],¨('-..'[1+×k]),¨⍕¨|k ⋄ fld←{((≢⍵)↑3↓f∆),⍪⍵}¨↓⍉↑3↓ast
   ⎕XML⍉↑d cls(⊂'')fld}

 lb3←{⍺←⍳≢⊃⍵
   '(',¨')',¨⍨{⍺,';',⍵}⌿⍕¨(N∆{⍺[⍵]}@2⊢(2⊃⍵){⍺[|⍵]}@{0>⍵}@4↑⊃⍵)[⍺;]}

 pp3←{⍺←'○' ⋄ d←(⍳≢⍵)≠⍵ ⋄ _←{z⊣d+←⍵≠z←⍺[⍵]}⍣≡⍨⍵ ⋄ lbl←⍺⍴⍨≢⍵
   lyr←{i←⍸⍺=d ⋄ k v←↓⍉⍵⍵[i],∘⊂⌸i ⋄ (⍵∘{⍺[⍵]}¨v)⍺⍺¨@k⊢⍵}⍵
   (⍵=⍳≢⍵)⌿⊃⍺⍺ lyr⌿(1+⍳⌈/d),⊂⍉∘⍪∘⍕¨lbl}


:EndNamespace 
:Namespace GLOBAL
(⎕IO ⎕ML ⎕WX)←0 1 3

:EndNamespace 
:EndNamespace 
