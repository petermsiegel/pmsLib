 ∆PRE←{⎕IO ⎕ML ⎕PP←0 1 34
  ⍝H ∆PRE    20190711
  ⍝H - Preprocesses contents of codeFileName (a 2∘⎕FIX-format file) and fixes in
  ⍝H   the workspace (via 2 ⎕FIX ppData, where ppData is the processed version of the contents).
  ⍝H - Returns: (shyly) the list of objects created (possibly none).
  ⍝H
  ⍝H names ← [⍺:opts preamble1 ... preambleN] ∆PRE ⍵:codeFileName
  ⍝H
  ⍝H ---------------------------------------------------------
  ⍝H   ⍺
  ⍝H (1↑⍺):opts   Contains one or more of the following letters:
  ⍝H              V, D, M | S, Q; H
  ⍝H ---------------------------------------------------------
  ⍝H
  ⍝H Verbosity
  ⍝H    'V' (Verbose)The default
  ⍝H                 Preprocessor directives and APL lines with macro replacements
  ⍝H                 are shown in the ⎕FIXed output code as comments
  ⍝H Debugging output
  ⍝H    'D' (Debug)
  ⍝H                 Details on the flow of execution are showed in the stdout (⎕←...)
  ⍝H                 For function ⍵, the function __⍵__, which shows all the details, is preserved.
  ⍝H                 See Debugging Flags below.
  ⍝H     D sets 'V' as well.
  ⍝H
  ⍝H Are multi-line double-quoted strings treated as
  ⍝H multiple strings or a single strings with NLs
  ⍝H        str ← "line1
  ⍝H               line2
  ⍝H               line three"
  ⍝H    'M' (Mult)   The default
  ⍝H                 A multiline DQ string ends up as multiple char vectors
  ⍝H                 str←'line1' 'line2' 'line3'
  ⍝H    'S' (Single) A multiline DQ string ends up as a single string with embedded newlines
  ⍝H                 str←('line1',(⎕UCS 13),'line2',(⎕UCS 13),'line three')
  ⍝H    'Q' or ''
  ⍝H                 None of 'DVS' above.
  ⍝H                 put no extra comments in output and no details on the console
  ⍝H                 Q will force ∆PRE to ignore #.__DEBUG__.
  ⍝H     'C'         (Compress)Remove blank lines and comment lines!
  ⍝H Help Information
  ⍝H    'H'          Show this HELP information
  ⍝H    '?' | 'h'    Same as 'H'
  ⍝H
  ⍝H Debugging Flags
  ⍝H    If __DEBUG__ (in the NS ∆PRE was called FROM) is defined,
  ⍝H    DEBUG mode is set, even if the 'D' flag is not given.
  ⍝H           unless 'Q' (quiet) mode is set.
  ⍝H    If DEBUG mode is set,
  ⍝H           internal flag variable __DEBUG__ is defined (DEF'd) as 1.
  ⍝H           In addition, Verbose mode is set.
  ⍝H    Otherwise,
  ⍝H           Internal flag variable __DEBUG__ is defined as 0.
  ⍝H           Verbose mode then depends on the 'V' flag (default is 1).
  ⍝H
  ⍝H    Use ::IF __DEBUG__ etc. to change behavior based on debug status.
  ⍝H
  ⍝H
  ⍝H ---------------------------------------------------------
  ⍝H   ⍺
  ⍝H (1↓⍺): preamble1 ... preambleN
  ⍝H ---------------------------------------------------------
  ⍝H    Zero or more lines of a preamble to be included at the start,
  ⍝H    e.g. ⍺ might include definitions to "import"
  ⍝H         'V' '::DEF PHASE1' '::DEF pi ← 3.13'
  ⍝H          ↑   ↑__preamble1   preamble2
  ⍝H          ↑__ option(s)
  ⍝H
  ⍝H ---------------------------------------------------------------------------------
  ⍝H   ⍵
  ⍝H ⍵:codeFN   The filename of the function, operator, namespace, or set of objects
  ⍝H ---------------------------------------------------------------------------------
  ⍝H
  ⍝H    The simple name, name.ext, or full filename
  ⍝H    of the function or cluster of objects compatible with (2 ⎕FIX ⍵),
  ⍝H    whose source will be loaded from:
  ⍝H      [a] if ⍵ has no filetype/extension,
  ⍝H             ⍵.dyapp,
  ⍝H          or (if not found in ⍵.dyapp),
  ⍝H             ⍵.dyalog
  ⍝H      [b] else
  ⍝H             ⍵ by itself.
  ⍝H    THese directories are searched:
  ⍝H           .  ..  followed by dirs named in env vars FSPATH and WSPATH (: separates dirs)
  ⍝H ---------
  ⍝H Returns
  ⍝H ---------
  ⍝H Returns (shyly) the names of the 0 or more objects fixed via (2 ⎕FIX code).
  ⍝H
  ⍝H ---------------------------------------------------------------------------------
  ⍝H Features:
  ⍝H ---------------------------------------------------------------------------------
  ⍝H   ∘ implicit macros
  ⍝H       Hex number converted to decimal
  ⍝H            0FACX /[\d][\dA-F]*[xX]/
  ⍝H       Big integers (any length) /¯?\d+[iI]/ converted to quoted numeric string.
  ⍝H            04441433566767657I →  '04441433566767657'
  ⍝H       num1 [num2] .. num3    .. is either the ellipsis char. or 2 or more dots.
  ⍝H            Creates a real progression from num1 to num3 with delta (num2-num1)
  ⍝H   ∘ explicit macros replaced
  ⍝H       See ::DEF, ::CDEF
  ⍝H   ∘ continuation lines end with .. (either the ellipsis char. or 2 or more dots),
  ⍝H     possibly with a preceding comment. In the output file, the lines are
  ⍝H     connected with the set of comments on the continuation lines on the last line
  ⍝H     or (if large) the following (otherwise blank) line
  ⍝H       vec←  1  2  3  4   5 ...   ⍝ Line 1
  ⍝H            ¯1 ¯2 ¯3 ¯4  ¯5 ..    ⍝ Line 2
  ⍝H            60 70 80 90 100       ⍝ Last line
  ⍝H     ==>
  ⍝H       vec← 1 2 3 4 5  ¯1 ¯2 ¯3 ¯4 ¯5 60 70 80 90 100
  ⍝H       ⍝ Line 1 ⍝ Line 2 ⍝ Last line
  ⍝H   ∘ Double quoted strings under options M (default) or S.
  ⍝H     str←"This is line 1.
  ⍝H          This is line 2.
  ⍝H          This is line 3."
  ⍝H   ==>
  ⍝H   option 'M':
  ⍝H     str←'This is line 1.' 'This is line 2.' 'This is line 3.'
  ⍝H   option 'S':
  ⍝H     str←('This is line 1.',(⎕UCS 13),'This is line 2.',(⎕UCS 13),'This is line 3.')
  ⍝H
  ⍝H    Directives
  ⍝H       ::IF      cond         If cond is an undefined name, returns false, as if ::IF 0
  ⍝H       ::IFDEF   name         If name is defined, returns true even if name has value 0
  ⍝H       ::IFNDEF  name
  ⍝H       ::ELSEIF  cond
  ⍝H       ::ELIF                 Alias for ::ELSEIF
  ⍝H       ::ELSE
  ⍝H       ::END                  ::ENDIF, ::ENDIFDEF; allows ::END followed by ANY text
  ⍝H       ::DEF     name ← [VAL] VAL may be an APL code sequence, including comments
  ⍝H                              or nullstring. If parens are needed, use them.
  ⍝H       ::DEF     name ←       Sets name to a nullstring, not its quoted value.
  ⍝H       ::DEF     name         Same as ::DEF name ← 'name'
  ⍝H       ::DEFINE  name ...     Alias for ::DEF ...
  ⍝H       ::CDEF    name ...     Like ::DEF, except executed only if name is undefined
  ⍝H       ::UNDEF   name         Undefines name, warning if already undefined
  ⍝H       ::VAL     name ...     Same as ::DEF, except name ← ⍎val
  ⍝H       ::INCLUDE [name[.ext] | "dir/file" | 'dir/file']
  ⍝H       ::INCL    name
  ⍝H       ::IMPORT  name1 name2  Set internal name1 from the value of name2 in the calling env.
  ⍝H       ::IMPORT  name1        The value must be used in a context that makes sense.
  ⍝H                              If name2 omitted, it is the same as name1.
  ⍝H                              big←?2 3 4⍴100
  ⍝H                              :IMPORT big
  ⍝H                              ::IF 3=⍴⍴big   ⍝ Makes sense
  ⍝H                              ⎕←big          ⍝ Will not work!
  ⍝H       ----------------
  ⍝H       cond: Is 0 if value of expr is 0, '', or undefined! Else 1.
  ⍝H       ext:  For ::INCLUDE/::INCL, extensions checked first are .dyapp and .dyalog.
  ⍝H             Paths checked are '.', '..', then dirs in env vars FSPATH and WSPATH.

     ⍺←,'V' ⋄ o←⊃⊆⍺
     1∊'Hh?'∊o:{⎕ED'___'⊣___←↑⍵/⍨(↑2↑¨⍵)∧.='⍝H'}2↓¨⎕NR⊃⎕XSI

     0≠≢o~'VDQSMC ':11 ⎕SIGNAL⍨'∆PRE: Options are any of {V or D, S or M},  Q, C, or H (default ''VM'')'

   ⍝ Preprocessor variable #.__DEBUG__ is always 1 or 0 (unless UNDEF'd)
     DEBUG←(~'Q'∊o)∧('D'∊o)∨(0⊃⎕RSI){0=⍺.⎕NC ⍵:0 ⋄ ⍺.⎕OR ⍵}'__DEBUG__'

     1:_←DEBUG{      ⍝ ⍵: [0] funNm, [1] tmpNm, [2] lines
         condSave←{  ⍝ ⍺=1: Keep __name__. ⍺=0: Delete __name__ unless error.
             _←⎕EX 1⊃⍵
             ⍺:⍎'(0⊃⎕RSI).',(1⊃⍵),'←2⊃⍵'   ⍝ Save preprocessor "log"  __⍵__, if 'D' option or #.__DEBUG__
             2⊃⍵
         }
         0::11 ⎕SIGNAL⍨{
             _←1 condSave ⍵
             _←'Preprocessor error. Generated object for input "',(0⊃⍵),'" is invalid.',⎕TC[2]
             _,'See preprocessor output: "',(1⊃⍵),'"'
         }⍵
         1:2 ⎕FIX{⍵/⍨(⎕UCS 0)≠⊃¨⍵}{~'C'∊o:⍵ ⋄ '^\h*(?:⍝.*)?$'⎕R(⎕UCS 0)⊣⍵}(⍺ condSave ⍵)
     }(⊆⍺){
         o preamble←{(⊃⍺)(⊆1↓⍺)}⍨⍺
       ⍝ ∆GENERAL ∆UTILITY ∆FUNCTIONS
         ∆PASS←{~VERBOSE:EMPTY ⋄ '⍝',(' '⍴⍨+/∧\' '=⍵),⍵}   ⍝ EMPTY←⎕UCS 0 (defined below)
         ∆NOTE←{⍺←0 ⋄ DEBUG∧⍺:⍞←⍵ ⋄ DEBUG:⎕←⍵ ⋄ ''}        ⍝ Keep notes only if DEBUG true.

       ⍝ ∆FLD: ⎕R helper.  ⍵ [default] ∆FLD [fld number | name]
         ∆FLD←{
             ns def←2↑⍺,⊂''
             ' '=1↑0⍴⍵:⍺ ∇ ns.Names⍳⊂⍵
             ⍵=0:ns.Match                                  ⍝ Fast way to get whole match
             ⍵≥≢ns.Lengths:def                             ⍝ Field not defined AT ALL → ''
             ns.Lengths[⍵]=¯1:def                          ⍝ Defined field, but not used HERE (within this submatch) → ''
             ns.(Lengths[⍵]↑Offsets[⍵]↓Block)              ⍝ Simple match
         }
       ⍝ ∆MAP: replaces elements of string ⍵ of form ⍎name with value of name.
       ⍝       recursive (within limits ⍺←10) if ⍵≢∆MAP ⍵
         ∆MAP←{⍺←15 ⋄ ∆←'⍎[\w∆⍙⎕]+'⎕R{⍎1↓⍵ ∆FLD 0}⍠'UCP' 1⊣⍵ ⋄ (⍺>0)∧∆≢⍵:(⍺-1)∇ ∆ ⋄ ∆}

         ∆QT←{⍺←'''' ⋄ ⍺,⍵,⍺}
         ∆DQT←{'"'∆QT ⍵}
         ∆DEQUOTE←{⍺←'"''' ⋄ ⍺∊⍨1↑⍵:1↓¯1↓⍵ ⋄ ⍵}
         ∆QT0←{⍺←'''' ⋄ ⍵/⍨1+⍵∊⍺}
         ∆QTX←{⍺←'''' ⋄ ⍺ ∆QT ⍺ ∆QT0 ⍵}

         h2d←{                                             ⍝ Decimal from hexadecimal
             11::'h2d: number too large'⎕SIGNAL 11         ⍝ number too big.
             16⊥16|a⍳⍵∩a←'0123456789abcdef0123456789ABCDEF'⍝ Permissive-- ignores non-hex chars!
         }

         ∆TRUE←{ ⍝ ⍵ is true if it is valid APL code
                 ⍝ unless its value is 0-length (number or character) or is a simple 0.
             ans←{0::0⊣⍞←'∆TRUE: CAN''T EVALUATE "',⍵,'" RETURNING 0'
                 0=≢⍵~' ':0 ⋄ 0=≢val←∊(⊃⎕RSI)⍎⍵:0 ⋄ (,0)≡val:0
                 1
             }⍵
             ans
         }

       ⍝ GENERAL CONSTANTS
         NL←⎕UCS 10 ⋄ EMPTY←,⎕UCS 0                        ⍝ An EMPTY line will be deleted before ⎕FIXing
       ⍝ DEBUG - see above...
         VERBOSE←1∊'VD'∊o ⋄ QUIET←VERBOSE⍱DEBUG

         DQ_SINGLE←'S'∊o    ⍝ Else 'M' (default)
         YES NO SKIP INFO←'  ' ' 😞' ' 🚫' ' 💡'

       ⍝ Process double quotes based on DQ_SINGLE flag.

         processDQ←{⍺←DQ_SINGLE   ⍝ If 1, create a single string. If 0, create char vectors.
             DQ←'"'
             u13←''',(⎕UCS 13),'''
             opts←('Mode' 'M')('EOL' 'LF')
             ⍺:'(',')',⍨∆QT'\n\h+'⎕R u13⍠opts⊢∆QT0 ∆DEQUOTE ⍵  ⍝ ('line1',(⎕UCS 13),'line2'...)
             '\n\h+'⎕R''' '''⍠opts⊢∆QTX ∆DEQUOTE ⍵           ⍝  'line1' 'line2' ...
         }
      ⍝ Append literal strings ⍵:SV.                      ⍝ res@B(←⍺) ← ⍺@B←1 appendRaw ⍵:SV
         appendRaw←{⍺←1 ⋄ ⍺⊣dataFinal,←⍵}
      ⍝ Append quoted string                              ⍝ res@B ←  ⍺@B←1 appendCond ⍵:SV
         appendCond←{PASSTHRU=1↑⍵:appendRaw⊂'⍙,←⊂',∆QTX 1↓⍵ ⋄ 0 appendRaw⊂⍵}¨
      ⍝ Pad str ⍵ to at least ⍺ (15) chars.
         padx←{⍺←15 ⋄ ⍺<≢⍵:⍵ ⋄ ⍺↑⍵}
      ⍝ get function '⍵' or its char. source '⍵_src', if defined.
         getDataIn←{∆∆←∇
             ⍺←{∪{(':'≠⍵)⊆⍵}'.:..',∊':',¨{⊢2 ⎕NQ'.' 'GetEnvironment'⍵}¨⍵}'FSPATH' 'WSPATH'
             0=≢⍺:11 ⎕SIGNAL⍨'Unable to find or load source file ',(∆DQT ⍵),' (filetype must be dyapp or dyalog)'
             dir dirs←(⊃⍺)⍺
             types←{
                 0≠≢⊃⌽⎕NPARTS ⍵:⊂''     ⍝ If the file has an explicit type, use only it...
                 '.dyapp' '.dyalog'
             }⍵
             types{
                 0=≢⍺:(1↓dirs)∆∆ ⍵
                 filenm←(2×dir≡,'.')↓dir,'/',⍵,⊃⍺
                 ⎕NEXISTS filenm:filenm(⊃⎕NGET filenm 1)
                 (1↓⍺)∇ ⍵
             }⍵
         }

      ⍝ MACRO (NAME) PROCESSING
      ⍝ functions...
         put←{n v←⍵ ⋄ n~←' ' ⋄ names,⍨←⊂n ⋄ vals,⍨←⊂v ⋄ 1:⍵}  ⍝ add name val
         get←{n←⍵~' ' ⋄ p←names⍳⊂n ⋄ p≥≢names:n ⋄ p⊃vals}
         del←{n←⍵~' ' ⋄ p←names⍳⊂n ⋄ p≥≢names:n ⋄ names vals⊢←(⊂p≠⍳≢names)/¨names vals ⋄ n}
         def←{n←⍵~' ' ⋄ p←names⍳⊂n ⋄ p≥≢names:0 ⋄ 1}
         expand←{
             else←⊢
           ⍝ Concise variant on dfns:to, allowing start [incr] to end
           ⍝     1 1.5 to 5     →   1 1.5 2 2.5 3 3.5 4 4.5 5
           ⍝ expanded to allow simply (homogeneous) Unicode chars
           ⍝     'ac' to 'g'    →   'aceg'
             ∆TO←{⎕IO←0 ⋄ 0=80|⎕DR ⍬⍴⍺:⎕UCS⊃∇/⎕UCS¨⍺ ⍵ ⋄ f s←1 ¯1×-\2↑⍺,⍺+×⍵-⍺ ⋄ f+s×⍳0⌈1+⌊(⍵-f)÷s+s=0}
             ∆TOcode←'{⎕IO←0 ⋄ 0=80|⎕DR ⍬⍴⍺:⎕UCS⊃∇/⎕UCS¨⍺ ⍵ ⋄ f s←1 ¯1×-\2↑⍺,⍺+×⍵-⍺ ⋄ f+s×⍳0⌈1+⌊(⍵-f)÷s+s=0}'
             str←⍵
             str←{⍺←MAX_EXPAND       ⍝ If 0, macros including hex, bigInt, etc. are NOT expanded!!!
                 strIn←str←⍵
                 0≥⍺:⍵
             ⍝ Match/Expand...
             ⍝ [1] pLNe: long names,
                 cSQe cCe cLNe←0 1 2
                 str←{
                     4::⎕EN ⎕SIGNAL⍨'∆PRE: Macro value in code is too complex: "',⍵,'"'
                     pSQe pCOMe pLNe ⎕R{
                         f0←⍵ ∆FLD 0 ⋄ case←⍵.PatternNum∘∊
                         case cSQe:f0
                         case cLNe:⍕get f0                ⍝ Let multilines fail
                       ⍝ case cLNe:1↓∊NL,⎕FMT get f0      ⍝ Deal with multilines...
                         else f0                ⍝ pCOMe
                     }⍠'UCP' 1⊣⍵
                 }str

              ⍝ [2] pSNe: short names (even within found long names)
              ⍝     pINTe: Hexadecimals and bigInts
                 cSQe cCe cSNe cIe←0 1 2 3
                 str←pSQe pCOMe pSNe pINTe ⎕R{
                     f0←⍵ ∆FLD 0 ⋄ case←⍵.PatternNum∘∊

                     case cIe:{⍵∊'xX':⍕h2d f0 ⋄ ∆QT ¯1↓f0}¯1↑f0
                     case cSNe:⍕get f0
                     else f0     ⍝ pSQe or pCOMe
                 }⍠'UCP' 1⊣str
                 str≢strIn:(⍺-1)∇ str    ⍝ expand is recursive, but only initial MAX_EXPAND times.
                 str
             }str
         ⍝  Ellipses - constants (pDOTDOT1e) and variable (pDOTDOT2e)
         ⍝  Check only after all substitutions, so ellipses with macros that resolve to numeric constants
         ⍝  are optimized.
             cSQe cCe cD1e cD2e←0 1 2 3
             str←pSQe pCOMe pDOTDOT1e pDOTDOT2e ⎕R{
                 case←⍵.PatternNum∘∊
                 case cSQe cCe:⍵ ∆FLD 0
                 case cD1e:⍕⍎f1,' ∆TO ',f2⊣f1 f2←⍵ ∆FLD¨1 2  ⍝  num [num] .. num
                 case cD2e:∆TOcode                           ⍝  .. preceded or followed by non-constants
             }⍠'UCP' 1⊣str
             str
         }


      ⍝ -------------------------------------------------------------------------
      ⍝ PATTERNS
      ⍝ [1] DEFINITIONS -
      ⍝ [2] PATTERN PROCESSING
      ⍝ -------------------------------------------------------------------------

      ⍝ -------------------------------------------------------------------------
      ⍝ [1] DEFINITIONS
      ⍝ -------------------------------------------------------------------------
         _CTR_←0 ⋄ patternList←patternName←⍬
         reg←{⍺←'???' ⋄ p←'(?xi)' ⋄ patternList,←⊂∆MAP p,⍵ ⋄ patternName,←⊂⍺ ⋄ (_CTR_+←1)⊢_CTR_}
         ⋄ ppBeg←'^\h* ::\h*'
         cIFDEF←'ifdef'reg'    ⍎ppBeg  IF(N?)DEF         \h+(.*)         $'
         cIF←'if'reg'          ⍎ppBeg  IF                \h+(.*)         $'
         cELSEIF←'elseif'reg'  ⍎ppBeg  EL(?:SE)?IF \b    \h+(.*)         $'
         cELSE←'else'reg'      ⍎ppBeg  ELSE         \b       .*          $'
         cEND←'end'reg'        ⍎ppBeg  END                   .*          $'
         ⋄ ppTarg←' [^←]+ '
         ⋄ ppAssign←'(?:(←)\h*(.*))?'
         ⋄ ppToken←'  (?:"[^"]+")+ | (?:''[^'']+'')+ | ⍎ppLName '
         ⋄ ppSName←'  [\pL∆⍙_\#⎕:] [\pL∆⍙_0-9\#]* '
         ⋄ ppLName←' ⍎ppSName (?: \. ⍎ppSName )*'

         cDEF←'def'reg'      ⍎ppBeg DEF(?:INE)?  \h* (⍎ppTarg) \h*  ⍎ppAssign   $'
         cVAL←'val'reg'      ⍎ppBeg E?VAL        \h* (⍎ppTarg) \h*  ⍎ppAssign   $'
         cINCL←'include'reg' ⍎ppBeg INCL(?:UDE)? \h* (⍎ppToken) .*              $'
         cIMPORT←'import'reg'⍎ppBeg IMPORT       \h* (⍎ppLName) (?:\h+(⍎ppLName))? \h* $'
         cCDEF←'cond'reg'    ⍎ppBeg CDEF         \h* (⍎ppTarg)  \h* ⍎ppAssign   $'
         cUNDEF←'undef'reg'  ⍎ppBeg UNDEF        \h* (⍎ppLName) .*              $'
         cOTHER←'apl'reg'   ^                                   .*              $'

      ⍝ patterns for the ∇expand∇ fn
         pDQe←'(?x)   (    (?: " [^"]*     "  )+  )'
         pSQe←'(?x)   (    (?: ''[^''\n\r]*'' )+  )'    ⍝ Don't allow multi-line SQ strings...
         pCOMe←'(?x)     ⍝ .*  $'
       ⍝ ppNum: A non-complex signed number (float or dec)
         ppNum←' (?: ¯?  (?: \d+ (?: \.\d* )? | \.\d+ ) (?: [eE]¯?\d+ )?  )'~' '
         ppDots←'(?:  … | \.{2,} )'
         pDOTDOT1e←∆MAP'(?x)  ( ⍎ppNum (?: \h+ ⍎ppNum)* ) \h* ⍎ppDots \h* (⍎ppNum)'
         pDOTDOT2e←∆MAP'(?x)   ⍎ppDots'

      ⍝ names include ⎕WA, :IF
      ⍝ pLNe Long names are of the form #.a or a.b.c
      ⍝ pSNe Short names are of the form a or b or c in a.b.c
      ⍝ pINTe: Allows both bigInt format and hex format
      ⍝       This is permissive (allows illegal options to be handled by APL),
      ⍝       but also VALID bigInts like 12.34E10 which is equiv to 123400000000
      ⍝       Exponents are invalid for hexadecimals, because the exponential range
      ⍝       is not defined/allowed.
         pINTe←'(?xi)  (?<![\dA-F\.])  ¯? [\.\d]  (?: [\d\.]* (?:E\d+)? I | [\dA-F]* X)'
         pLNe←∆MAP'(?x) ⍎ppLName'
         pSNe←∆MAP'(?x) ⍎ppSName'
      ⍝       Convert multiline quoted strings "..." to single lines ('...',(⎕UCS 13),'...')
         pCONTe←'(?x) \h* \.{2,} \h* (⍝ .*)? \n\h*'
         pEOLe←'(?x)              \h* (⍝ .*)? \n'


      ⍝ -------------------------------------------------------------------------
      ⍝ [2] PATTERN PROCESSING
      ⍝ -------------------------------------------------------------------------
         processDirectives←{
             T F S←1 0 ¯1    ⍝ true, false, skip
             lineNum+←1
             f0 f1 f2 f3←⍵ ∆FLD¨0 1 2 3
             case←⍵.PatternNum∘∊
          ⍝  Any non-directive, i.e. APL statement, comment, or blank line...
             case cOTHER:{
                 T=⊃⌽stack:{str←expand ⍵ ⋄ QUIET∨str≡⍵:str ⋄ '⍝',⍵,YES,NL,'  ',str}f0
                 ∆PASS f0,SKIP     ⍝ See ∆PASS, QUIET
             }0
           ⍝ ::IFDEF/IFNDEF name
             case cIFDEF:{
                 T≠⊃⌽stack:∆PASS f0,SKIP⊣stack,←S
                 stack,←c←~⍣(1∊'nN'∊f1)⊣def f2
                 ∆PASS f0,' ➡ ',(⍕c),(c⊃NO YES)
             }0
           ⍝ ::IF cond
             case cIF:{
                 T≠⊃⌽stack:∆PASS f0,SKIP⊣stack,←S
                 stack,←c←∆TRUE(e←expand f1)
                 ∆PASS f0,' ➡ ',(⍕e),' ➡ ',(⍕c),(c⊃NO YES)
             }0
          ⍝  ::ELSEIF
             case cELSEIF:{
                 S=⊃⌽stack:∆PASS f0,SKIP⊣stack,←S
                 T=⊃⌽stack:∆PASS f0,NO⊣(⊃⌽stack)←F
                 (⊃⌽stack)←c←∆TRUE(e←expand f1)
                 ∆PASS f0,' ➡ ',(⍕e),' ➡ ',(⍕c),(c⊃NO YES)
             }0
           ⍝ ::ELSE
             case cELSE:{
                 S=⊃⌽stack:∆PASS f0,SKIP⊣stack,←S
                 T=⊃⌽stack:∆PASS f0,NO⊣(⊃⌽stack)←F
                 (⊃⌽stack)←T
                 ∆PASS f0,' ➡ 1',YES
             }0
           ⍝ ::END(IF(N)(DEF))
             case cEND:{
                 stack↓⍨←¯1
                 c←S≠⊃⌽stack
                 0=≢stack:∆PASS'⍝ ',f0,ERR⊣stack←,0⊣⎕←'INVALID ::END statement at line [',lineNum,']'
                 ∆PASS(c⊃'     ' ''),f0     ⍝ Line up cEND with skipped IF/ELSE
             }0
          ⍝ ：：DEF name ← val    ==>  name ← 'val'
          ⍝ ：：DEF name          ==>  name ← 'name'
          ⍝ ：：DEF name ← ⊢      ==>  name ← '⊢'     Make name a NOP
          ⍝ ：：DEF name ← ⍝...      ==>  name ← '⍝...'
          ⍝ Define name as val, unconditionally.
             case cDEF:{
                 T≠stk←⊃⌽stack:∆PASS'⍝ ',f0,(SKIP NO⊃⍨F=stk)
                 noArrow←1≠≢f2
                 f3 note←f1{noArrow∧0=≢⍵:(∆QTX ⍺)'' ⋄ 0=≢⍵:'' '  [EMPTY]' ⋄ (expand ⍵)''}f3
                 _←put f1 f3

                 pad←' '⍴⍨+/∧\' '=f0
                 ∆PASS pad,'DEF ',f1,' ➡ ',f3,note,' ',YES
             }0
           ⍝  ::VAL name ← val    ==>  name ← ⍎'val' etc.
           ⍝  ::VAL i5  ← (⍳5)         i5 set to '(0 1 2 3 4)' (depending on ⎕IO)
           ⍝ Experimental preprocessor-time evaluation
             case cVAL:{
                 T≠stk←⊃⌽stack:∆PASS'⍝ ',f0,(SKIP NO⊃⍨F=stk)
                 noArrow←1≠≢f2
                 f3 note←f1{
                     noArrow∧0=≢⍵:(∆QTX ⍺)''
                     0=≢⍵:'' '  [EMPTY STRING]'
                     {0::(⍵,' ∘∘∘')'  [INVALID EXPRESSION DURING PREPROCESSING]'
                         (⍕⍎⍵)''
                     }expand ⍵
                 }f3
                 _←put f1 f3
                 pad←' '⍴⍨+/∧\' '=f0
                 ∆PASS pad,'VAL ',f1,' ➡ ',f3,note,' ',YES
             }0
          ⍝ ::CDEF name ← val      ==>  name ← 'val'
          ⍝ ::CDEF name            ==>  name ← 'name'
          ⍝  etc.
          ⍝ Set name to val only if name not already defined.
             case cCDEF:{
                 T≠stk←⊃⌽stack:∆PASS'⍝ ',f0,(SKIP NO⊃⍨F=stk)
                 defd←def f1

                 defd:∆PASS'⍝ ',f0,NO
                 noArrow←1≠≢f2
                 f3←f1{noArrow∧0=≢⍵:∆QTX ⍺ ⋄ 0=≢⍵:'' ⋄ expand ⍵}f3
                 _←put f1 f3
                 pad←' '⍴⍨+/∧\' '=f0
                 ∆PASS pad,'CDEF ',f1,' ➡ ',f3,(' [EMPTY] '/~0=≢f3),' ',YES
             }0
           ⍝ ::UNDEF name
           ⍝ Warns if <name> was not set!
             case cUNDEF:{
                 T≠stk←⊃⌽stack:∆PASS'⍝ ',f0,(SKIP NO⊃⍨F=stk)
                 _←del f1⊣{def ⍵:'' ⋄ ⎕←INFO,' UNDEFining an undefined name: ',⍵}f1
                 ∆PASS f0,YES
             }0
           ⍝ ::INCLUDE file or "file with spaces" or 'file with spaces'
           ⍝ If file has no type, .dyapp [dyalog preprocessor] or .dyalog are assumed
             case cINCL:{
                 T≠stk←⊃⌽stack:∆PASS'⍝ ',f0,(SKIP NO⊃⍨F=stk)
                 funNm←∆DEQUOTE f1
                 _←1 ∆NOTE INFO,2↓(bl←+/∧\f0=' ')↓f0
                 (fullNm dataIn)←getDataIn funNm
                 _←1 ∆NOTE',',msg←' file "',fullNm,'", ',(⍕≢dataIn),' lines',NL

                 _←fullNm{
                     includedFiles,←⊂⍺
                     ~⍵∊⍨⊂⍺:⍬
                   ⍝ See ::extern INCLUDE_LIMITS
                     count←+/includedFiles≡¨⊂⍺
                     warn err←(⊂INFO,'::INCLUDE '),¨'WARNING: ' 'ERROR: '
                     count≤1↑INCLUDE_LIMITS:⍬
                     count≤¯1↑INCLUDE_LIMITS:⎕←warn,'File "',⍺,'" included ',(⍕count),' times'
                     11 ⎕SIGNAL⍨err,'File "',⍺,'" included too many times (',(⍕count),')'
                 }includedFiles

                 includeLines∘←dataIn
                 ∆PASS f0,'  ',INFO,msg
             }0
             case cIMPORT:{
                 f2←f2 f1⊃⍨0=≢f2
                 T≠stk←⊃⌽stack:∆PASS'⍝ ',f0,(SKIP NO⊃⍨F=stk)
                 info←' ','[',']',⍨{
                     0::'NOT FOUND. UNDEFINED'⊣del f1
                     'IMPORTED'⊣put f1((⊃⎕RSI).⎕OR f2)
                 }⍬
                 ∆PASS(30 padx f0),info
             }⍬
         }

      ⍝ --------------------------------------------------------------------------------
      ⍝ EXECUTIVE
      ⍝ --------------------------------------------------------------------------------
       ⍝ User-settable options
         MAX_EXPAND←5  ⍝ Maximum times to expand macros (if 0, none are expanded!)
         INCLUDE_LIMITS←5 10  ⍝ First # is min before warning. Second is max before error.

       ⍝ Initialization
         funNm←⍵
         stack←,1
         lineNum←0
         tmpNm←'__',funNm,'__'

         fullNm dataIn←getDataIn funNm       ⍝ dataIn: SV
         includedFiles←⊂fullNm
         NLINES←≢dataIn ⋄ NWIDTH←⌈10⍟NLINES

         _←∆NOTE'Processing object ',(∆DQT funNm),' from file "',∆DQT fullNm
         _←∆NOTE'Object has ',NLINES,' lines'
         dataFinal←⍬

         names←vals←⍬
         ⋄ _←put'__DEBUG__'DEBUG

         includeLines←⍬
       ⍝ Go!

         comment←⍬
         lines←pDQe pCONTe pSQe pEOLe ⎕R{
             f0 f1←⍵ ∆FLD¨0 1 ⋄ case←⍵.PatternNum∘∊
             case 0:processDQ f0   ⍝ DQ, w/ possible newlines...
             case 1:' '⊣comment,←(' '/⍨0≠≢f1),f1
             case 2:f0
           ⍝ case 3
             0=≢comment:f0
             ln←comment,' ',f1,NL ⋄ comment⊢←⍬
           ⍝ If the commment is more than (⎕PW÷2), put on newline
             (' 'NL⊃⍨(⎕PW×0.5)<≢ln),1↓ln
         }⍠('Mode' 'M')('EOL' 'LF')('NEOL' 1)⊣preamble,dataIn
       ⍝ Process macros... one line at a time, so state is dependent only on lines before...
         lines←{⍺←⍬
             0=≢⍵:⍺
             l←patternList ⎕R processDirectives⍠'UCP' 1⊣⊃⍵
             (⍺,⊂l)∇(includeLines∘←⍬)⊢includeLines,1↓⍵
         }lines
       ⍝ Return specifics to next phase for ⎕FIXing
         funNm tmpNm lines
     }⍵
 }
