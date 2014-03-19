⍝ CoDfns Namespace: Increment 5

:Namespace CoDfns

  ⎕IO ⎕ML←0 1

⍝ Platform Configuration
⍝
⍝ The following variables must be set correctly for the appropriate platform

Target←'X86'
TargetTriple←'x86_64-slackware-linux-gnu'
CoDfnsRuntime←'runtime/libcodfns.so'
LLVMCore←'libLLVMCore.so'
LLVMExecutionEngine←'libLLVMExecutionEngine.so'
LLVMX86Info←'libLLVMX86Info.so'
LLVMX86CodeGen←'libLLVMX86CodeGen.so'
LLVMX86Desc←'libLLVMX86Desc.so'

⍝ Fix
⍝
⍝ Intended Function: Accept a valid namespace script and return an
⍝ equivalent namespace script, possibly exporting a module at the same
⍝ time to the file named in the optional left argument.

Fix←{
  _←FFI∆INIT                  ⍝ Initialize FFI; Fix ← Yes
  ~1≡≢⍴⍵:⎕SIGNAL 11           ⍝ Input is vector?
  ~∧/1≥≢∘⍴¨⍵:⎕SIGNAL 11       ⍝ Elements are vectors?
  ~∧/∊' '=(⊃0⍴⊂)¨⍵:⎕SIGNAL 11 ⍝ Elements are characters?
  ⍺←⊢ ⋄ obj←⍺⊣''              ⍝ Identify Obj property
  IsFnb obj:⎕SIGNAL 11        ⍝ Handle Fnb, Fnf, Fne stimuli
  mod nms←Compile ⍵           ⍝ Get LLVM Module
  ns←nms ModToNS mod          ⍝ Namespace to return
  ''≡Obj:ns                   ⍝ No optional object file output
  ns⊣obj ModToObj mod         ⍝ Export Mod to object file
}

⍝ IsFnb
⍝
⍝ Intended Function: Determine whether the given input is a valid
⍝ filename or not.

IsFnb←{
  ~(∧/∊' '=⊃0⍴⊂⍵)∧(1≡≢⍴⍵)∧(1≡≡⍵) ⍝ Is simple, character vector?
}

⍝ Compile
⍝
⍝ Intended Function: Compile the given Fix input into an LLVM Module.

Compile←{
  tks←Tokenize ⍵
  ast names←Parse   tks
  ast←KillLines     ast
  ast←DropUnreached ast
  ast←LiftConsts    ast
  ast←LiftBound     ast
  ast←AnchorVars    ast
  ast←LiftFuncs     ast
  ast←ConvPrims     ast
  mod←GenLLVM       ast
  mod names
}

⍝ ModToNS
⍝
⍝ Intended Function: Create an observationally equivalent namespace from
⍝ a given LLVM Module.

ModToNS←{
  ns←⎕NS⍬                             ⍝ Create an Empty Namespace
  _←⍎'Initialize',Target,'TargetInfo' ⍝ Setup targeting information
  _←⍎'Initialize',Target,'Target'     ⍝ Based on given Machine
  _←⍎'Initialize',Target,'TargetMC'   ⍝ Parameters in CoDfns namespace
  _←SetTarget ⍵ TargetTriple          ⍝ JIT must have machine target
  jc←1 ⍵ 0 1                          ⍝ Params: JIT Ov, Mod, OptLevel, Err Ov
  jc←CreateJITCompilerForModule jc    ⍝ Make JIT compiler
  0≠⊃jc:(ErrorMessage ⊃⌽jc)⎕SIGNAL 99 ⍝ Error handling, C style
  ee←1⊃jc                             ⍝ Extract exec engine on success
  fn←{                                ⍝ Op to build ns functions
    z←RunFunction ⍺⍺ ⍵⍵ 0 0           ⍝ Eval function in module
    z←GenericValueToPointer z         ⍝ Get something we can use
    Z←ConvertArray z                  ⍝ Get it into Dyalog format
    z⊣DisposeGenericValue z           ⍝ Clean memory and return
  }
  fp←{                                ⍝ Fn to get function pointer
    c fpv←FindFunction ee ⍵ 1         ⍝ Get function from LLVM Module
    0=c:fpv                           ⍝ Function pointer on success
    'FUNCTION NOT FOUND'⎕SIGNAL 99    ⍝ System error on failure
  }
  addf←{                              ⍝ Fn to insert func into namespace
    0=⊃⍴⍵:0                           ⍝ No name is no-op
    f←ee fn (fp ⍵)                    ⍝ Get function
    0⊣⍎'Ns.',⍵,'←f ⋄ 0'               ⍝ Store function using do oper trick
  }
  ns⊣addf¨(2=1⌷⍉⍺)/0⌷⍉⍺               ⍝ Add all functions
}

⍝ ConvertArray
⍝
⍝ Intended Function: Convert an array from the Co-dfns compiler into an
⍝ array suitable for use in the Dyalog APL Interpreter.

ConvertArray←{
  s←FFIGetSize ⍵       ⍝ Get the number of data elements
  d←⊃FFIGetDataInt s ⍵ ⍝ We assume that we have only integer types
  r←FFIGetRank ⍵       ⍝ Get the number of shape elements
  p←⊃FFIGetShape r ⍵   ⍝ Get the shapes
  p⍴d                  ⍝ Reshape based on shape
}

⍝ ModToObj
⍝
⍝ Intended Function: Generate a compiled object to the file given the LLVM Module

ModToObj←{
  r err←PrintModuleToFile ⍵ ⍺ 1     ⍝ Print to the file given
  1=r:(ErrorMessage ⊃err)⎕SIGNAL 99 ⍝ And error out with LLVM errr on failure
  0 0⍴⍬                             ⍝ Best to return something that isn't seen
}

⍝ ErrorMessage
⍝
⍝ Intended Function: Return an array of the LLVM Error Message

ErrorMessage←{
  len←strlen ⍵          ⍝ Length of C string
  res←cstring len ⍵ len ⍝ Convert using memcpy
  res⊣DisposeMessage ⍵  ⍝ Cleanup and return
}

⍝ Tokenize
⍝
⍝ Intended Function: Convert a vector of character vectors or scalars to a valid
⍝ AST with a Tokens root that is lexically equivalent modulo spaces.

Tokenize←{
  vc←'ABCDEFGHIJKLMNOPQRSTUVWXYZ_'     ⍝ Upper case characters
  vc,←'abcdefghijklmnopqrstuvwxyz'     ⍝ Lower case characters
  vc,←'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝß' ⍝ Accented upper case
  vc,←'àáâãäåæçèéêëìíîïðñòóôõöøùúûüþ'  ⍝ Accented lower case
  vc,←'∆⍙'                             ⍝ Deltas
  vc,←'ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏ'     ⍝ Underscored alphabet
  vcn←vc,nc←'0123456789'               ⍝ Numbers
  tc←'←{}:⋄+-÷×|*⍟⌈⌊<≤=≠≥>'            ⍝ Single Token characters
  ac←vcn,' ⍝',tc                       ⍝ All characters
  ~∧/ac∊⍨⊃,/⍵:⎕SIGNAL 2                ⍝ Verify we have only good characters
  i←⍵⍳¨'⍝' ⋄ t←i↑¨⍵ ⋄ c←i↓¨⍵           ⍝ Divide into comment and code
  t←((⌽∘(∨\)∘⌽¨t)∧∨\¨t←' '≠t)/¨t       ⍝ Strip leading/trailing whitespace
  nsb←t∊':Namespace' ':EndNamespace'   ⍝ Mask of Namespace tokens
  nsl←nsb/t ⋄ nsi←nsb/⍳⍴t              ⍝ Namespace lines and indices
  ti←(~nsb)/⍳⍴t ⋄ t←(~nsb)/t           ⍝ Token indices and non ns tokens
  at←{2 2⍴'name'⍵'class' 'delimiter'}  ⍝ Fn for namespace attributes
  nsl←{,⊂2 'Token' '' (at ⍵)}¨nsl      ⍝ Tokenize namespace elements
  t←{                                  ⍝ Tokenize other tokens
    0=⍴t:⍬                             ⍝ Special empty case
    t←(m/2</0,m)⊂(m←' '≠t)/t           ⍝ Split on and remove spaces
    t←{(b∨2≠/1,b←⍵∊tc)⊂⍵}¨¨t           ⍝ Split on token characters
    t←{⊃,/(⊂⍬),⍵}¨t                    ⍝ Recombine lines
    lc←+/l←≢¨t                         ⍝ Token count per line and total count
    t←⊃,/t                             ⍝ Convert to single token vector
    fc←⊃¨t                             ⍝ First character of each token
    iv←(sv←fc∊vc)/⍳lc                  ⍝ Mask and indices of variables
    ii←(si←fc∊nc)/⍳lc                  ⍝ Mask and indices of numbers
    ia←(sa←fc∊'←⋄:')/⍳lc               ⍝ Mask and indices of separators
    id←(sd←fc∊'{}')/⍳lc                ⍝ Mask and indices of delimiters
    ipm←(spm←fc∊'+-÷×|*⍟⌈⌊')/⍳lc       ⍝ Mask and indices of monadic primitives
    ipd←(spd←fc∊'<≤=≠≥>')/⍳lc          ⍝ Mask and indices of dyadic primitives
    tv←1 2∘⍴¨↓(⊂'name'),⍪sv/t          ⍝ Variable attributes
    tv←{1 4⍴2 'Variable' '' ⍵}¨tv      ⍝ Variable tokens
    ti←{'value' ⍵ 'class' 'int'}¨si/t  ⍝ Number attributes
    ti←{1 4⍴2 'Number' '' (2 2⍴⍵)}¨ti  ⍝ Number tokens
    tpm←{1 2⍴'name' ⍵}¨spm/t           ⍝ Monadic Primitive name attributes
    tpm←{⍵⍪'class' 'monadic axis'}¨tpm ⍝ Monadic Primtiive class
    tpm←{1 4⍴2 'Primitive' '' ⍵}¨tpm   ⍝ Monadic Primitive tokens
    tpd←{1 2⍴'name' ⍵}¨spd/t           ⍝ Dyadic primitive name attributes
    tpd←{⍵⍪'class' 'dyadic axis'}¨tpd  ⍝ Dyadic primitive class
    tpd←{1 4⍴2 'Primitive' '' ⍵}¨tpd   ⍝ Dyadic primitive tokens
    ta←{1 2⍴'name' ⍵}¨sa/t             ⍝ Separator name attributes
    ta←{⍵⍪'class' 'separator'}¨ta      ⍝ Separator class
    ta←{1 4⍴2 'Token' '' ⍵}¨ta         ⍝ Separator tokens
    td←{1 2⍴'name' ⍵}¨sd/t             ⍝ Delimiter name attributes
    td←{⍵⍪'class' 'delimiter'}¨td      ⍝ Delimiter class attributes
    td←{1 4⍴2 'Token' '' ⍵}¨td         ⍝ Delimiter tokens
    t←tv,ti,tpm,tpd,ta,td              ⍝ Reassemble tokens
    t←t[⍋iv,ii,ipm,ipd,ia,id]          ⍝ In the right order
    t←(⊃,/l↑¨1)⊂t                      ⍝ As vector of non-empty lines of tokens
    t←t,(+/0=l)↑⊂⍬                     ⍝ Append empty lines
    t[⍋((0≠l)/⍳⍴l),(0=l)/⍳⍴l]          ⍝ Put empty lines where they belong
  }⍬
  t←(nsl,t)[⍋nsi,ti]                   ⍝ Add the Namespace lines back
  t←c{                                 ⍝ Wrap in Line nodes
    ha←1 2⍴'comment' ⍺                 ⍝ Head comment
    h←1 4⍴1 'Line' '' ha               ⍝ Line node
    0=≢⍵:h ⋄ h⍪⊃⍪/⍵                    ⍝ Wrap it
  }¨t
  0 'Tokens' '' MtA⍪⊃⍪/t               ⍝ Create and return tokens tree
}

⍝ Utility Constants

MtA←0 2⍴⊂''           ⍝ An empty attribute table for AST
MtAST←0 4⍴0 '' '' MtA ⍝ An empty AST
MtNTE←0 2⍴'' 0        ⍝ An Empty (Name, Type) Environment

⍝ Utility Functions

⍝ Attr Prop AST: A vector of the values of a specific attribute
⍝
⍝ Prop is used to take an AST (⍵) and extract the values of
⍝ an attribute (⍺) from all the nodes in the AST. It returns a
⍝ vector of these values.

Prop←{(¯1⌽P∊⊂⍺)/P←(⊂''),,↑⍵[;3]}

⍝ AST ByElem NodeName: All nodes of the AST named NodeName
⍝
⍝ ByElem extracts a matrix of all the nodes of the AST (⍺)
⍝ by the node name (⍵).

ByElem←{(⍺[;1]∊⊂⍵)⌿⍺}

⍝ AST ByDepth Depth: All nodes of a specific depth
⍝
⍝ ByDepth obtains a matrix of all the nodes of the AST (⍺)
⍝ that have a given depth (⍵).

ByDepth←{(⍵=⍺[;0])⌿⍺}

⍝ Name Bind AST: Take the root node and attach a new name to it
⍝
⍝ Bind describes an AST (⍵) adjusted to include Name (⍺) as another
⍝ name in the 'name' attribute of the node.

Bind←{
  Ni←(A←0⌷⍉⊃0 3⌷Ast←⍵)⍳⊂'name'
  Ni≥⍴A:Ast⊣(⊃0 3⌷Ast)⍪←'name' ⍺
  Ast⊣((0 3)(Ni 1)⊃Ast){⍺,⍵,⍨' ' ''⊃⍨0=⍴⍺}←⍺
}

⍝ Comment: Currently stubbed out

Comment←{⍺}

⍝ Env VarType Var: Type of Var in Env
⍝
⍝ Gives back the type of a variable in the environment

VarType←{(⍺[;1],0)[⍺[;0]⍳⊂⍵]}

⍝ Depth Kids Ast: Children of root node of AST
⍝
⍝ Obtain subtrees of a depth relative to the depth
⍝ of the first node of the tree.

Kids←{((⍺+⊃⍵)=0⌷⍉⍵)⊂[0]⍵}

⍝ Fn Eachk AST: Each over children
⍝
⍝ Applies (cid Fn kid) where cid is the child id (1-based) and
⍝ kid is a member of 1 Kids ⍵.

Eachk←{
  km←+\(⊃=⊢)0⌷⍉k←1↓⍵ ⍝ Map of children
  (1↑⍵)⍪⊃⍪/km(⊂⍺⍺)⌸k ⍝ Must enclose the intermediate results
}

⍝ map f Sel g Sel h arg: case selection
⍝
⍝ Utility from Phil Last for doing case selection based on a
⍝ boolean map to choose which function to apply to arg.

Sel←{~∨/⍺:⍵ ⋄ g←⍵⍵⍣(⊢/⍺) ⋄ 2=⍴⍺:⍺⍺⍣(⊣/⍺)g ⍵ ⋄ (¯1↓⍺)⍺⍺ g ⍵}

⍝ Split str: Split name list on spaces

Split←' '∘(≠(/∘⊢)1,1↓¯1⌽=)⊂≠(/∘⊢)⊢

⍝ Parse
⍝
⍝ Intended Function: Convert a Tokens AST to a Namespace AST that is
⍝ structurally equivalent and that preserves comments and line counts.
⍝
⍝ Input: Tokens tree
⍝ Output: Namespace AST, Top-level Names
⍝ State: Context ← Top ⋄ Fix ← Yes ⋄ Namespace ← NOTSEEN ⋄ Eot ← No
⍝
⍝ The top-level names are an important structure. In particular, they
⍝ are a matrix of (name, type) records. The set of types are as follows:
⍝
⍝   0  Unknown Type
⍝   1  Array
⍝   2  Function
⍝   3  Monadic Operator
⍝   4  Dyadic Operator
⍝
⍝ The name should be a simple, valid APL variable in the form of a
⍝ string (that is, a simple character vector).

Parse←{
  ⍝ Potential Stimuli: Eot Nl Nse Nss Vfo Vu N ← { }
  ⍝
  ⍝ State Transitions:
  ⍝   Eot → SYNTAX ERROR → (Fix ← No)
  ⍝   Nl  → null         → ()
  ⍝   Nse → SYNTAX ERROR → (Fix ← No)
  ⍝   Nss → null         → (Namespace ← OPEN)
  ⍝   Vfo → SYNTAX ERROR → ()
  ⍝   Vu  → SYNTAX ERROR → ()
  ⍝   N   → SYNTAX ERROR → ()
  ⍝   {   → SYNTAX ERROR → ()
  ⍝   }   → SYNTAX ERROR → ()
  ⍝
  ⍝ Trace: Tables 9 and 206 in Function Specification

  ⍝ Stimuli: Eot
  ⍝ This corresponds to an empty namespace
  ⍝ This means that there are no tokens, which we can
  ⍝ check easily
  ⍝
  ⍝ Importantly, we can handle this here because there is
  ⍝ only one place that an Eot is legal, and in all other
  ⍝ cases it is a SYNTAX ERROR. Because all of the cases
  ⍝ occur in a Top level context, we can handle them all
  ⍝ here without further ado. The legal cases of Eot
  ⍝ falls out implicitly.
  ⍝
  ⍝ Trace: Table 233 in Function Specification
  0=+/⍵[;1]∊⊂'Token':⎕SIGNAL 2

  ⍝ Stimuli: Nl
  ⍝
  ⍝ Empty lines don't matter, and Nl has already been
  ⍝ parsed for us by Tokenize, so there is no need to deal
  ⍝ with this explicitly. We leave the empty or comment
  ⍝ only lines around for idempotency's sake
  ⍝
  ⍝ Trace: Table 243 in Function Specification
  ⍝
  ⍝ In the above table, we see that in all cases, the Nl
  ⍝ is a partitioning form that serves only to partition
  ⍝ the state-space of other stimuli and their possible
  ⍝ occurances. We can determine the proper result without
  ⍝ requiring explicit handling of the Nl stimuli.
  ⍝ Thus, we need to do no explicit parsing here for Nl.

  ⍝ Stimuli: Nss and Nse
  ⍝ Trace: Tables 233, 244, 245, and 206 in Function Specification
  ⍝ Properties handled: Eot and Namespace
  ⍝
  ⍝ The only cases where we may have a valid Nse the Namespace is OPEN,
  ⍝ which happens when we see an Nss. Nothing else will change this state.
  ⍝ The response of encountering an Nse token depends on the values of
  ⍝ the previous elements, and only on them, so we can trigger those errors
  ⍝ at a later time, when we care to process them. However, if we have only
  ⍝ Nss or only Nse it is clearly a SYNTAX ERROR. So, at this point, we can
  ⍝ eliminate the need to consider the Namespace property entirely by
  ⍝ parsing out the Nss and Nse tokens here. After this the only properties
  ⍝ that must be handled at the top-level Context are the Value and
  ⍝ Named properties.
  ⍝
  ⍝ Firstly, we need to test that the beginning and end are both
  ⍝ Nss and Nse tokens.
  FL←⊃1 ¯1⍪.↑⊂⍵ ByDepth 2
  ~FL[;1]∧.≡⊂'Token':⎕SIGNAL 2
  ~':Namespace' ':EndNamespace'∧.≡'name' Prop FL:⎕SIGNAL 2

  ⍝ Secondly, we must ensure that there are not more than two Nss and Nse
  ⍝ tokens combined either, or it is also a syntax error
  N←'name' Prop ⍵ ByElem 'Token'
  2≠+/N∊':Namespace' ':EndNamespace':⎕SIGNAL 2

  ⍝ Parse out the Nss and Nse tokens
  ⍝ This corresponds to lifting the tokens to part of the structure
  ⍝ This changes the root from Tokens to Namespace
  ⍝ We remove both the Line that contains the single namespace
  ⍝ token as well as the token itself. We take advantage of the
  ⍝ assumption that a namespace token must appear on a line
  ⍝ by itself.
  NS←0 'Namespace' '' (1 2⍴'name' '')
  NS⍪←⍵[1↓(⍳⊃⍴⍵)~I,¯1+I←(⊂[1]⍵)⍳⊂[1]FL;]

  ⍝ Stimuli: ⋄
  ⍝
  ⍝ The ⋄ token is treated just the same as an Nl for all intents
  ⍝ and purposes. However, the Tokenizer will not have broken these
  ⍝ out implicitly like it has for Nl due to the way the input
  ⍝ format works.
  ⍝
  ⍝ Trace: Table 219 in Function Specification
  ⍝
  ⍝ We can examine each of the cases illustrated by the above table
  ⍝ and note the same as with Nl. It thus suffices to convert all
  ⍝ ⋄ tokens to Nl lines. In the tree, converting each ⋄ Token node
  ⍝ to a Line node has this effect, and is a safe transformation
  ⍝ because a Token node has no children, and stores no additional
  ⍝ information that needs to be restored.
  ⍝
  ⍝ XXX: The following transformation does not adequately preserve
  ⍝ commenting behavior.
  I←(('name' Prop B⌿NS)∊⊂,'⋄')/(B←NS[;1]∊⊂'Token')/⍳⊃⍴NS
  NS[I;]←((⍴I),4)⍴1 'Line' '' MtA

  ⍝ Stimuli: { }
  ⍝
  ⍝ The { and } stimuli delimit only function bodies, and nothing else.
  ⍝ Moreover, they must be balanced or a syntax error occurs. It is also
  ⍝ the only valid way to continue from Funtion State 0. Because of these
  ⍝ natural features of the way that the { and } stimuli occur, this allows
  ⍝ a complete removal of them from the set of tokens early on, provided
  ⍝ that we allow for a single internal extension to the public AST
  ⍝ restriction. If we allow for lines to contain not only token values,
  ⍝ but also Function subtrees, then we can convert all { and } stimuli
  ⍝ into Function nodes that themselves contain Line nodes. This, of course,
  ⍝ works recursively.
  ⍝
  ⍝ At this point the NS variable contains a namespace tree of shallow
  ⍝ depth containing all Line nodes with various tokens in each line.
  ⍝ This gives a maximum depth of 2. We divide the basic operation into
  ⍝ two steps:
  ⍝
  ⍝ 1. Adapt all depths of the nodes to ensure that the depth of each node
  ⍝    is incremented by two for each un-closed { that appears prior to the
  ⍝    token in the token stream. Fm is the map of { and } tokens, where
  ⍝    a 1 is for any { token, and a ¯1 for any } token, and 0 for everything
  ⍝    else.
  Fm←((1⌷⍉NS)∊⊂'Token')×{1 ¯1 0⌷⍨(,¨'{}')⍳((0⌷⍉⍵)⍳⊂'name')⌷(1⌷⍉⍵),⊂''}¨3⌷⍉NS
  _←⍎'⎕SIGNAL(0≠+/Fm)/2 ⋄ ⍬ '
  NS[;0]+←2×Fd←+\0,¯1↓Fm

  ⍝ 2. Delete the { and } token nodes to insert a Function node at the
  ⍝    { token location. Additionally, insert a child node Line under the
  ⍝    Function node to hold the rest of the tokens on the same line as
  ⍝    the { token but appearing after it. Accomplished through Ci and Fi,
  ⍝    the index vectors of the Children and Function nodes, respectively.
  Fi←(1=Fm)/⍳⍴Fm ⋄ Ci←((1⌽B)∧B←0≠Fd)/⍳⍴Fd
  NS[1+Ci;]←NS[Ci;]
  NS[Fi;1+⍳3]←((⍴Fi),3)⍴'Function' '' (1 2⍴'class' 'ambivalent')
  NS[1+Fi;]←(NS[Fi;0]+1),((⍴Fi),3)⍴'Line' '' MtA

  ⍝ Now we have handled all { and } stimuli and do not need to consider
  ⍝ them again; they have been replaced with the appropriate Function
  ⍝ nodes.

  ⍝ State: Namespace ← OPEN ⋄ Eot ← No
  ⍝ Stimuli already handled by this point or that do not need handling:
  ⍝   Eot Fix Fnb Fne Fnf Nl Nse Nss Break ⋄ { }
  ⍝ Stimuli to consider: Vfo Vu N ← E Fe
  ⍝
  ⍝ At this point we have a series of abstract Line nodes which are either
  ⍝ empty, contain an expression or a function. The previous handling of
  ⍝ { and } stimuli means that we can still treat Functions as occuring
  ⍝ on a single line, and that any lines that they have inside of them are
  ⍝ "internal" to the function and do not affect the top-level.
  ⍝ If we look at the set of states in the
  ⍝ top-level (Table 206) we will see that all of the Namespace ← OPEN
  ⍝ states either error out on Nl or they return back to the
  ⍝ Namespace ← OPEN state which is right here. Thus, each line
  ⍝ can be processed individually from one another as they all just
  ⍝ come back here anyways.
  ⍝
  ⍝ Trace: Tables 11 through 22 in Function Specification dealing with
  ⍝ Fix Nss prefixes.
  ⍝
  ⍝ We rely on a helper function at this point which is designed to
  ⍝ handle all of the cases when we have a Namespace ← Open property.

  ⍝ Our overall strategy here is to reduce over the lines from top to bottom,
  ⍝ eventually resulting in our final namespace. Each call to ParseTopLine will
  ⍝ return an extended namespace and a new environment containing the bindings
  ⍝ that have been created so far.
  ⍝
  ⍝ Start with an empty AST and the function bindings at the top-level as
  ⍝ the seed value.
  SD←(0 4⍴⍬)(⊃ParseFeBindings/(1 Kids NS),⊂0 2⍴⍬)

  ⍝ We note that all sub-trees of the the main Tokens AST at this point
  ⍝ are lines.  All other nodes types are at depth 2 or greater. We assume
  ⍝ here that the tree consists of a single root node of depth 0 and that
  ⍝ there are no other depth 0 nodes appearing anywhere else.  Finally, we
  ⍝ use ParseTopLine to reduce over the lines, extracting out the final
  ⍝ namespace. At this point, the namespace will not have the appropriate
  ⍝ head on it, which we stripped off above. We put this back on to form
  ⍝ the final, correctly parsed AST. The AST is now a Namespace AST and
  ⍝ each line has been converted into an apropriate node, or left alone if
  ⍝ it is an empty line.
  NS←(1↑NS)⍪⊃A E←⊃ParseTopLine/⌽(⊂SD),1 Kids NS

  ⍝ We return the final environment created by the ParseTopLine function and
  ⍝ the final Namespace AST.
  NS E
}

⍝ ParseFeBindings
⍝
⍝ Intended Function: Describe an set of bindings which is an extension of
⍝ given binding and any function bindings introduced by the given
⍝ AST top-level node.
⍝
⍝ Right Argument: (Name, Type) Environment
⍝ Left Argument: A top-level Namespace AST child node
⍝ Output: (Name, Type) Environment
⍝ Invariant: Output extends the right argument
⍝ Invariant: Only function bindings are added

ParseFeBindings←{
  1=⊃⍴⍺:⍵
  ~'Function' 'Primitive'∨.≡⊂0(0 1)⊃⌽C←1 Kids ⍺:⍵
  ⍵⍪⍨2,⍨⍪'name'Prop{⍵⌿⍨(1⌷⍉⍵)∊⊂'Variable'}⊃⍪/1↑¨C
}

⍝ ParseTopLine
⍝
⍝ Intended Function: Given a Top-level Line sub-tree, parse it into one of
⍝ Expression, Function, or FuncExpr sub-tree at the same depth.
⍝
⍝ Right Argument: Code lines already parsed, Names environment
⍝ Left Argument: Current Line sub-tree to process
⍝ Output: (Code extended by Line, Expression, Function, or FuncExpr)
⍝         (New [name,type] environment)
⍝ Invariant: Depth of input and output sub-trees should be the same
⍝ Invariant: Comment of the line should be transferred to the output node
⍝ Invariant: Should be able to reconstruct the original input from output
⍝ State: Context ← Top ⋄ Fix ← Yes ⋄ Namespace ← OPEN ⋄ Eot ← No
⍝ Return state: Same as entry state.

ParseTopLine←{C E←⍵
  ⍝ Possible stimuli: Vfo Vu N ← E Fe
  ⍝
  ⍝ We are only considering the Value and Named states in this function.
  ⍝ That is to say, the Context, Namespace and Eot states should stay the
  ⍝ same throughout this function. While the literal stimuli that we
  ⍝ consider above are the only ones that can appear, we are also implicitly
  ⍝ dealing with the Nl stimuli.
  ⍝
  ⍝ State Transitions:
  ⍝   E        → null         → (Value ← EXPR)
  ⍝   E Nl     → null         → ()
  ⍝   Fe       → null         → (Value ← FUNC ⋄ Named ← No)
  ⍝   Fe Nl    → null         → ()
  ⍝   ←        → SYNTAX ERROR → ()
  ⍝   Vfo      → null         → (Value ← FUNC ⋄ Named ← MAYBE)
  ⍝   Vfo Nl   → null         → ()
  ⍝   Vfo ←    → null         → (Named ← BOUND)
  ⍝   Vu       → null         → (Value ← UNBOUND ⋄ Named ← MAYBE)
  ⍝   Vu Nl    → VALUE ERROR  → ()
  ⍝   Vu ←     → null         → (Named ← UNBOUND)
  ⍝
  ⍝ Trace: Tables 11-15, 18-22, 206 in Function Specification

  ⍝ Dealing with Empty Lines
  ⍝ We might have an empty line with no tokens. In this case, we can
  ⍝ just return the line, as there is nothing to do for this
  ⍝ line.
  1=⊃⍴⍺:(C⍪⍺)E

  ⍝ Regardless of what we do, we need to have the comment to put on the
  ⍝ new head of the sub-tree that we will return.
  cmt←⊃'comment' Prop 1↑⍺

  ⍝ Stimuli: E Fe
  ⍝ Stimuli indirectly processed: N { }
  ⍝
  ⍝ States to process: E, Fe, E Nl, Fe Nl, Vfo Nl, Vu Nl
  ⍝
  ⍝ The first stimuli to eliminate if possible is the recursive stimuli,
  ⍝ which, if it parses correctly, is all we need do. Since we are dealing
  ⍝ with an implicit Nl, then ParseExpr and ParseFuncExpr will give us the
  ⍝ results both for E and Fe states, but for E Nl and Fe Nl. Since these
  ⍝ are the only reasonable transitions from E and Fe states, this also means
  ⍝ that we have properly handled the E and Fe transitions from the above table.
  ⍝
  ⍝ We also have the happy situation of handling the Vfo Nl and Vu Nl states, as
  ⍝ both of these are really subsumed members of the set of parses of E Nl and Fe Nl.
  ⍝ Thus we can eliminate these states as well from needing further treatment.
  ⍝ We are not quite done with the handling fo the Vu and Vfo states, however, as
  ⍝ the state-space clearly has more to handle as can be seen from the above table.
  0=⊃eerr ast Ne←E ParseExpr 1↓⍺:(C⍪ast Comment cmt)Ne
  0=⊃ferr ast rst←E ParseFuncExpr 1↓⍺:(C⍪ast Comment cmt)E

  ⍝ At this point we have only to deal with variables. This happens to be a situation
  ⍝ that we encounter fairly often, so we abstract this into another function.
  ⍝ All possible environment changes have already been handled by ParseFeBindings.
  0=⊃err ast←E 0 ParseLineVar 1↓⍺:(C⍪ast Comment cmt)E

  ⍝ When the error is best taken from one of the recursive stimuli (see ParseLineVar
  ⍝ documentation) then we will use the expression error code, as it is the one most
  ⍝ likely to be useful.
  ¯1=×err:⎕SIGNAL eerr

  ⎕SIGNAL err
}

⍝ ParseLineVar
⍝
⍝ Intended Function: Process variable stimuli that can occur when processing a
⍝ top-level line.
⍝
⍝ This function exists because we need to use it in more than one place.
⍝ ParseLineVar can be safely used whenever the state transitions in the current
⍝ state result in the same state change as given in the transition table below.
⍝
⍝ The first element of the output vector is a number indicating the error that was
⍝ received. It will return a negative number in the case where it thinks that the
⍝ errors of previously parsed recursive stimuli is better than the current error,
⍝ and a positive value whenever it wants to return a very specific error code.
⍝ It will return zero in the case that the parsing has succeeded.
⍝
⍝ The process of parsing out a variable assignment appears in a few locations
⍝ so it makes a bit of sense to encapsulate this process into a single function.
⍝ Indeed, the basic process is exactly the same, but depending on the starting
⍝ state, the transitions (read, function calls) are slightly different. In particular,
⍝ the transitions from an unbound variable depends on whether we have seen a
⍝ bound variable already or not. To handle this, we admit a "state class"
⍝ argument as the second element of the left argument vector.
⍝
⍝ State Class 0: Value ← EMPTY ⋄ Named ← EMPTY
⍝ State Class 1: Value ← EMPTY ⋄ Named ← BOUND
⍝
⍝ Right Argument: Matrix of Token and Function nodes
⍝ Left Argument: ([name,type] environment)(Parser state class)
⍝ Output: (Success/Failure)(Empty Line, Expression, Function, or FuncExpr)
⍝ Invariant: Depth of input and output sub-trees should be the same
⍝ Invariant: Should be able to reconstruct the original input from output
⍝ State: Context ← Top ⋄ Fix ← Yes ⋄ Namespace ← OPEN ⋄ Eot ← No
⍝ Return state: Same as entry state.

ParseLineVar←{E SC←⍺
  ⍝ State Transitions (State Class 0):
  ⍝   ←      → SYNTAX ERROR → ()
  ⍝   Vfo    → null         → (Value ← FUNC    ⋄ Named ← MAYBE)
  ⍝   Vfo Nl → null         → (Value ← EMPTY   ⋄ Named ← EMPTY)
  ⍝   Vfo ←  → null         → (Value ← EMPTY   ⋄ Named ← BOUND)
  ⍝   Vu     → null         → (Value ← UNBOUND ⋄ Named ← MAYBE)
  ⍝   Vu Nl  → VALUE ERROR  → ()
  ⍝   Vu ←   → null         → (Value ← EMPTY   ⋄ Named ← UNBOUND)
  ⍝
  ⍝ State Transitions (State Class 1):
  ⍝   ←      → SYNTAX ERROR → ()
  ⍝   Vfo    → null         → (Value ← FUNC    ⋄ Named ← MAYBE)
  ⍝   Vfo Nl → null         → (Value ← EMPTY   ⋄ Named ← EMPTY)
  ⍝   Vfo ←  → null         → (Value ← EMPTY   ⋄ Named ← BOUND)
  ⍝   Vu     → null         → (Value ← UNBOUND ⋄ Named ← BOUND)
  ⍝   Vu Nl  → VALUE ERROR  → ()
  ⍝   Vu ←   → null         → (Value ← EMPTY   ⋄ Named ← BOUND)
  ⍝
  ⍝ Trace: Tables 11-15, 18-22, 206 in Function Specification
  ⍝
  ⍝ The Nl suffixed states are assumed to have been already handled implicitly
  ⍝ by the caller of ParseLineVar. See ParseLine.

  ⍝ Stimuli: Vfo Vu ←
  ⍝
  ⍝ States to Process: Vfo, Vu, Vfo ←, Vu ←
  ⍝
  ⍝ After the above, there are only a few situations we can be in. All the other states
  ⍝ described in Table 206 are tied in one way or another to the ← token. Most of them
  ⍝ have ← directly in their names, but the Vfo and Vu states are partially handled by the
  ⍝ above handling, and the only other situations we can have which make sense,
  ⍝ are not illegal, and not otherwise subsumed by the above are the assignment cases.
  ⍝
  ⍝ This handling of the assignment statement is really a case of handling the
  ⍝ Named property. We can have either BOUND or UNBOUND states. The MAYBE state
  ⍝ will be unused here.
  ⍝
  ⍝ The first possibility is that we have no variable to be named, in which case we need
  ⍝ to signal a SYNTAX ERROR.
  '←'≡⊃'name'Prop 1↑⍵:2 MtAST

  ⍝ The only non-error cases that make any sense at this point are either Vfo ← or Vu ←,
  ⍝ so we can check to make sure that we have at least 3 tokens, any less than that
  ⍝ would indicate either Vfo ← Nl or some other error case.
  3>⊃⍴⍵:¯1 MtAST

  ⍝ If we have at least three tokens to deal with, then the first two should be an
  ⍝ assignment token and a variable token. Let's make sure that this is what we
  ⍝ actually have, otherwise, we should signal an error again.
  ~'Variable' 'Token'∧.≡⍵[0 1;1]:¯1 MtAST
  (,'←')≢⊃'name' Prop 1 4⍴1⌷⍵:¯1 MtAST

  ⍝ Now we need to determine whether the variable is a Vfo or a Vu.
  Tp←E VarType⊢Vn←⊃'name'Prop 1 4⍴0⌷⍵

  ⍝ If the type of the variable is Vu, then we have
  ⍝ the Named ← UNBOUND when we have State Class ← 0
  (0=Tp)∧(SC=0):0,⊂Vn E ParseNamedUnB 2↓⍵

  ⍝ If we have a Vfo, then the Named ← BOUND
  ⍝ and when we have State Class ← 1 with a Vu
  ⍝ XXX In this case, because we know that we only have types
  ⍝ of 2, then we can make sure that we give a type of 2 to
  ⍝ the ParseNamedBnd call. In the future, we will need to make
  ⍝ sure that we know what the real type of the variable is for
  ⍝ State Class ← 1. We will also have to make sure that the
  ⍝ types are in the appropriate nameclass if we have another
  ⍝ class in the stack already.
  (2 3 4∨.=Tp)∨(0=Tp)∧(SC=1):0,⊂Vn 2 E ParseNamedBnd 2↓⍵

  ⍝ If we do not have a Vfo or Vu, then something is wrong and we should error out
  ¯1 MtAST
}

⍝ ParseNamedUnB
⍝
⍝ Intended Function: Parse an assignment to an unbound variable.
⍝
⍝ Right Argument: Non-empty matrix of Token and Function nodes
⍝ Left Argument: Variable Name, [Name,Type] Environment
⍝ Invariant: Input should have at least one row.
⍝ Output: FuncExpr Node
⍝ State: Context ← Top ⋄ Value ← EMPTY ⋄ Named ← UNBOUND
⍝ Return State: Context ← Top ⋄ Fix ← Yes ⋄ Namespace ← OPEN ⋄ Eot ← No

ParseNamedUnB←{Vn E←⍺
  ⍝ Possible stimuli: Fe Vfo Vu ←
  ⍝ Indirectly processed: { }
  ⍝
  ⍝ Trace: Table 19, 22, 206 in Function Specification
  ⍝
  ⍝ State Transitions:
  ⍝   Fe    → null         → (Value ← FUNC    ⋄ Named ← UNBOUND)
  ⍝   Fe Nl → null         → ()
  ⍝   Vfo   → null         → (Value ← FUNC    ⋄ Named ← MAYBE)
  ⍝   Vu    → null         → (Value ← UNBOUND ⋄ Named ← MAYBE)
  ⍝   ←     → SYNTAX ERROR → ()

  ⍝ Stimuli: Fe
  ⍝
  ⍝ We begin by directly addressing the Fe possibility, which has only a
  ⍝ single valid follow-up from here, which is to end the line.
  ⍝ In this case, we take the function expression and give it the name
  ⍝ given to us. This further requires updating the environment and returning
  ⍝ that together with the new node.
  0=⊃ferr ast rst←E ParseFuncExpr ⍵:Vn Bind ast

  ⍝ Stimuli: Vfo Vu ←
  ⍝
  ⍝ If we could not successfully parse as a function expression, the only
  ⍝ other valid, non-error option is the Vfo or Vu prefixes. However, in this
  ⍝ case we have a state exactly like that handled by the ParseLineVar function
  ⍝ above. The only thing we need to remember to do is to add the extra variable
  ⍝ name that is given to us.
  0=⊃err ast←E 0 ParseLineVar ⍵:Vn Bind ast

  ¯1=×err:⎕SIGNAL ferr
  ⎕SIGNAL err
}

⍝ ParseNamedBnd
⍝
⍝ Intended Function: Parse an assignment to a bound variable.
⍝
⍝ Right Argument: Non-empty matrix of Token and Function nodes
⍝ Left Argument: Variable Name, Variable Type, [Name,Type] Environment
⍝ Invariant: Input should have at least one row.
⍝ Output: FuncExpr Node
⍝ State: Context ← Top ⋄ Value ← EMPTY ⋄ Named ← BOUND
⍝ Return State: Context ← Top ⋄ Fix ← Yes ⋄ Namespace ← OPEN ⋄ Eot ← No

ParseNamedBnd←{Vn Tp E←⍺
  ⍝ Possible stimuli: Fe Vfo Vu ←
  ⍝ Indirectly processed: { }
  ⍝
  ⍝ Trace: Table 18, 20, 21, 206 in Function Specification
  ⍝
  ⍝ State Transitions:
  ⍝   E     → SYNTAX ERROR → ()
  ⍝   Fe    → null         → (Value ← FUNC    ⋄ Named ← BOUND)
  ⍝   Fe Nl → null         → (Value ← EMPTY   ⋄ Named ← EMPTY)
  ⍝   Vfo   → null         → (Value ← FUNC    ⋄ Named ← MAYBE)
  ⍝   Vu    → null         → (Value ← UNBOUND ⋄ Named ← BOUND)
  ⍝   Vu Nl → SYNTAX ERROR → ()
  ⍝   Vu ←  → null         → (Value ← EMPTY   ⋄ Named ← BOUND)
  ⍝   ←     → SYNTAX ERROR → ()

  ⍝ Stimuli: E
  ⍝
  ⍝ If we are Named ← BOUND then we need to make sure that we do not have
  ⍝ a binding to a different nameclass. Namely, a binding from an expression
  ⍝ to a function, operator, or the like.
  0=⊃E ParseExpr ⍵:⎕SIGNAL 2

  ⍝ Stimuli: Fe
  ⍝
  ⍝ When we parse a function expression successfully, we still need to
  ⍝ ensure that the type of the variable matches the type of the function
  ⍝ expression, but at least this time, we have a chance of it succeeding.
  ⍝ If it does succeed, we simply need to add the name and move on.
  T←2 ⋄ ferr ast rst←E ParseFuncExpr ⍵
  (0=ferr)∧Tp=T:Vn Bind ast
  Tp≠T:⎕SIGNAL 2

  ⍝ Stimuli: Vfo Vu ←
  ⍝
  ⍝ The handling of the Fe stimuli will have covered both the Fe states and
  ⍝ the Vfo Nl state, as in the Value ← EMPTY ⋄ Named ← EMPTY case handled in
  ⍝ ParseTopLine. We must handle the Vu Nl state explicitly here, and then we are
  ⍝ left only with the states handled by ParseLineVar, except that we need to call
  ⍝ it with a state class of 1 instead of 0.
  (1=⊃⍴⍵)∧('Variable'≡⊃0 1⌷⍵)∧(0=E VarType⊃'name'Prop 1↑⍵):⎕SIGNAL 6
  0=⊃err ast←E 1 ParseLineVar ⍵:Vn Bind ast

  ¯1=×err:⎕SIGNAL ferr
  ⎕SIGNAL err
}

⍝ ParseExpr
⍝
⍝ Intended Function: Take a set of tokens and an environment of types
⍝ and parse it as an expression, returning an error code, ast, and a new,
⍝ updated environment of types.
⍝
⍝ Right Argument: Matrix of Token and Function nodes
⍝ Left Argument: [Name,Type] Environment
⍝ Output: (0 or Exception #)(Expression Node)(New [Name,Type] Environment)
⍝ Invariant: Depth of the output should be the same as the input
⍝ Invariant: Either entire right argument is parsed or an exception is given
⍝ State: Context ← Expr ⋄ Nest ← NONE ⋄ Class ← ATOM ⋄ Last Seen ← EMPTY

ParseExpr←{
  ⍝ Possible Stimuli: ← N Va Vna Vi Vnu E Fea Fed Fem

  ⍝ Do we have an empty expression?
  0=⊃⍴⍵:2 MtAST ⍺

  ⍝ It is sometimes convenient to error out via signal
  2::2 MtAST ⍺
  6::6 MtAST ⍺
  11::11 MtAST ⍺

  ⍝ We must consider the following expression states for Increment 5:

  ⍝  0 empty
  ⍝  1 Fea
  ⍝  3 N
  ⍝  5 Va
  ⍝  6 Vna
  ⍝  7 Vnu
  ⍝  9 Fea N
  ⍝ 10 Fea Va
  ⍝ 11 Fea Vna
  ⍝ 16 N Vnu

  ⍝ Increment 5 does not have nested vectors, so any mix of variables
  ⍝ and literals won't be valid. Additionally, we have only atomic
  ⍝ function expressions. There are also no nested expressions, which
  ⍝ makes assignments and other things easier. Since we are also not
  ⍝ worried about atomic expressions at the moment, we can consider
  ⍝ Expression states 9, 10, and 11 (Tables 45, 46, and 47 in the
  ⍝ Function Specification) as equivalent, more or less to states 3,
  ⍝ 5, and 6 (Tables 39, 41, and 42).

  ⍝ State 16 (Table 52) leads only to various error states. In our
  ⍝ case, because we don't have nested arrays yet, we can map all of
  ⍝ these to SYNTAX ERROR and be done with it.

  ⍝ State 7 leads to only VALUE ERRORS for our case except for
  ⍝ assignment.

  ⍝ We don't have strands yet, so Vna doesn't actually make sense, and
  ⍝ Vnu is actually Vu.

  ⍝ Analyzing the rest of the tables that are left, we see that the
  ⍝ stimuli can be divided into a regular set of partitions:

  ⍝   Group      │ Stimuli
  ⍝   ───────────┼─────────────
  ⍝   Variables  │ Va Vu
  ⍝   Literals   │ N+
  ⍝   Assignment │ ←
  ⍝   Function   │ Fea Fed Fem

  ⍝ Variables and literals may not appear next to one
  ⍝ another. Likewise, the ← token must appear between another
  ⍝ expression and a variable.

  ⍝ Encapsulate literals as atomic Expression nodes
  ⍝ XXX: Is there a more elegant way to do this?
  N←(D←⊃⍵)'Expression' ''(1 2⍴'class' 'atomic')
  P←2</0,M←(D=0⌷⍉⍵)∧(1⌷⍉⍵)∊⊂'Number'
  E←(⍵⍪N)[⊃,/(⊂(∧\~M)/⍳S),S,¨P⊂⍳S←⊃⍴⍵;]
  E[M/(+\P)+⍳⊃⍴⍵;0]+←1

  ⍝ Parse Function calls, Variables, Assignments
  ⍝ XXX: Please make this neater and cleaner
  E Ne _←⊃{ast env knd←⍵ ⋄ Dwn←{A←⍵ ⋄ A[;0]+←1 ⋄ A}
    Em Ed←{D'Expression' '' (1 2⍴'class' ⍵)}¨'monadic' 'dyadic'
    kid←(⍵ ast)⊃⍨0=⊃_ ast←2↑env ParseFuncExpr ⍺
    case←(16⍴2)⊤2*4⊥knd,⊂'Expression' 'FuncExpr' 'Token' 'Variable'⍳0 1⌷kid
    c01←c02←c10←c13←c30←c31←c32←{⎕SIGNAL 2}
    c00←{(kid⍪ast),env 1}
    c03←{(N⍪Dwn kid⍪ast)env 1}
    c21←c11←{(Em⍪Dwn kid⍪ast)env 2}
    c22←c12←{ast env 3}
    c20←{(Ed⍪(Dwn kid)⍪1↓ast)env 1}
    c23←{(Ed⍪(Dwn N⍪Dwn kid)⍪1↓ast)env 1}
    c33←{(nm Bind ast)(((nm←⊃'name'Prop kid)1)⍪env)1}
    c3←c33 Sel c32 Sel c31 Sel c30
    c2←c3 Sel c23 Sel c22 Sel c21 Sel c20
    c1←c2 Sel c13 Sel c12 Sel c11 Sel c10
    c0←c1 Sel c03 Sel c02 Sel c01 Sel c00
    case c0 ⍵
  }/(0 Kids E),⊂MtAST ⍺ 0

  0 E Ne
}

⍝ ParseFuncExpr
⍝
⍝ Intended Function: Take a set of tokens and an environment of types
⍝ and parse it as a function expression, returning an error code, ast, and a new,
⍝ updated environment of types.
⍝
⍝ Right Argument: Matrix of Token and Function nodes
⍝ Left Argument: [Name,Type] Environment
⍝ Output: (0 or Exception #)(FuncExpr AST)(Rest of Input)
⍝ Invariant: Depth of the output should be the same as the input
⍝ State: Context ← Fnex ⋄ Opnd ← NONE ⋄ Oper ← NONE ⋄ Axis ← NO ⋄ Nest ← NONE ⋄ Tgt ← No

ParseFuncExpr←{
  ⍝ Possible Stimuli: Fn Da Ma Vf Vu Vi
  ⍝
  ⍝ We only accept atomic expressions right now, which means only
  ⍝ atomic stimuli, without any consideration to multi-stimuli
  ⍝ histories.

  0≠⊃err ast rst cls eqv←⍺{
    Pcls←{(~∨\' '=C)/C←⊃'class'Prop 1↑⍵}
    IsFunc←{('Variable'≡⊃0 1⌷⍵)∧2=⍺ VarType ⊃'name'Prop 1↑⍵}
    'Primitive'≡⊃0 1⌷⍵:0(1↑⍵)(1↓⍵)(Pcls ⍵)(⊃'name'Prop 1↑⍵)
    IsFunc ⍵:0(1↑⍵)(1↓⍵)'ambivalent' ''
    0=⊃err ast rst←⍺ ParseFunc ⍵:err ast rst,2⍴⊂'ambivalent'
    2 MtAST ⍵ '' ''
  }⍵:err ast rst

  ⍝ The only thing we can have at this point is a function, so we just handle that
  ⍝ here directly.
  Fn←(¯1+⊃⍵) 'FuncExpr' '' (2 2⍴'class' cls 'equiv' eqv)

  0(Fn⍪ast)rst
}

⍝ ParseFunc
⍝
⍝ Intended Function: Take a set of tokens and parse them as an user-defined
⍝ ambivalent function, monadic or dyadic operator.
⍝
⍝ Right Argument: Non-empty matrix of Token and Function nodes
⍝ Left Argument: [Name,Type] Environment
⍝ Output: (0 or Exception #)(Function AST)(Rest of Input)
⍝ Invariant: Depth of the output should be the same as the input
⍝ Invariant: Right argument must have at least one row
⍝ State: Context ← Func ⋄ Bracket ← No ⋄ Cond ← No ⋄ Bind ← NO ⋄ Value ← EMPTY

ParseFunc←{
  ⍝ Possible Stimuli: E : Vfo Vu
  ⍝ Indirectly processed stimuli: N
  ⍝
  ⍝ Trace: Tables 23 - 28 and 31 of Function Specification
  ⍝
  ⍝ In Parse, the { and } stimuli have already been processed and used
  ⍝ to construct nested forms of the lines. The ParseFunc therefore must
  ⍝ check to ensure that the next node (token) to process is a Function
  ⍝ node and convert the body of the function from a series of Line nodes
  ⍝ to a proper function body. Firstly, we must check to determine whether
  ⍝ we have a Function node.
  'Function'≢⊃0 1⌷⍵:2 MtAST ⍵

  ⍝ The rest of the nodes to parse are children of the Function node,
  ⍝ so extract out just the Function node from the rest of the tokens.
  Fb←(Fm←1=+\(Fd←⊃⍵)=D←0⌷⍉⍵)⌿⍵

  ⍝ State: Bracket ← Yes ⋄ Cond ← No ⋄ Bind ← NO ⋄ Value ← EMPTY
  ⍝
  ⍝ State Transitions:
  ⍝   E     → wait → (Value ← EXPR)
  ⍝   E :   → wait → (Cond ← Yes ⋄ Value ← EMPTY)
  ⍝   E : E → wait → (Value ← EXPR)
  ⍝   Vfo   → wait → (Value ← FVAR)
  ⍝   Vu    → wait → (Value ← UNBOUND)
  ⍝   :     → SYNTAX ERROR → ()
  ⍝   }     → okay         → ()
  ⍝
  ⍝ At this point we can use a similar technique to that used at the
  ⍝ top level and reduce over all the lines to collect up a final AST.
  ⍝ At the end we can replace the Fb contents (marked out by Fm) with
  ⍝ the AST that was created. This requires a ParseFnLine function.
  ⍝ Note that the } Stimuli which could appear here for an empty function
  ⍝ gets implicitly handled.

  ⍝ To begin with, we need to start with an empty environment and an empty
  ⍝ AST. This is our Seed value.
  Sd←(0 4⍴⍬)MtNTE

  ⍝ We partition the AST into the appropriate sub-trees, each of which should
  ⍝ correspond to a single line. All Lines we care about are at depth Fd+1.
  Cn←((Fd+1)=0⌷⍉Fb)⊂[0]Fb

  ⍝ Finally, we use ParseFnLine to reduce over the lines.
  ⍝ At this point, the function will not have the appropriate root on
  ⍝ it, which we stripped off above. We put this back on to form the final,
  ⍝ correctly parsed Function. Fn is now a Function node and each line has been
  ⍝ converted into an apropriate node, or left alone if it is an empty line.
   2:: 2 MtAST ⍵
  11::11 MtAST ⍵
  Fn←(1↑Fb)⍪⊃A E←⊃ParseFnLine/⌽(⊂Sd),Cn

  ⍝ We return the function node together with the rest of the nodes after
  ⍝ it.
  0 Fn ((~Fm)⌿⍵)
}

⍝ ParseFnLine
⍝
⍝ Intended Function: Given a Function Line sub-tree, parse it into one of
⍝ Expression, FuncExpr, Condition, or Guard sub-tree at the same depth.
⍝
⍝ Right Argument: Code lines already parsed, Names environment
⍝ Left Argument: Current Line sub-tree to process
⍝ Output: (Code extended by Line, Expression, FuncExpr, Condition, or Guard)
⍝         (New [name,type] environment)
⍝ Invariant: Depth of input and output sub-trees should be the same
⍝ Invariant: Comment of the line should be transferred to the output node
⍝ Invariant: Should be able to reconstruct the original input from output
⍝ State: Context ← Func ⋄ Bracket ← Yes ⋄ Cond ← No ⋄ Bind ← NO ⋄ Value ← EMPTY
⍝ Return state: Same as entry state.

ParseFnLine←{C E←⍵
  ⍝ State: Bracket ← Yes ⋄ Cond ← No ⋄ Bind ← NO ⋄ Value ← EMPTY
  ⍝
  ⍝ State Transitions:
  ⍝   E     → wait         → (Value ← EXPR)
  ⍝   E :   → wait         → (Cond ← Yes ⋄ Value ← EMPTY)
  ⍝   E : E → wait         → (Value ← EXPR)
  ⍝   Vfo   → wait         → (Value ← FVAR)
  ⍝   Vu    → wait         → (Value ← UNBOUND)
  ⍝   :     → SYNTAX ERROR → ()

  ⍝ Dealing with Empty Lines / Handling Immediate } Stimuli
  ⍝ We might have an empty line with no tokens. In this case, we can
  ⍝ just return the line, as there is nothing to do for this
  ⍝ line.
  1=⊃⍴⍺:(C⍪⍺)E

  ⍝ Regardless of what we do, we need to have the comment to put on the
  ⍝ new head of the sub-tree that we will return.
  cmt←⊃'comment' Prop 1↑⍺

  ⍝ Stimuli: :
  ⍝
  ⍝ A line may contain at most one : stimuli. If one occurs, we know exactly
  ⍝ what we must have, but if we do not, then we have one of E, Vfo, or Vu.
  Cm←{(,':')≡((0⌷⍉⍵)⍳⊂'name')⊃(1⌷⍉⍵),⊂''}¨3⌷⍉⍺ ⍝ All name attributes ≡,':'
  Cnd←+/Cm←((1+⊃⍺)=0⌷⍉⍺)×((1⌷⍉⍺)∊⊂'Token')×Cm  ⍝ Only direct child Tokens
  1<Cnd:⎕SIGNAL 2                               ⍝ Too many : tokens
  1=1⌷Cm:⎕SIGNAL 2                              ⍝ Empty test clause
  1=Cnd:((C⍪A)E)⊣A E←⊃E ParseCond/¯1↓¨(1,1↓Cm)⊂[0]1⊖⍺
  0≠Cnd:'Unexpected : Token Count'⎕SIGNAL 99

  ⍝ At this point, we have handled line terminators (Nl and ⋄) as well as
  ⍝ all closing } stimuli. We have also eliminated Stimuli : . Function
  ⍝ States 0, 1, 5, 8 have all been processed by the code above. That
  ⍝ leaves the following states:
  ⍝
  ⍝   State # │ Canonical Sequence
  ⍝   ────────┼───────────────────
  ⍝         2 │ { E
  ⍝         3 │ { Vfo
  ⍝         4 │ { Vu
  ⍝   ────────┴───────────────────
  ⍝
  ⍝ Basically, state 3 at this point, because we do not have
  ⍝ assignments, can be nothing but a SYNTAX ERROR (see Table 26
  ⍝ in the Function Specification). State 4 (Table 27) can be nothing
  ⍝ more than a VALUE ERROR, and is completely subsumed by state 2
  ⍝ (Table 25). Thus, checking for a valid E stimuli at this point
  ⍝ suffices to answer all questions and complete the handling of these
  ⍝ tables completely.
  0≠⊃err ast Ne←E ParseExpr 1↓⍺:⎕SIGNAL err
  (C⍪ast)Ne
}

⍝ ParseCond
⍝
⍝ Intended Function: Construct a Condition node from two expressions
⍝ representing a conditional line in a function body.
⍝
⍝ Left Operand: Current (name, type) environment
⍝ Right argument: Tokens representing the consequent expression
⍝ Left argument: Tokens representing the test expression
⍝ Output: (Condition node)(New [name, type] environment)
⍝ Invariant: Test expression is non-empty
⍝ Invariant: Condition node depth is one less than token depth
⍝ State: Context ← Func ⋄ Bracket ← Yes ⋄ Cond ← Yes ⋄ Bind ← NO ⋄ Value ← EMPTY

ParseCond←{
  ⍝ ParseFnLine calls ParseCond without knowing whether the test expression
  ⍝ parses to a valid expression. Verify this first.
  0≠⊃err ast Ne←⍺⍺ ParseExpr ⍺:⎕SIGNAL err

  ⍝ Depths of ast need to be bumped since they are going into a condition
  ⍝ node.
  ast[;0]+←1

  ⍝ Return a Condition node
  H←(¯1+⊃⍺)'Condition' '' MtA

  ⍝ Refer to Tables 28 and 31 in Function Specification; parse a valid or
  ⍝ empty expression, as all other cases are subsumed. This covers
  ⍝ Function States 5 and 8.
  0=⊃⍴⍵:(H⍪ast)Ne
  0≠⊃err con Ne←Ne ParseExpr ⍵:⎕SIGNAL err
  con[;0]+←1 ⍝ Bump the consequence depth as well
  (H⍪ast⍪con)Ne
}

⍝ KillLines
⍝
⍝ Intended Function: Eliminate all semantically irrelevant lines from AST
⍝ to create an AST suitable for compiling.

KillLines←{(~⍵[;1]∊⊂'Line')⌿⍵}

⍝ DropUnreached
⍝
⍝ Intended Function: Simplify functions by removing code in function
⍝ bodies after a return expression (unnamed expression).

DropUnreached←{
  u←(0=∘≢('name'∘Prop 1∘↑))¨ ⍝ (u k) gives map of unnamed exprs
  d←(~(∨\0,1↓¯1⌽u))(/∘⊢)⊢    ⍝ (d k) drops kids after first unnamed expr
  f←'Function'≡(⊃0 1∘⌷)      ⍝ (f n) tests if n is function node
  0=≢k←1 Kids ⍵:⍵            ⍝ Terminate at leaves
  (1↑⍵)⍪⊃⍪/∇¨d⍣(f ⍵)⊢k       ⍝ Recur after dropping unnamed exprs
}

⍝ LiftConsts
⍝
⍝ Intended Function: Lift all literal expressions to the top level.

LiftConsts←{
  I←¯1 ⋄ MkV←{'LC',⍕I⊣(⊃I)+←1}      ⍝ New variable maker
  at←{2 2⍴'name' ⍵ 'class' ⍺}       ⍝ Attribute maker
  ns←'Expression' 'Number'          ⍝ Nodes we care about
  e l←((1⌷⍉a←⍵)∊⊂)¨ns               ⍝ All Expr and Number nodes
  v←mkv¨⍳+/s←2</0,l                 ⍝ Variables we need; start of literals
  hn←1⌷⍉h←(l∨e∧1⌽l)⌿a               ⍝ Literal Expressions and node names
  vn←{'Variable' '' ('array' at ⍵)} ⍝ Variable node maker sans depth
  a[s/⍳⊃⍴a;1+⍳3]←↑vn¨v              ⍝ Replace starting literals with variables
  a←(s∨~l)⌿a                        ⍝ Remove all non-first literals
  h[(i←{(hn∊⊂⍵)/⍳⊃⍴h})1⊃ns;0]←2     ⍝ Literal depths are all 2
  h[i⊃ns;0 3]←1,⍪'atomic'∘at¨v      ⍝ Litexprs are depth 1, with new names
  (1↑a)⍪h⍪1↓a                       ⍝ Connect root, lifted with the rest
}

⍝ LiftBound
⍝
⍝ Intended Function: Lift all assignments to the root of their scope.

LiftBound←{
  vex←{                             ⍝ Function to make var expr
    at←2 2⍴'name' ⍵ 'class' 'array' ⍝ Variable name is right argument
    v←1 4⍴(1+⍺)'Variable' '' at     ⍝ Variable node, depth in left argument
    at←1 2⍴'class' 'atomic'         ⍝ Expression is atomic
    e←1 4⍴⍺ 'Expression' '' at      ⍝ Expression node has no name
    e⍪v                             ⍝ Give valid AST as result
  }
  lft←{                             ⍝ Function to lift expression
    cls←⊃'class'Prop ⍵              ⍝ Class determines handling
    'atomic'≡cls:⍵                  ⍝ Nothing to do for atomic
    ri←1+'monadic' 'dyadic'⍳⊂cls    ⍝ Location of the right argument
    lf ex←⍺ ∇ ri⊃k←1 Kids ⍵         ⍝ Lift the right argument
    nm←⊃'name'Prop ex               ⍝ Consider right argument name
    nr←⊃⍪/¯1↓k                      ⍝ Our not right arguments to recombine
    ∧/' '=nm:lf((1↑⍵)⍪nr⍪ex)        ⍝ When unnamed, do nothing
    ex[;0]-←(⊃ex)-⍺                 ⍝ When named, must lift
    ne←(1↑⍵)⍪nr⍪(1+⊃⍵)vex nm        ⍝ Replace right with variable reference
    (lf⍪ex)(ne)                     ⍝ New lifted exprs and new node
  }
  atm←{                             ⍝ Fn to atomize test expression
    cls←⊃'class'Prop 1↑te←⍵         ⍝ Class of test expression
    'atomic'≡cls:MtAST ⍵            ⍝ Do nothing if atomic already
    te[;0]-←1                       ⍝ Test expression is going up
    nm←⊃'class'Prop 1↑⍵             ⍝ Name of test expression
    ∨/' '≠nm:te((⊃⍵)vex ⊃Split nm)  ⍝ Already named, return with referring vex
    ('tst'Bind te)((⊃⍵)vex'tst')    ⍝ Use temporary name otherwise
  }
  cnd←{                             ⍝ Function to handle condition nodes
    te←⊃k←1 Kids ⍵                  ⍝ We care especially about the test expr
    lf1 te←(⊃⍵)lft te               ⍝ Lift test children, before cond
    lf2 te←atm te                   ⍝ Atomize test expression
    lf←lf1⍪lf2                      ⍝ Combine liftings
    1=≢k:lf⍪(1↑⍵)⍪te                ⍝ No consequent, no children expressions
    ce←⊃⍪/(1+⊃⍵)lft⊃⌽k              ⍝ Lift consequent, inside cond
    lf⍪(1↑⍵)⍪te⍪ce                  ⍝ Put it all back in the right order
  }
  1=≢⍵:⍵                            ⍝ Do nothing for leaves
  'Expression'≡⊃0 1⌷⍵:⊃⍪/(⊃⍵)lft ⍵  ⍝ Lift root expressions
  'Condition'≡⊃0 1⌷⍵:cnd ⍵          ⍝ Lifting Condition nodes is special
  (∇⊢)Eachk ⍵                       ⍝ Ignore non-expr nodes
}

⍝ AnchorVars
⍝
⍝ Intended Function: Associate with each assignment, scope, and variable
⍝ reference an appropriate slot pointing to a specific region of memory within
⍝ the stack frames, or in the case of scopes, the size of the stack frame of
⍝ that scope.

AnchorVars←{
  mt←0 2⍴⊂'' 0                    ⍝ An empty environment
  ge←{                            ⍝ Fn to get environment for current scope
    em←(1+⊃⍵)=0⌷⍉⍵                ⍝ All expressions are direct descendants
    em∧←(1⌷⍉⍵)∊⊂'Expression'      ⍝ Mask of expressions
    nm←'name'Prop em⌿⍵            ⍝ Names in local scope
    nm←⍪⊃,/(⊂0⍴⊂''),Split¨nm      ⍝ Split names and prepare
    (nm,0),⍳≢nm                   ⍝ Local scope 0, assign a slot to each var
  }
  vis←{nm←⊃0 1⌷⍺ ⋄ ast env←⍵
    'Variable'≡nm:⍺(⍺⍺{           ⍝ Variable node
      i←⊃env⍳'name'Prop ⍺         ⍝ Lookup var in env
      a←'env' 'slot',⍪i(1 2)⌷env  ⍝ Stack frame and slot
      a←(⊃0 3⌷⍺)⍪a                ⍝ Attach new attributes
      (ast⍪(1 3↑⍺),⊂a)env         ⍝ Attach to current AST
    })⍵
    'Expression'≡nm:⍺(⍺⍺{         ⍝ Expression node
      z←(⌽1 Kids ⍺),⊂MtAST env    ⍝ Children use existing env
      ka env←⊃⍺⍺vis/z             ⍝ Children visited first
      nm←Split⊃'name'Prop 1↑⍺     ⍝ Name(s) of expression
      id←(0⌷⍉⍺⍺)⍳nm               ⍝ Relevant names in scope env
      sl←id⊃¨⊂2⌷⍉⍺⍺               ⍝ Slot(s) for each name
      at←(⊃0 3⌷⍺)⍪'slots'(⍕sl)    ⍝ New attributes for node
      nd←(1 3↑⍺),⊂at              ⍝ New node
      z←(ast⍪nd⍪ka)               ⍝ AST to return
      z(((⊂id)⌷⍺⍺)⍪env)           ⍝ Add any names to environment
    })⍵
    'Condition'≡nm:⍺(⍺⍺{          ⍝ Condition node
      k←1 Kids ⍵                  ⍝ Must handle children
      z←(⌽1 Kids ⍵),⊂MtAST env    ⍝ We can reduce over all the kids at once
      ca _←⊃⍺⍺ vis/z              ⍝ We ignore the consequent environment
      (ast⍪(1↑⍺)⍪ca)env           ⍝ Return the original environment
    })⍵
    'Function'≡nm:⍺(⍺⍺{           ⍝ Function node
      ken←⍺⍺⍪env                  ⍝ Env is current env plus all in scope
      ken[;1]+←1                  ⍝ Push the stack count up
      z←(⌽1 Kids ⍺),⊂MtAST ken    ⍝ Must go through all children
      ne←ge ⍺                     ⍝ New scope env
      ka _←⊃ne vis/z              ⍝ Ignore env from children
      at←(⊃0 3⌷⍺)⍪'alloca'(≢ne)   ⍝ New env attribute for function node
      nd←(1 3↑⍺),⊂at              ⍝ New function node
      (ast⍪nd⍪ka)env              ⍝ Leave environment same as when entered
    })⍵
    z←(⌽1 Kids ⍺),⊂MtAST env
    ka env←⊃⍺⍺∇/z
    (ast⍪(1↑⍺),ka)env
  }
  z←(⌽1 Kids ⍵),⊂MtAST mt
  z←⊃⊃(ge ⍵)vis/z
  (1↑⍵)⍪z
}

⍝ LiftFuncs
⍝
⍝ Intended Function: Lift all functions to the top level.

LiftFuncs←{
  I←¯1 ⋄ MkV←{'FN',⍕I⊣(⊃I)+←1}     ⍝ New variable maker
  vis←{lft ast←⍵                   ⍝ Fn to visit each node
    (1=⊃⍺)∧'FuncExpr'≡⊃0 1⌷⍺:⍵     ⍝ Ignore top-level functions
    'Function'≡⊃0 1⌷⍺:⍺(⍺⍺{        ⍝ Only lift Function nodes
      z←(⌽1 Kids ⍺),⊂lft MtAST     ⍝ Recur over children, updating lifted
      lft ka←⊃(1+⍺⍺)vis/z          ⍝ Bump up the depth over children
      at←(⊃0 3⌷⍺)⍪'depth' ⍺⍺       ⍝ New depth attribute for Function node
      nlf←((1 3↑⍺),⊂at)⍪ka         ⍝ Function node lifted
      vn←1 2⍴'class' 'ambivalent'  ⍝ Replace with ambivalent variable
      vn⍪←'depth'(⍕⍺⍺)             ⍝ With the same depth
      vn⍪←'name'(MkV⍬)             ⍝ And a new name
      vn←1 4⍴(⊃⍺)'Variable' '' vn  ⍝ Node has same depth
      (lft⍪nlf)(ast⍪vn)            ⍝ Fn lifted and replaced by variable
    })⍵
    z←(⌽1 Kids ⍺),⊂lft (1↑⍺)       ⍝ Otherwise, traverse
    ⊃⍺⍺ ∇/z                        ⍝ without changing anything
  }
  z←(⌽1 Kids ⍵),⊂2⍴⊂MtAST          ⍝ Must traverse all top-level
  (1↑⍵)⍪⊃⍪/0 vis/z                 ⍝ Nodes just the same
}

⍝ ConvPrims
⍝
⍝ Intended Function: Convert all Primitive nodes to their appropriate
⍝ runtime variable references.

ConvPrims←{ast←⍵
  pl←'+-÷×|*⍟⌈⌊<≤=≠≥>'                ⍝ Primitives
  cl←'apl_plus' 'apl_minus' 'apl_div' ⍝ Foreign equivalents
  cl,←'apl_times' 'apl_residue'
  cl,←'apl_exp' 'apl_log' 'apl_max'
  cl,←'apl_min' 'apl_lessthan'
  cl,←'apl_lessthaneq' 'apl_equal'
  cl,←'apl_noteq' 'apl_greaterthaneq'
  cl,←⊂'apl_greatthan'
  pm←(1⌷⍉⍵)∊⊂'Primitive'              ⍝ Mask of Primitive nodes
  pn←⊃,/'name'Prop pm⌿⍵               ⍝ Primitive names
  cn←(pl⍳pn)⊃¨⊂cl                     ⍝ Converted names
  at←⊂1 2⍴'class' 'function'          ⍝ Class is function
  at⍪¨←(⊂⊂'name'),∘⊂¨cn               ⍝ Use the converted name
  vn←(⊂'Variable'),(⊂''),⍪at          ⍝ Build the basic node structure
  ast⊣(pm⌿ast)←(pm/0⌷⍉⍵),vn           ⍝ Replace Primitive nodes

}

⍝ GenLLVM
⍝
⍝ Intended Function: Take a namespace and convert it to an LLVM Module that is
⍝ semantically equivalent.

GenLLVM←{
  nam←(0 3)(0 1)⊃⍵                   ⍝ Namespace must have name
  nam←nam 'Unamed Namespace'⌷⍨''≡nam ⍝ Possibly empty, so fix it
  mod←ModuleCreateWithName nam       ⍝ Empty module to start with
  1=≢k←1 Kids ⍵:mod                  ⍝ Quit if nothing to do
  nm←1⌷⍉(1=0⌷⍉⍵)⌿⍵                   ⍝ Top-level nodes and node names
  exm←nm∊⊂'Expression'               ⍝ Mask of expressions
  fem←nm∊⊂'FuncExpr'                 ⍝ Mask of function expressions
  _←GenRuntime mod                   ⍝ Generate declarations for runtime
  tex←mod GenGlobal¨exm/k            ⍝ Generate top-level globals
  _←mod GenFnDec¨fem/k               ⍝ Generate Function declarations
  _←mod GenFunc¨fem/k                ⍝ Generate functions
  mod⊣mod GenInit tex                ⍝ Generate Initialization function
}

⍝ GenFnDec
⍝
⍝ Intended Function: Take a FuncExpr node and declare the function.

GenFnDec←{
  0=≢fn←Split⊃'name'Prop 1↑⍵:0       ⍝ Ignore functions without names
  vtst←'Variable'≡⊃1 1⌷⍵             ⍝ Child node type
  vn←⊃'name'Prop 1↑1↓⍵               ⍝ Variable name if it exists
  vtst:⍺{                            ⍝ Named function reference
    fr←GetNamedFunction ⍺ vn         ⍝ Referenced function
    ft←GenFuncType(CountParams fr)-3 ⍝ Function Type based on depth
    ⍺{AddAlias ⍺ ft fr ⍵}¨fn         ⍝ Generate aliases for each name
  }⍵
  fnf←⊃fn ⋄ fnr←1↓fn                 ⍝ Canonical name; rest of names
  fd←⍎⊃'depth'Prop 1↑1↓⍵             ⍝ Function depth
  ft←GenFuncType fd                  ⍝ Fn type based on depth
  fr←AddFunction ⍺ fnf ft            ⍝ Insert function into module
  0=≢fnr:fr                          ⍝ Return if no other names
  fr⊣⍺{AddAlias ⍺ ft fr ⍵}¨fnr       ⍝ Otherwise, alias the others
}

⍝ GenGlobal
⍝
⍝ Intended Function: Take a global expression and generate a new
⍝ binding in the module. Returns initialization expression if needed.

GenGlobal←{
  0=≢⍵:MtAST                         ⍝ Don't do anything if nothing to do
  litp←{                             ⍝ Fn predicate to test if literal
    cls←⊃'class'Prop 1↑⍵             ⍝ Class of Expression
    ct←⊃1 1⌷⍵                        ⍝ Node type of the first child
    ('atomic'≡cls)∧'Number'≡ct       ⍝ Class is atomic; Child type is Number
  }
  litp ⍵:MtAST⊣⍺ GenConst ⍵          ⍝ Generate the constants directly
  ∧/' '=nm←⊃'name'Prop 1↑⍵:⍵         ⍝ No need to declare unnamed expressions
  ⍵⊣⍺ GenArrDec Split⊃'name'Prop 1↑⍵ ⍝ Declare the array and enqueue
}

⍝ GenArrDec
⍝
⍝ Intended Function: Generate a new binding for an expression to be
⍝ initialized later if there is not already a binding in the module.

GenArrDec←{
  ⍺{                               ⍝ Fn to declare new array
    0≠GetNamedGlobal ⍺ ⍵:⍵         ⍝ Do nothing if already declared
    r←ConstInt (Int16Type) 0 0     ⍝ Rank ← 0
    sz←ConstInt (Int64Type) 0 0    ⍝ Size ← 0
    t←ConstInt (Int8Type) 2 0      ⍝ Type ← 2
    s←ConstPointerNull Int32Type   ⍝ Shape ← ⍬
    d←ConstPointerNull Int64Type   ⍝ Data ← ⍬
    a←ConstStruct (r sz t s d) 5 0 ⍝ Build empty structure
    g←AddGlobal ⍺(GenArrayType⍬)⍵  ⍝ Add the Global
    ⍵⊣SetInitializer g a           ⍝ Set the initial empty value
  }¨⍵
}

⍝ GenConst
⍝
⍝ Intended Function: Given an literal Expression node, generate a global
⍝ LLVM Constant and insert it into the LLVM Module given.

GenConst←{
  vs←⊃'name'Prop 1↑⍵                   ⍝ Get the name of a literal
  mnlerr←'BAD LITERAL NAME'            ⍝ Error message
  ∨/' '=vs:mnlerr ⎕SIGNAL 99           ⍝ Sanity check for a single name
  v←((2≤⍴v)⊃⍬(⍴v))⍴v←'value'Prop 1↓⍵   ⍝ Expression values with correct shape
  arrayp←{                             ⍝ Fn to generate LLVM Array Pointer
    a←ConstArray ⍺⍺ ⍵ (⊃⍴⍵)            ⍝ Data values
    at←ArrayType ⍺⍺ (⊃⍴⍵)              ⍝ Type of the array
    g←AddGlobal ⍺ at ⍵⍵                ⍝ Add global to the module
    _←SetInitializer g a               ⍝ Initialize it
    b←CreateBuilder                    ⍝ Need a builder
    p←BuildGEP b g (GEPI 0 0) 2 ''     ⍝ Get the array pointer
    p⊣DisposeBuilder b                 ⍝ Cleanup and return pointer
  }
  cintstr←ConstIntOfString             ⍝ Shorten the name
  d←{cintstr (Int64Type) ⍵ 10}¨,v      ⍝ Data values
  d←⍺(Int64Type arrayp 'elems')d       ⍝ Data array pointer
  s←{                                  ⍝ The shape is either
    0=⍴⍵:⍬                             ⍝ An empty shape
    {ConstInt (Int32Type) ⍵ 0}¨⍵       ⍝ Or has LLVM Integers
  }⍴v                                  ⍝ Based on the shape of v
  s←⍺(Int32Type arrayp 'shape')s       ⍝ Shape array pointer
  r←ConstInt (Int16Type) (⊃⍴⍴v) 0      ⍝ Rank is constant; from v not d
  sz←ConstInt (Int64Type) (⊃⍴,v) 0     ⍝ Size of d is length of v
  t←ConstInt (Int8Type) 2 0            ⍝ Constant Int type, for now
  a←ConstStruct (r sz t s s) 5 0       ⍝ Build array value
  g←AddGlobal ⍺ (GenArrayType⍬) vs     ⍝ Create global place holder
  g⊣SetInitializer g a                 ⍝ Initialize global with array value
}

⍝ GenFunc
⍝
⍝ Intended Function: Given a FuncExpr node, build an appropriate
⍝ Function in the LLVM Module given.

GenFunc←{
  0=≢fn←Split⊃'name'Prop 1↑⍵:0       ⍝ Ignore functions without names
  'Variable'≡⊃1 1⌷⍵:0                ⍝ Ignore named function references
  fs←⍎⊃'allloca'Prop 1↑1↓⍵           ⍝ Allocation for local scope
  fr←GetNamedFunction ⍺ (⊃fn)        ⍝ Get the function reference
  bldr←CreateBuilder                 ⍝ Setup builder
  bb←AppendBasicBlock fr ''          ⍝ Initial basic block
  _←PositionBuilderAtEnd bldr bb     ⍝ Link builder and basic block
  env0←{                             ⍝ Setup local frame
    0=fs:(0 0)                       ⍝ If frame is empty, do nothing
    fsz←ConstInt Int32Type fs        ⍝ Frame size value reference
    ftp←GenArrayType⍬                ⍝ Frame is array pointer
    args←bldr ftp fsz 'env0'         ⍝ Frame is env0
    (BuildArrayAlloca args)fs        ⍝ Return pointer and size
  }⍬
  k←2 Kids ⍵                         ⍝ Nodes of the Function body
  _←⍬ ⍬(⍺ fr bldr env0 GenFnBlock)k  ⍝ Generate the function body
  fr⊣DisposeBuilder bldr              ⍝ Builder cleanup
}

⍝ GenFnBlock
⍝
⍝ Intended Function: Generate a block of code in a function.

GenFnBlock←{mod fr bldr env0←⍺⍺ ⋄ nm vl←⍺ ⋄ k←⍵
  line←{n←⊃0 1⌷⍺                     ⍝ Op to handle node in function body
    n≡'Expression':⍺(⍺⍺ GenExpr)⍵    ⍝ Use GenExpr on Expressions
    n≡'Condition':⍺(⍺⍺ GenCond)⍵     ⍝ Use GenCond on Conditions
    emsg←'UNKNOWN FUNCTION CHILD'    ⍝ Only deal with Expressions or Conditions
    emsg ⎕SIGNAL 99                  ⍝ And signal an error otherwise
  }
  _ v←⊃⍺⍺ line/(⌽⍵),⊂⍺               ⍝ Reduce top to bottom over children
  mt←GetNamedFunction mod 'array_mt' ⍝ Runtime function to empty array
  res←GetParam fr 0                  ⍝ ValueRef of result parameter
  mtret←{                            ⍝ Fn for empty return
    _←BuildCall bldr mt res 1 ''     ⍝ Empty the result parameter
    bldr(⍵ MkRet)env0                ⍝ And make return
  }
  0=≢⍵:mtret mod                     ⍝ Empty return on empty body
  'Condition'≡⊃0 1⌷l←⊃⌽⍵:mtret mod   ⍝ Extra return if condition
  cp←GetNamedFunction mod 'array_cp' ⍝ Runtime array copy function
  ∨/' '≠⊃'name'Prop 1↑l:{            ⍝ Is last node named?
    args←res,⊃⌽v                     ⍝ Then we return the binding
    _←BuildCall bldr cp args 2 ''    ⍝ Copied into result array
    bldr(mod MkRet)env0              ⍝ And return
  }⍵
}

⍝ GenInit
⍝
⍝ Intended Function: Generate the initialization function that will
⍝ initialize all global variables that are not constants.

GenInit←{
  ft←GenFuncType 0                   ⍝ Zero depth function
  fr←AddFunction ⍺ 'Init' ft         ⍝ Named Init
  bldr←CreateBuilder                 ⍝ Setup builder
  bb←AppendBasicBlock fr ''          ⍝ Initial basic block
  _←PositionBuilderAtEnd bldr bb     ⍝ Link builder and basic block
  gex←{GetNamedGlobal ⍺ ⍵}           ⍝ Convenience Fn for GetNamedGlobal
  gfn←{GetNamedFunction ⍺ ⍵}         ⍝ Convenience Fn for GetNamedFunction
  call←{BuildCall bldr ⍺⍺ ⍵ (≢⍵) ''} ⍝ Op to build call
  cpf←⍺ gfn 'array_cp'               ⍝ Runtime copy function
  cpy←{cpf call ⍺ ⍵}                 ⍝ Convenience Fn for Copying arrays
  mcall←{                            ⍝ Fn to generate multiple assignment
    v←⍺⍺ call (⊃⍺),⍵                 ⍝ Call on the first argument
    1=≢⍺:v                           ⍝ If single target, done.
    v,(1↓⍺)cpy¨⊃⍺                    ⍝ Otherwise, copy results to other args
  }
  gtg←{                              ⍝ Fn to ensure valid target name
    nm←⊃'name'Prop 1↑⍵               ⍝ Name attr of node
    ∧/' '=nm:(⍺ GenArrDec⊂'ign'),1   ⍝ If unnamed, generate temp name
    (⍺ gex¨Split nm)(0)              ⍝ Otherwise, lookup references
  }
  array_free←⍺ gfn 'array_free'      ⍝ Runtime cleaner function reference
  free←{array_free call ⍵}           ⍝ Function to cleanup ararys
  clean←{(⊃⍺){⍵⊣free ⍺}⍣(⊃⌽⍺)⊢⍵}     ⍝ Fn to optionally cleanup temp array
  _←{                                ⍝ Handle each global expr in turn
    n←⊃'class'Prop 1↑⍵               ⍝ Switch on node class
    'atomic'≡n:⍺{                    ⍝ Atomic case: variable reference
      ∧/' '=tgt←⊃'name'Prop 1↑⍵:0    ⍝ Ignore unnamed global references
      tgt←⍺ gex¨Split tgt            ⍝ Vector of target ValueRefs
      src←⍺ gex ⊃'name'Prop 1↑1↓⍵    ⍝ Source ValueRef
      tgt cpy¨src                    ⍝ Copy source to each target
    }⍵
    'monadic'≡n:⍺{                   ⍝ Monadic: FVar Var, Depth always 0
      tgt ist←t←⍺ gtg ⍵              ⍝ Variables to be assigned
      lft←GenNullArrayPtr⍬           ⍝ Left argument is null
      fn←⍺ gfn ⊃'name'Prop 1↑2↓⍵     ⍝ Function is first child
      rgt←⍺ gex ⊃'name'Prop 1↑4↓⍵    ⍝ Right argument is second child
      t clean tgt(fn mcall)lft rgt   ⍝ Make the call
    }⍵
    'dyadic'≡n:⍺{                    ⍝ Dyadic: Var FVar Var
      tgt ist←t←a gtg ⍵              ⍝ Variables to be assigned
      lft←⍺ gex ⊃'name'Prop 1↑2↓⍵    ⍝ Left argument is first child
      fn←⍺ gfn ⊃'name'Prop 1↑4↓⍵     ⍝ Function is second child
      rgt←⍺ gex ⊃'name'Prop 1↑6↓⍵    ⍝ Right argument is third child
      t clean tgt(fn mcall)lft rgt   ⍝ Make the call
    }⍵
  }¨⍵
  _←bldr(⍺ MkRet)0 0                 ⍝ Do a standard return
  fr⊣DisposeBuilder bldr             ⍝ Cleanup and return function reference
}

⍝ LookupExpr
⍝
⍝ Intended Function: Given an environment and a name, find the
⍝ LLVM Value Ref for that name.

LookupExpr←{⍺←⊢ ⋄ nm vl←⍺⊣2⍴⊂0⍴⊂'' ⋄ mod fr bld _←⍺⍺ ⋄ node←⍵
  nam←⊃'name'Prop ⍵                 ⍝ Variable's name
  (i←nm⍳⊂nam)<≢nm:(i⊃vl),nm vl      ⍝ Environment contains binding, use it
  eid←⍎⊃'env'Prop ⍵                 ⍝ Variable's Environment
  pos←⍎⊃'slot'Prop ⍵                ⍝ Position in environment
  fnd←(CountParams fr)-3            ⍝ Get the function depth
  eid=0:'VALUE ERROR'⎕SIGNAL 99     ⍝ Variable should not be in local scope
  eid>fnd:{                         ⍝ Environment points to global space
    val←GetNamedGlobal mod nam      ⍝ Grab the value from the global space
    val,(nam val),¨nm vl            ⍝ Add it to the bindings and return
  }⍬
  env←GetParam fr(2+eid)            ⍝ Pointer to environment frame
  app←BuildStructGEP bld env pos '' ⍝ Pointer to Array Pointer for Variable
  apv←BuildLoad bld app nam         ⍝ Array Pointer for Variable
  apv,nam apv,¨nm vl                ⍝ Update the environment and return
}

⍝ GenCond
⍝
⍝ Intended Function: Generate code for a Condition node.

GenCond←{mod fr bldr env0←⍺⍺ ⋄ nm vl←⍵ ⋄ node←⍺
  te←⊃k←1 Kids ⍺                      ⍝ Children and test expression
  te nm vl←⍵(⍺⍺ LookupExpr)1↑1↓te     ⍝ Find ValueRef of test expression
  gp←BuildStructGEP bldr te 4 ''      ⍝ Get data values pointer
  tp←BuildLoad bldr gp 'tp'           ⍝ Load data values
  ap←ArrayType Int64Type 1            ⍝ Type of an Array
  ap←PointerType ap 0                 ⍝ Pointer type to an array
  tp←BuildBitCast bldr tp ap ''       ⍝ Cast data values to array pointer
  gp←BuildGEP bldr tp (GEPI 0 0) 2 '' ⍝ Value pointer
  tv←BuildLoad bldr gp 'tv'           ⍝ Load value
  zr←ConstInt Int64Type 0 1           ⍝ We're testing against zero
  t←BuildICmp bldr 32 tv zr 'T'       ⍝ We test at the end of block
  cb←AppendBasicBlock fr 'consequent' ⍝ Consequent basic block
  _←PositionBuilderAtEnd bldr cb      ⍝ Point builder to consequent
  _←⍵(⍺⍺ GenFnBlock)1↓k               ⍝ Generate the consequent block
  ob←GetPreviousBasicBlock cb         ⍝ Original basic block
  ab←AppendBasicBlock fr 'alternate'  ⍝ Alternate basic block
  _←PositionBuilderAtEnd bldr ob      ⍝ We need to add a conditional break
  _←BuildCondBr bldr t ab cb          ⍝ To the old block pointing to cb and ab
  _←PositionBuilderAtEnd bldr ab      ⍝ And then return pointing at the ab
  nm vl                               ⍝ Return our possibly new environment
}

⍝ GenExpr
⍝
⍝ Intended Function: Generate an Expression, named or unnamed.

GenExpr←{mod fr bldr env0←⍺⍺ ⋄ nm vl←⍵ ⋄ node←⍺
  gnf←{GetNamedFunction mod ⍵}          ⍝ Convenience function
  call←{BuildCall bldr ⍺ ⍵ (≢⍵) ''}     ⍝ Op to build call
  cpf←gnf 'array_cp'                    ⍝ Foreign copy function
  cpy←{0=⍺:0 ⋄ cpf call ⍺ ⍵}            ⍝ Copy wrapper
  gret←{GetParam ⍵ 0}                   ⍝ Fn to get result array
  gloc←{BuildStructGEP bldr(⊃env0)⍺ ⍵}  ⍝ Fn to get local variable
  garg←{0=⍵:⍬ ⋄ GetParam ⍺ ⍵}           ⍝ Fn to get a function parameter
  cls←⊃'class'Prop 1↑⍺                  ⍝ Node Class
  nms←Split ⊃'name'Prop 1↑⍺             ⍝ Assignment variables
  sl←⍕¨Split ⊃'slots'Prop 1↑⍺           ⍝ Slots for variable assignments
  tgt←sl{0=≢⍵:gret fr ⋄ ⍺ gloc¨⍵}nms    ⍝ Target Value Refs for assignment
  tgh←⊃tgt ⋄ tgr←1↓tgt                  ⍝ Split into head and rest targets
  'atomic'≡cls:⍺(⍺⍺{                    ⍝ Atomic: Var Reference
    av nm vl←⍵(⍺⍺ LookupExpr)1↑1↓⍺      ⍝ Lookup variable
    nb←(nms,nm)(((≢nms)↑tgt),vl)        ⍝ New bindings
    0=≢nms:nb⊣bldr(mod MkRet)env0       ⍝ Unnamed is a return
    nb⊣tgt cpy¨av                       ⍝ Named is a copy
  })⍵
  lft nm vl f r←⍺(⍺⍺{                   ⍝ Left argument handled based on arity
    gnap←GenNullArrayPtr                ⍝ Convenience
    dlft←⍺⍺{⍵(⍺⍺LookupExpr)1↑2↓⍺}       ⍝ Grab left argument in dyadic case
    'monadic'≡cls:(gnap⍬),⍵,2 4         ⍝ No new bindings, Fn Rgt ←→ 1st, 2nd
    'dyadic'≡cls:(⍺ dlft ⍵),4 6         ⍝ New bindings, Fn Rgt ←→ 2nd, 3rd
    'BAD CLASS'⎕SIGNAL 99               ⍝ Error trap just in case
  })⍵
  fn←gnf⊃'name'Prop 1↑f↓⍺               ⍝ Grab function (pre-declared)
  rgt nm vl←nm vl(⍺⍺ LookupExpr)1↑r↓⍺   ⍝ Lookup right argument
  fd←-(CountParams fn)-3                ⍝ Callee depth
  cd←(CountParams fr)-3                 ⍝ Caller depth
  env←fd↑(⊃env0),fr garg¨3+⍳cd          ⍝ Environments to pass to callee
  _←fn call tgh,lft,rgt,env             ⍝ Build the call
  nb←(nms,nm)(((≢nms)↑tgt),vl)          ⍝ New bindings
  0=≢nms:nb⊣bldr(mod MkRet)env0         ⍝ Unnamed is a return
  nb⊣tgr cpy¨tgh                        ⍝ Copy rest of names; return bindings
}

⍝ MkRet
⍝
⍝ Intended Function: Insert a return at the end of a function body

MkRet←{
  cln←GetNamedFunction ⍺⍺ 'clean_env' ⍝ Runtime function to clean environment
  _←BuildCall ⍺ cln ⍵ 2 ''            ⍝ Clean the local environment
  zero←ConstInt Int32Type 0 0         ⍝ Zero integer
  BuildRet ⍺ zero                     ⍝ Return a success status
}

⍝ GenNullArrayPtr
⍝
⍝ Intended Function: Generate a null pointer to an array.

GenNullArrayPtr←{
  T←PointerType (GenArrayType⍬) 0 ⍝ Array Type
  ConstPointerNull T              ⍝ Null Pointer
}

⍝ GenArrayType
⍝
⍝ Intended Function: Constant function returning the type of an
⍝ array.
⍝
⍝ See the Software Architecture for details on the Array Structure.

GenArrayType←{
  D←PointerType (Int64Type) 0
  S←PointerType (Int32Type) 0
  lt←(Int16Type)(Int64Type)(Int8Type) S D
  StructType lt 5 0
}

⍝ GenFuncType
⍝
⍝ Intended Function: A constant function returning the type of a
⍝ Function.

GenFuncType←{
  typ←PointerType (GenArrayType⍬) 0 ⍝ All arguments are array pointers
  ret←Int32Type ⋄ arg←((3+⍵)⍴typ)   ⍝ Return type and arg type vector
  FunctionType ret arg (≢arg) 0     ⍝ Return the function type
}

⍝ GEPIndices
⍝
⍝ Intended Function: Generate an array of pointers to be used as
⍝ inputs to the BuildGEP function.

GEPI←{{ConstInt (Int32Type) ⍵ 0}¨⍵}

⍝ GenRuntime
⍝
⍝ Intended Function: Generate declarations for the Co-dfns runtime
⍝ in an LLVM Module.

GenRuntime←{
  two←GenFuncType ¯1
  std←GenFuncType 0
  add←⍵ {AddFunction ⍺⍺ ⍵ ⍺}
  _←two add¨'array_cp' 'array_free'
  rt←'apl_plus' 'apl_minus' 'apl_div'
  rt,←'apl_times' 'apl_residue' 'apl_exp'
  rt,←'apl_log' 'apl_max' 'apl_min' 'apl_lessthan'
  rt,←'apl_lessthaneq' 'apl_equal' 'apl_noteq'
  rt,←'apl_greaterthan' 'apl_greatthaneq'
  _←std add¨rt
  0 0⍴⍬
}

⍝ Foreign Functions

∇{Z}←FFI∆INIT;P;Core;ExEng;X86Info;X86CodeGen;X86Desc;R
Z←⍬
Core←LLVMCore
ExEng←LLVMExecutionEngine
X86Info←LLVMX86Info
X86CodeGen←LLVMX86CodeGen
X86Desc←LLVMX86Desc
R←CoDfnsRuntime
P←'LLVM'

⍝ LLVMTypeRef LLVMInt8Type (void)
'Int8Type'⎕NA 'P ',Core,'|',P,'Int8Type'

⍝ LLVMTypeRef  LLVMInt16Type (void)
'Int16Type'⎕NA 'P ',Core,'|',P,'Int16Type'

⍝ LLVMTypeRef  LLVMInt32Type (void)
'Int32Type'⎕NA 'P ',Core,'|',P,'Int32Type'

⍝ LLVMTypeRef  LLVMInt64Type (void)
'Int64Type'⎕NA 'P ',Core,'|',P,'Int64Type'

⍝ LLVMTypeRef
⍝ LLVMFunctionType (LLVMTypeRef ReturnType,
⍝    LLVMTypeRef *ParamTypes, unsigned ParamCount, LLVMBool IsVarArg)
'FunctionType'⎕NA 'P ',Core,'|',P,'FunctionType P <P[] U I'

⍝ LLVMTypeRef
⍝ LLVMStructType (LLVMTypeRef *ElementTypes, unsigned ElementCount, LLVMBool Packed)
'StructType'⎕NA 'P ',Core,'|',P,'StructType <P[] U I'

⍝ LLVMPointerType (LLVMTypeRef ElementType, unsigned AddressSpace)
'PointerType'⎕NA 'P ',Core,'|',P,'PointerType P U'

⍝ LLVMTypeRef 	LLVMArrayType (LLVMTypeRef ElementType, unsigned ElementCount)
'ArrayType'⎕NA'P ',Core,'|',P,'ArrayType P U'

⍝ LLVMValueRef  LLVMConstInt (LLVMTypeRef IntTy, unsigned long long N, LLVMBool SignExtend)
'ConstInt'⎕NA 'P ',Core,'|',P,'ConstInt P U8 I'

⍝ LLVMValueRef  LLVMConstIntOfString (LLVMTypeRef IntTy, const char *Text, uint8_t Radix)
'ConstIntOfString'⎕NA 'P ',Core,'|',P,'ConstIntOfString P <0C[] U8'

⍝ LLVMValueRef
⍝ LLVMConstArray (LLVMTypeRef ElementTy, LLVMValueRef *ConstantVals, unsigned Length)
'ConstArray'⎕NA 'P ',Core,'|',P,'ConstArray P <P[] U'

⍝ LLVMValueRef 	LLVMConstPointerNull (LLVMTypeRef Ty)
'ConstPointerNull'⎕NA'P ',Core,'|',P,'ConstPointerNull P'

⍝ LLVMValueRef  LLVMAddGlobal (LLVMModuleRef M, LLVMTypeRef Ty, const char *Name)
'AddGlobal'⎕NA 'P ',Core,'|',P,'AddGlobal P P <0C[]'

⍝ void  LLVMSetInitializer (LLVMValueRef GlobalVar, LLVMValueRef ConstantVal)
'SetInitializer'⎕NA '',Core,'|',P,'SetInitializer P P'

⍝ LLVMValueRef  LLVMAddFunction (LLVMModuleRef M, const char *Name, LLVMTypeRef FunctionTy)
'AddFunction'⎕NA 'P ',Core,'|',P,'AddFunction P <0C[] P'

⍝ LLVMValueRef  LLVMGetNamedGlobal (LLVMModuleRef M, const char *Name)
'GetNamedGlobal'⎕NA 'P ',Core,'|',P,'GetNamedGlobal P <0C[]'

⍝ LLVMValueRef 	LLVMGetNamedFunction (LLVMModuleRef M, const char *Name)
'GetNamedFunction'⎕NA 'P ',Core,'|',P,'GetNamedFunction P <0C[]'

⍝ LLVMBasicBlockRef  LLVMAppendBasicBlock (LLVMValueRef Fn, const char *Name)
'AppendBasicBlock'⎕NA 'P ',Core,'|',P,'AppendBasicBlock P <0C[]'

⍝ LLVMBuilderRef  LLVMCreateBuilder (void)
'CreateBuilder'⎕NA 'P ',Core,'|',P,'CreateBuilder'

⍝ void  LLVMPositionBuilderAtEnd (LLVMBuilderRef Builder, LLVMBasicBlockRef Block)
'PositionBuilderAtEnd'⎕NA 'P ',Core,'|',P,'PositionBuilderAtEnd P P'

⍝ LLVMValueRef  LLVMBuildRet (LLVMBuilderRef, LLVMValueRef V)
'BuildRet'⎕NA'P ',Core,'|',P,'BuildRet P P'

⍝ LLVMValueRef 	LLVMBuildRetVoid (LLVMBuilderRef)
'BuildRetVoid'⎕NA'P ',Core,'|',P,'BuildRetVoid P'

⍝ LLVMValueRef
⍝ LLVMBuildCondBr (LLVMBuilderRef, LLVMValueRef If, LLVMBasicBlockRef Then,
⍝     LLVMBasicBlockRef Else)
'BuildCondBr'⎕NA'P ',Core,'|',P,'BuildCondBr P P P P'

⍝ LLVMValueRef
⍝ LLVMBuildCall (LLVMBuilderRef, LLVMValueRef Fn,
⍝     LLVMValueRef *Args, unsigned NumArgs, const char *Name)
'BuildCall'⎕NA'P ',Core,'|',P,'BuildCall P P <P[] U <0C'

⍝ void  LLVMDisposeBuilder (LLVMBuilderRef Builder)
'DisposeBuilder'⎕NA 'P ',Core,'|',P,'DisposeBuilder P'

⍝ LLVMValueRef
⍝ LLVMConstStruct (LLVMValueRef *ConstantVals, unsigned Count, LLVMBool Packed)
'ConstStruct'⎕NA'P ',Core,'|',P,'ConstStruct <P[] U I'

⍝ LLVMValueRef 	LLVMBuildAlloca (LLVMBuilderRef, LLVMTypeRef Ty, const char *Name)
'BuildAlloca'⎕NA'P ',Core,'|',P,'BuildAlloca P P <0C'

⍝ LLVMValueRef 	LLVMBuildLoad (LLVMBuilderRef, LLVMValueRef PointerVal, const char *Name)
'BuildLoad'⎕NA'P ',Core,'|',P,'BuildLoad P P <0C'

⍝ LLVMValueRef 	LLVMBuildStore (LLVMBuilderRef, LLVMValueRef Val, LLVMValueRef Ptr)
'BuildStore'⎕NA'P ',Core,'|',P,'BuildStore P P P'

⍝ LLVMBasicBlockRef 	LLVMGetInsertBlock (LLVMBuilderRef Builder)
'GetInsertBlock'⎕NA'P ',Core,'|',P,'GetInsertBlock P'

⍝ LLVMValueRef 	LLVMGetLastInstruction (LLVMBasicBlockRef BB)
'GetLastInstruction'⎕NA'P ',Core,'|',P,'GetLastInstruction P'

⍝ LLVMBasicBlockRef 	LLVMGetPreviousBasicBlock (LLVMBasicBlockRef BB)
'GetPreviousBasicBlock'⎕NA'P ',Core,'|',P,'GetPreviousBasicBlock P'

⍝ LLVMValueRef
⍝ LLVMBuildStructGEP (LLVMBuilderRef B, LLVMValueRef Pointer, unsigned Idx, const char *Name)
'BuildStructGEP'⎕NA'P ',Core,'|',P,'BuildStructGEP P P U <0C'

⍝ LLVMValueRef
⍝ LLVMBuildGEP (LLVMBuilderRef B, LLVMValueRef Pointer, LLVMValueRef *Indices,
⍝     unsigned NumIndices, const char *Name)
'BuildGEP'⎕NA'P ',Core,'|',P,'BuildGEP P P <P[] U <0C'

⍝ LLVMValueRef
⍝ LLVMBuildBitCast (LLVMBuilderRef, LLVMValueRef Val, LLVMTypeRef DestTy, const char *Name)
'BuildBitCast'⎕NA'P ',Core,'|',P,'BuildBitCast P P P <0C'

⍝ LLVMValueRef
⍝ LLVMBuildICmp (LLVMBuilderRef, LLVMIntPredicate Op, LLVMValueRef LHS,
⍝     LLVMValueRef RHS, const char *Name)
'BuildICmp'⎕NA'P ',Core,'|',P,'BuildICmp P U P P <0C'

⍝ LLVMValueRef
⍝ LLVMBuildArrayAlloca (LLVMBuilderRef,
⍝     LLVMTypeRef Ty, LLVMValueRef Val, const char *Name)
'BuildArrayAlloca'⎕NA'P ',Core,'|',P,'BuildArrayAlloca P P P <0C'

⍝ LLVMValueRef 	LLVMGetParam (LLVMValueRef Fn, unsigned Index)
'GetParam'⎕NA'P ',Core,'|',P,'GetParam P U'

⍝ unsigned 	LLVMCountParams (LLVMValueRef Fn)
'CountParams'⎕NA'U ',Core,'|',P,'CountParams P'

⍝ LLVMBool
⍝ LLVMPrintModuleToFile (LLVMModuleRef M, const char *Filename, char **ErrorMessage)
'PrintModuleToFile'⎕NA'I4 ',Core,'|',P,'PrintModuleToFile P <0C >P'

⍝ void LLVMDisposeMessage (char *Message)
'DisposeMessage'⎕NA'',Core,'|',P,'DisposeMessage P'

⍝ LLVMModuleRef LLVMModuleCreateWithName (const char *ModuleID)
'ModuleCreateWithName'⎕NA'P ',Core,'|',P,'ModuleCreateWithName <0C'

⍝ LLVMValueRef
⍝ LLVMAddAlias (LLVMModuleRef M, LLVMTypeRef Ty, LLVMValueRef Aliasee, const char *Name)
'AddAlias'⎕NA'P ',Core,'|',P,'AddAlias P P P <0C'

⍝ LLVMBool
⍝ LLVMCreateJITCompilerForModule (LLVMExecutionEngineRef *OutJIT,
⍝     LLVMModuleRef M, unsigned OptLevel, char **OutError)
'CreateJITCompilerForModule'⎕NA'I ',ExEng,'|',P,'CreateJITCompilerForModule >P P U >P'

⍝ LLVMGenericValueRef
⍝ LLVMRunFunction (LLVMExecutionEngineRef EE,
⍝     LLVMValueRef F, unsigned NumArgs, LLVMGenericValueRef *Args)
'RunFunction'⎕NA'P ',ExEng,'|',P,'RunFunction P P U <P[]'

⍝ void * LLVMGenericValueToPointer (LLVMGenericValueRef GenVal)
'GenericValueToPointer'⎕NA'P ',ExEng,'|',P,'GenericValueToPointer P'

⍝ void LLVMDisposeGenericValue (LLVMGenericValueRef GenVal)
'DisposeGenericValue'⎕NA ExEng,'|',P,'DisposeGenericValue P'

⍝ LLVMBool
⍝ LLVMFindFunction (LLVMExecutionEngineRef EE, const char *Name, LLVMValueRef *OutFn)
'FindFunction'⎕NA'I ',ExEng,'|',P,'FindFunction P <0C >P'

⍝ void 	LLVMSetTarget (LLVMModuleRef M, const char *Triple)
'SetTarget'⎕NA Core,'|',P,'SetTarget P <0C'

⍝ #define 	LLVM_TARGET(TargetName)   void LLVMInitialize##TargetName##TargetInfo(void);
⍝ #define 	LLVM_TARGET(TargetName)   void LLVMInitialize##TargetName##Target(void);
⍝ #define 	LLVM_TARGET(TargetName)   void LLVMInitialize##TargetName##TargetMC(void);
('Initialize',Target,'TargetInfo')⎕NA X86Info,'|',P,'Initialize',Target,'TargetInfo'
('Initialize',Target,'Target')⎕NA X86CodeGen,'|',P,'Initialize',Target,'Target'
('Initialize',Target,'TargetMC')⎕NA X86Desc,'|',P,'Initialize',Target,'TargetMC'

⍝ void 	LLVMDumpModule (LLVMModuleRef M)
'DumpModule'⎕NA Core,'|',P,'DumpModule P'

⍝ void FFIGetDataInt (int64_t **res, struct codfns_array *)
'FFIGetDataInt'⎕NA R,'|FFIGetDataInt >I8[] P'

⍝ void FFIGetShape (uint32_t **res, struct codfns_array *)
'FFIGetShape'⎕NA R,'|FFIGetShape >U4[] P'

⍝ uint64_t FFIGetSize (struct codfns_array *)
'FFIGetSize'⎕NA 'U8 ',R,'|FFIGetSize P'

⍝ uint16_t FFIGetRank (struct codfns_array *)
'FFIGetRank'⎕NA 'U2 ',R,'|FFIGetRank P'

⍝ void *memcpy(void *dst, void *src, size_t size)
'cstring'⎕NA'libc.so.6|memcpy >C[] P P'

⍝ size_t strlen(char *str)
'strlen'⎕NA'P libc.so.6|strlen P'

∇

:EndNamespace

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Notes on Style
⍝
⍝ ∘ Global variables are camel case
⍝ ∘ Local variables are lower case
⍝ ∘ Function bodies receive a two column code/comment layout
⍝ ∘ Comments of entire function body should align
⍝ ∘ Avoid needless bindings
⍝ ∘ Divide bindings based on clarity of documentation
⍝ ∘ Prefer tacit programming
⍝ ∘ Keep to 80 columns
⍝ ∘ Every global function must have an intended function documented in comments

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ Notes on each increment development

⍝ Increment 1 Overview:
⍝
⍝ ∘ Support an empty namespace
⍝ ∘ Generate an empty LLVM Object to a file
⍝ ∘ Create passes Tokenize, GenLLVM, Parse
⍝ ∘ Add support for stimuli: Fix Break Eot Fnb Fne Fnf Lle Lls Nl Nse Nss
⍝
⍝ Handling of the Break Stimuli is automatic, and does not need to be handled
⍝ explicitly

⍝ Increment 2 Overview:
⍝
⍝ ∘ Support static global constants of integers
⍝ ∘ New Stimuli: N ← V { }
⍝ ∘ Support functions that return constants of integers
⍝ ∘ New Passes: KillLines, LiftConsts
⍝ ∘ Modified Passes: GenLLVM, Tokenize, Parse
⍝
⍝ GenLLVM Modifications:
⍝
⍝ ∘ Handle global arrays
⍝ ∘ Generate single basic block, one-statement function bodies that
⍝   reference a single global variable
⍝
⍝ Tokenize Modifications:
⍝
⍝ ∘ Integers
⍝ ∘ Variable names
⍝ ∘ Assignment
⍝ ∘ Braces
⍝
⍝ Parse Modifications:
⍝
⍝ ∘ Integer arrays
⍝ ∘ Constant expressions
⍝ ∘ Assignment to literal integer array expressions
⍝ ∘ Assignment to user-defined functions

⍝ Increment 3 Overview:
⍝
⍝ ∘ Implement all of top-level space
⍝ ∘ Top-level Stimuli: ⋄ ← Break Eot Fix Fnb Fne Fnf Lle Lls Nl
⍝   Nse Nss Vi Vfo Vu E Fe
⍝
⍝ Impact Analysis
⍝ ===============
⍝
⍝ IsFnb     Must be implemented to handle the Fnb stimuli.
⍝ ModToNS   Must be implemented.
⍝ Tokenize  Add support for the ⋄ token.
⍝ Parse     Must add support for the ⋄ stimuli.
⍝ GenFunc   Must add support for multiple names to a single function.
⍝ DropUnmd  Add a new pass to drop the unnamed functions that could
⍝           appear at the top-level.

⍝ Increment 4 Overview:
⍝
⍝ ∘ Complete all code to cover Bind ∊ NO states in the Functions space
⍝ ∘ Return a JIT'd or Fixed Namespace (Functions only)
⍝
⍝ Impact Analysis
⍝ ===============
⍝
⍝ These additions have mostly to do with handline a more complete body
⍝ of the function, which will require some additional changes in the
⍝ handling of Tokenize first and foremost to support the : token:
⍝
⍝   1. Update Tokenize to handle the : token
⍝
⍝ Furthermore, we now allow multi-line functions, which will require
⍝ extending how we parse functions currently. We can roughly divide this
⍝ into a series of stages. The first stage corresponds to handling the
⍝ { and } tokens and encapsulating the entire function space, which also
⍝ happens to fully deal with the 0th state of the Function Space.
⍝
⍝   2. Extend handling of { and } to deal with multi-line functions.
⍝
⍝ The next state that is left unfinished is the 1st state, which can be
⍝ handled separately, and should be used to dispatch into the rest of
⍝ the states.
⍝
⍝   3. Complete handling of Function State 1.
⍝
⍝ Function State 4 ( { Vu ) deals with a single unbound variable. We are
⍝ not dealing with any assignments here, which means that all behaviors
⍝ encapsulated by the state are subsumed by Function State 5 ( { E ).
⍝ So we can deal with Vu implicitly rather than explicitly. Function
⍝ State 2 needs to be dealt with explicitly, but the difference between
⍝ this and states 5 and 8 are a matter of the : token.
⍝
⍝   4. Deal with parsing the : token.
⍝
⍝ With this taken care of, we can handle all other cases of the state 2,
⍝ so we should clear that at this point.
⍝
⍝   5. Complete handling of parse state 2.
⍝
⍝ Once States 0 - 2 are cleared, states 5 and 8 fall out as the next
⍝ natural elements, so we should parse those next.
⍝
⍝   6. Complete parsing of function states 5 and 8.
⍝
⍝ This finally leaves only state 3, which is a simple case at the moment,
⍝ so we can complete the handling of state 3 now.
⍝
⍝   7. Complete parsing of function state 3.
⍝
⍝ At the completion of Step 7, we will have multi expression function bodies,
⍝ but without function bindings or nested functions. We will also have
⍝ conditional branching. We must first extend the compiler to handle
⍝ multiple expressions in the body of a function. We will allow expressions
⍝ to be either bound or not, but still constant. This means we will need to
⍝ extend the parser to handle top-level unbound expressions and function
⍝ level bound expressions.
⍝
⍝   8. Extend parser to handle more general constant expressions in both
⍝      function bodies and top-level.
⍝
⍝ This will also necessitate modifying DropUnmd to handle top-level
⍝ unbound expressions.
⍝
⍝   9. Extend DropUnmd pass to handle unbound top-level constant expressions.
⍝
⍝ Now we can extend the compiler to handle multiple expressions in the
⍝ function body. We should start with a new compiler pass to remove code
⍝ that will never be executed in the function, so that we do not need to
⍝ generate code for this.
⍝
⍝   10. Create a new compiler pass that eliminates any code in a function
⍝       body that will never be executed by the shape of the conditionals
⍝       and the bindings of the body.
⍝
⍝ At this point LiftConst will need to be modified to handle multiple
⍝ expressions in the body and to lift all of the constants in the
⍝ function body to the top-level.
⍝
⍝   11. Modify LiftConst to handle multiple expression function bodies
⍝       and to lift all of the constants in said body to the top-level,
⍝       but to keep the local bindings local.
⍝
⍝ Next GenFunc will need to be modified to handle multiple expressions in
⍝ a function body as well as conditional expressions.
⍝
⍝   12. Modify GenFunc to handle multiple constant expressions in a function
⍝       body and to handle branching in the system. This will require a
⍝       means of dealing with local bindings and the return value of expressions
⍝       and assignment as an expression and not as a statement.

⍝ Increment 5 Overview:
⍝
⍝ ∘ Support Expressions without nesting or selection:
⍝    0 empty
⍝    1 Fea
⍝    3 N
⍝    5 Va
⍝    6 Vna
⍝    7 Vnu
⍝    9 Fea N
⍝   10 Fea Va
⍝   11 Fea Vna
⍝   16 N Vnu
⍝
⍝ ∘ Only atomic Function Expressions:
⍝   0 empty
⍝
⍝ ∘ Basic scalar function primitives:
⍝   + - ÷ × | * ⍟ ⌈ ⌊ < ≤ = ≠ ≥ >
⍝
⍝ ∘ Basic structural primitives
⍝   ⍴ , ≡ ≢
⍝
⍝ ∘ Only over integers without overflow concerns
⍝
⍝ ∘ JIT'd namespace support
⍝
⍝ Steps for completing Increment 5
⍝ ────────────────────────────────
⍝
⍝ 1. Update Software Architecture with a function signature
⍝
⍝ 2. Update Tokenize with new stimuli: D[a] & M[a]
⍝    + - ÷ × | * ⍟ ⌈ ⌊ < ≤ = ≠ ≥ >
⍝
⍝ 3. Rewrite ParseFuncExpr to handle atomics
⍝
⍝ 4. Rewrite ParseExpr
⍝   a. Split on Function nodes
⍝   b. Enclose literals and variables
⍝   c. Apply nesting levels
⍝
⍝ 5. Make sure that ParseExpr has the right environment from the top-level
⍝    and from function bodies.
⍝
⍝ 6. Rewrite DropUnreached
⍝
⍝ 7. Adapt Liftconsts to handle new expression types and function expressions.
⍝
⍝ 8. Add a pass to insert allocations
⍝
⍝ 9. Add a pass to flatten function calls.
⍝
⍝ 10. Add a pass to convert free variables to environment references
⍝
⍝ 11. Add support for function calls in GenLlvm
⍝
⍝ 12. Add a pass to replace primitive function names with runtime names
⍝
⍝ 13. Fix ModToNs
⍝
⍝ 14. Implement runtime functions
⍝
⍝ 15. Update Software Architecture to include new attributes that were added
⍝
⍝ 16. Update ConvertArray to handle higher-ranked arrays
⍝
⍝ 17. Update FFI declarations to use multiple libraries so that things work on
⍝     OpenSuse
