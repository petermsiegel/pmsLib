 ∆PRE←{⎕IO ⎕ML ⎕PP←0 1 34
  ⍝  ::EXTERN (Variables global to ∆PRE, but not above)
     __INCLUDE_LIMITS__←__MAX_EXPAND__←__MAX_PROGRESSION__←__PREFIX__←¯1

  ⍝H ∆PRE    20190711
  ⍝H - Preprocesses contents of codeFileName (a 2∘⎕FIX-format file) and fixes in
  ⍝H   the workspace (via 2 ⎕FIX ppData, where ppData is the processed version of the contents).
  ⍝H - Returns: (shyly) the list of objects created (possibly none).
  ⍝H
  ⍝H names ← [⍺:opts preamble1 ... preambleN] ∆PRE ⍵:codeFileName
  ⍝H
  ⍝H ---------------------------------------------------------
  ⍝H   ⍺
  ⍝H  (1↑⍺):opts    Contains one or more of the following letters:
  ⍝H                V; D; E; Q; (M | S);(C | c);  H
  ⍝H   Debugging:   Verbose, Debug, Edit; Quiet
  ⍝H   [DQ lines]:  Multi-line | Single-line;
  ⍝H   Compression: Compress (comments+blank lines), compress (blank lines)
  ⍝H   Help info:   Help
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
  ⍝H     E  (Edit)   ⎕EDits the intermediate preprocessor file(*) when done... (Sets 'D'; Debug mode)
  ⍝H                 (*) The intermed. preproc file is a text file which is ⎕FIXed to create the
  ⍝H                 executables. Unlike the latter, it will be viewable even if the ⎕FIXing fails.
  ⍝H    'Q' or ''    None of 'DV' above.
  ⍝H                 put no extra comments in output and no details on the console
  ⍝H                 Q will force ∆PRE to ignore #.__DEBUG__.
  ⍝H
  ⍝H Are multi-line double-quoted strings treated as
  ⍝H multiple strings or a single strings with NLs
  ⍝H     str ← "line1
  ⍝H            line2
  ⍝H            line three"
  ⍝H    'M' (Mult)   The default
  ⍝H                 A multiline DQ string ends up as multiple char vectors
  ⍝H                 str←'line1' 'line2' 'line3'
  ⍝H    'S' (Single) A multiline DQ string ends up as a single string with embedded newlines
  ⍝H                 str←('line1',(⎕UCS 13),'line2',(⎕UCS 13),'line three')
  ⍝H
  ⍝H    'C'          (Compress) Remove blank lines and comment lines (most useful w/ Q)!
  ⍝H    'c'          (small compress) Remove blank lines only!
  ⍝H Help Information
  ⍝H    'H'          Show this HELP information
  ⍝H    '?' | 'h'    Same as 'H'
  ⍝H
  ⍝H Debugging Flags
  ⍝H    If __DEBUG__ is defined in the namespace from which ∆PRE was called,
  ⍝H           then __DEBUG__ mode is set, even if the 'D' flag is not specified.
  ⍝H           unless 'Q' (quiet) mode is set explicitly.
  ⍝H           debugmode:  (__DEBUG__∨D)∧~Q
  ⍝H    If __DEBUG__ mode is set,
  ⍝H           internal macro "variable" __DEBUG__ is defined (DEF'd) as 1, as if:
  ⍝H                 ::VAL __DEBUG__ ← (__DEBUG__∨option_D)∧~option_Q   ⍝ Pseudocode...
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
  ⍝H  (1↓⍺): preamble1 ... preambleN
  ⍝H ---------------------------------------------------------
  ⍝H    Zero or more lines of a preamble to be included at the start,
  ⍝H    e.g. ⍺ might include definitions to "import"
  ⍝H         'V' '::DEF PHASE1' '::DEF pi ← 3.13'
  ⍝H          ↑   ↑__preamble1   preamble2
  ⍝H          ↑__ option(s)
  ⍝H
  ⍝H ---------------------------------------------------------------------------------
  ⍝H  ⍵
  ⍝H  ⍵:codeFN   The filename of the function, operator, namespace, or set of objects
  ⍝H             ⎕NULL: Prompt for lines from the user, creating pseudo-function
  ⍝H                 __PROMPT__
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
  ⍝H     ∘ HEXADECIMALS: Hex number converted to decimal
  ⍝H             0FACX /[\d][\dA-F]*[xX]/
  ⍝H     ∘ BIG INTEGERS: Big integers (of any length) /¯?\d+[iI]/ are converted to
  ⍝H             quoted numeric strings for use with Big Integer routines.
  ⍝H             04441433566767657I →  '04441433566767657'
  ⍝H     ∘ PROGRESSIONS: num1 [num2] .. num3
  ⍝H             Progressions use either the ellipsis char (…) or 2 or more dots (..).
  ⍝H             Creates a real-number progression from num1 to num3
  ⍝H             with delta (num2-num1), defaulting to 1 or ¯1.
  ⍝H             With constants  (10 0.5 .. 15), the progression is calculated at
  ⍝H             preprocessor time; with variables, a DFN is inserted to calculate at run time.
  ⍝H     ∘ MAPS: word1 word2 ... wordN → anything
  ⍝H             where word1 is an APL-style name or an APL number;
  ⍝H             such that numbers are left as is, but names are quoted:
  ⍝H               func (name → 'John Smith', age → 25, code 1 → (2 3⍴⍳6)) ==>
  ⍝H               func (('name')'John Smith'),('age')25,('code' 1)(2 3⍴⍳6))
  ⍝H     ∘ ATOM:    `word1 word2 ... wordN
  ⍝H             as for MAPS, as in:
  ⍝H                `red orange  02FFFEX green ==>
  ⍝H                ('red' 'orange' 196606 'green')      ⍝ Hex number converted to decimal
  ⍝H
  ⍝H   ∘ explicit macros for text replacement
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
  ⍝H     These may appear on one or more lines. By default, leading blanks on
  ⍝H     continuation lines are ignored, allowing follow-on lines to easily line up
  ⍝H     under the first line. (See the DQ Raw suffix below).
  ⍝H     str←"This is line 1.
  ⍝H          This is line 2.
  ⍝H          This is line 3."
  ⍝H   ==>
  ⍝H   option 'M':
  ⍝H     str←'This is line 1.' 'This is line 2.' 'This is line 3.'
  ⍝H   option 'S':
  ⍝H     str←('This is line 1.',(⎕UCS 13),'This is line 2.',(⎕UCS 13),'This is line 3.')
  ⍝H
  ⍝H   ∘ DQ Raw Suffix:
  ⍝H     Double-quoted strings followed (w/o spaces) by the R (raw) suffix will NOT have
  ⍝H     leading spaces on continuation lines removed.
  ⍝H     Options M and S (above) are both supported.
  ⍝H     "This is a
  ⍝H      raw format
  ⍝H   double string."R
  ⍝H   ==>  (option 'M')
  ⍝H     'This is a' '      raw format' 'double string.'
  ⍝H
  ⍝H    Directives
  ⍝H       (Note: currently comments are removed from preprocessor directives
  ⍝H        before processing.
  ⍝H       ::IF      cond         If cond is an undefined name, returns false, as if ::IF 0
  ⍝H       ::IFDEF   name         If name is defined, returns true even if name has value 0
  ⍝H       ::IFNDEF  name
  ⍝H       ::ELSEIF  cond
  ⍝H       ::ELIF                 Alias for ::ELSEIF
  ⍝H       ::ELSE
  ⍝H       ::END                  ::ENDIF, ::ENDIFDEF; allows ::END followed by ANY text
  ⍝H       ::DEF     name ← [VAL] VAL may be an APL code sequence, including the null string
  ⍝H                              If parens are needed, use them.
  ⍝H                              If you want to ignore lines by prefixing with comments,
  ⍝H                              use EVAL. Comments are IGNORED on directive lines, unless quoted.
  ⍝H       ::DEF     name ←       Sets name to a nullstring, not its quoted value.
  ⍝H       ::DEF     name         Same as ::DEF name ← 'name'
  ⍝H       ::DEFINE  name ...     Alias for ::DEF ...
  ⍝H       ::DEFQ    name ...     Like ::DEF except quoted evaluated string
  ⍝H       ::CDEF    name ...     Like ::DEF, except executed only if name is undefined
  ⍝H       ::[E]VAL  name ...     Same as ::DEF, except name ← ⍎val
  ⍝H       ::[E]VALQ name ...     Same as ::EVAL, except result is quoted.
  ⍝H                 ∘ Note that ::DEF creates a string of code (including comments),
  ⍝H                 and is "TRUE" if it is not-null.  EVAL executes the string to determine
  ⍝H                 its value; it is true if not 0, or an object of length 0.
  ⍝H
  ⍝H       ∘ To create a macro to "null out" code lines (have them ignored),
  ⍝H         you can't use ::DEF, because (visible) comments are ignored for directives.
  ⍝H         Instead, use ::VAL, which allows you to present the comment in quotes,
  ⍝H         which ::VAL will evaluate (i.e. dequote) as an actual comment sequence.
  ⍝H                      ::VAL PHASE1 ← '⍝ IGNORE PHASE1: '
  ⍝H                      PHASE1 b←do_something_with 'PHASE1'
  ⍝H         Treated as:  ⍝ IGNORE PHASE1: b←do_something_with 'PHASE1'
  ⍝H                      ::VAL PHASE2 ← ''   ⍝ Don't ignore PHASE2.
  ⍝H                                          ⍝ Or do ::DEF PHASE2←       ⍝ null "code" assigned
  ⍝H                      PHASE2 b←do_something_with 'PHASE2'
  ⍝H         Treated as:  b←do_something_with 'PHASE2'
  ⍝H
  ⍝H
  ⍝H       ::UNDEF   name         Undefines name, warning if already undefined
  ⍝H       ::INCLUDE [name[.ext] | "dir/file" | 'dir/file']
  ⍝H       ::INCL    name
  ⍝H       ::IMPORT  name1 name2  Set internal name1 from the value of name2 in the calling env.
  ⍝H       ::IMPORT  name1        The value must be used in a context that makes sense.
  ⍝H                              If name2 omitted, it is the same as name1.
  ⍝H                              big←?2 3 4⍴100
  ⍝H                              big2←'?2 3 4⍴100'
  ⍝H                              ::IMPORT big
  ⍝H                              ::IF 3=⍴⍴big   ⍝ Makes sense
  ⍝H                              ⎕←big          ⍝ Will not work!
  ⍝H                              ::IMPORT big2
  ⍝H                              ⎕←big2         ⍝ Will work
  ⍝H       ----------------
  ⍝H       cond: Is 0 if value of expr is 0, '', or undefined! Else 1.
  ⍝H       ext:  For ::INCLUDE/::INCL, extensions checked first are .dyapp and .dyalog.
  ⍝H             Paths checked are '.', '..', then dirs in env vars FSPATH and WSPATH.

     ⍺←'V' ⋄ opts←⊃⊆,⍺
     1∊'Hh?'∊opts:{⎕ED'___'⊣___←↑⍵/⍨(↑2↑¨⍵)∧.='⍝H'}2↓¨⎕NR⊃⎕XSI

     0≠≢opts~'VDQSMCc ':11 ⎕SIGNAL⍨'∆PRE: Options are any of {V or D}, {S or M}, Q, C, or H (default ''VM'')'

     EDIT←(⎕NULL≡⍵)∨'E'∊opts
   ⍝ Preprocessor variable (0⊃⎕RSI).__DEBUG__ is always 1 or 0 (unless user UNDEFs it)
     __DEBUG__←EDIT∨('D'∊opts)∨(~'Q'∊opts)∧(0⊃⎕RSI){0=⍺.⎕NC ⍵:0 ⋄ ⍺.⎕OR ⍵}'__DEBUG__'

     1:_←__DEBUG__{      ⍝ ⍵: [0] funNm, [1] tmpNm, [2] lines
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
         1:2 ⎕FIX{⍵/⍨(⎕UCS 0)≠⊃¨⍵}{
             'c'∊opts:'^\h*$'⎕R(⎕UCS 0)⊣⍵
             'C'∊opts:'^\h*(?:⍝.*)?$'⎕R(⎕UCS 0)⊣⍵
             ⍵
         }(⍺ condSave ⍵){
             ~EDIT:⍺
             ⍺⊣(0⊃⎕RSI).⎕ED(1⊃⍵)
         }⍵
     }(⊆,⍺){
         opts preamble←{(⊃⍺)(⊆1↓⍺)}⍨⍺

       ⍝ ∆GENERAL ∆UTILITY ∆FUNCTIONS
       ⍝
       ⍝ ∆IF_VERBOSE:  If VERBOSE,
       ⍝         ∘ show Directive (::name) and result as comment in output.
       ⍝         ∘ if len ⍺ not 0, pad ⍵ by its leading blanks.
         ∆IF_VERBOSE←{
             ~VERBOSE:EMPTY ⋄ ⍺←⍬
             0≠≢⍺:'⍝',⍵,⍨⍺↑⍨0⌈¯1++/∧\' '=⍺
             '⍝',(' '⍴⍨0⌈p-1),⍵↓⍨p←+/∧\' '=⍵
         }

         ∆IF_DEBUG←{⍺←0 ⋄ __DEBUG__∧⍺:⍞←⍵ ⋄ __DEBUG__:⎕←⍵ ⋄ ''}

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

         h2d←{   ⍝ Decimal from hexadecimal
             11::'∆PRE hex number (0..X) too large'⎕SIGNAL 11
             16⊥16|a⍳⍵∩a←'0123456789abcdef0123456789ABCDEF'⍝ Permissive:ignores non-hex chars!
         }

       ⍝ ∆TRUE: a "Python-like" sense of truth
       ⍝        ⍵ is true unless its value is 0-length ('', ⍬ etc)
       ⍝                  or 0 or (,0)
         ∆TRUE←{
             ans←{0::0⊣⎕←'∆PRE: Can''t evaluate truth of {',⍵,'}, returning 0'
                 0=≢⍵~' ':0 ⋄ 0=≢val←∊(⊃⎕RSI)⍎⍵:0 ⋄ (,0)≡val:0
                 1
             }⍵
             ans
         }

       ⍝ GENERAL CONSTANTS
         NL←⎕UCS 10 ⋄ EMPTY←,⎕UCS 0 ⍝ Marks ∆PRE-generated lines to be deleted before ⎕FIXing
       ⍝ __DEBUG__ - see above...
         VERBOSE←1∊'VD'∊opts ⋄ QUIET←VERBOSE⍱__DEBUG__
         DQ_SINGLE←'S'∊opts          ⍝ Treatment of "...".  Default is 0 ("M" option).
         YES NO SKIP INFO←' ✓' ' 😞' ' 🚫' ' 💡'

       ⍝ Process double quotes based on DQ_SINGLE flag.
         processDQ←{⍺←DQ_SINGLE   ⍝ If 1, create a single string. If 0, create char vectors.
             str type←⍵
             ⋄ lit←'R'∊type
             ⋄ DQ←'"'
             ⋄ u13←''',(⎕UCS 13),'''
             ⋄ opts←('Mode' 'M')('EOL' 'LF')
             ⍺∧lit:'(',')',⍨∆QT'\n'⎕R u13⍠opts⊢∆QT0 ∆DEQUOTE str       ⍝ Single mode ∧ literal
             ⍺:'(',')',⍨∆QT'\n\h*'⎕R u13⍠opts⊢∆QT0 ∆DEQUOTE str        ⍝ Single mode
             lit:'\n'⎕R''' '''⍠opts⊢∆QTX ∆DEQUOTE str                  ⍝ Multi  mode ∧ literal
             '\n\h*'⎕R''' '''⍠opts⊢∆QTX ∆DEQUOTE str                   ⍝ Multi  mode

             '∆PRE: processDQ logic error'⎕SIGNAL 911
         }


       ⍝ getDataIn:
       ⍝ get function '⍵' or its char. source '⍵_src', if defined.
       ⍝ Returns ⍵:the object name, the full file name found, (the lines of the file)
       ⍝ If the obj is ⎕NULL, the object is prompted from the user.
       ⍝ (See promptForData) for returned value.
         getDataIn←{∆∆←∇
             19::'∆PRE: Invalid or missing file'⎕SIGNAL 19
             ⍵≡⎕NULL:promptForData ⍬
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
                 ⎕NEXISTS filenm:⍵ filenm(⊃⎕NGET filenm 1)
                 (1↓⍺)∇ ⍵
             }⍵
         }
         promptForData←{
             ⎕←'Enter lines. Empty line to terminate.'
             lines←{⍺←⊂'__TERM__'
                 0=≢l←⍞↓⍨≢⍞←⍵:⍺
                 (⍺,⊂l)∇ ⍵
             }'> '
             '__PROMPT__' '__NONE__'lines
         }

      ⍝ MACRO (NAME) PROCESSING
      ⍝ functions...
      ⍝ For now, special macros start and end with __.
         put←{⍺←__DEBUG__
             n v←⍵   ⍝ add (name, val) to macro list
             n~←' '
             names,⍨←⊂n
             vals,⍨←⊂v
             '____'≢4↑¯2⌽n:⍵     ⍝ Not of form:  __chars__
             ⍝ Special macros-- all integers ≥0.
             n{
                 0::⍵                       ⍝ Error? Quietly move on.
                 v←{0::⍵ ⋄ ⌊0⌈⍎⍕⍵}v        ⍝ Ensure integers at least 0
                 _←⍎n,'∘←v'                 ⍝ Execute in ∆PRE space, not user space.
                 ⍺:⍵⊣⎕←'Set special variable ',n,' ← ',(⍕v),' [EMPTY]'/⍨0=≢v
                 ⍵
             }⍵
         }
         get←{n←⍵~' ' ⋄ p←names⍳⊂n ⋄ p≥≢names:n ⋄ p⊃vals}
         del←{n←⍵~' ' ⋄ p←names⍳⊂n ⋄ p≥≢names:n ⋄ names vals⊢←(⊂p≠⍳≢names)/¨names vals ⋄ n}
         def←{n←⍵~' ' ⋄ p←names⍳⊂n ⋄ p≥≢names:0 ⋄ 1}

      ⍝-----------------------------------------------------------------------
      ⍝ mExpand (macro expansion, including special predefined expansion)
      ⍝     …                     for continuation
      ⍝     …                     for numerical sequences
      ⍝     25X                   for hexadecimal constants
      ⍝     25I                   for big integer constants
      ⍝     post USA → 14850      for implicit quoted (name) strings and numbers on left
      ⍝     `red 025X yellow      for implicit quoted (name) strings and numbers on right
      ⍝
      ⍝-----------------------------------------------------------------------
         mExpand←{
             else←⊢
           ⍝ Concise variant on dfns:to, allowing start [incr] to end
           ⍝     1 1.5 to 5     →   1 1.5 2 2.5 3 3.5 4 4.5 5
           ⍝ expanded to allow simply (homogeneous) Unicode chars
           ⍝     'ac' to 'g'    →   'aceg'
             ∆TO←{⎕IO←0 ⋄ 0=80|⎕DR ⍬⍴⍺:⎕UCS⊃∇/⎕UCS¨⍺ ⍵ ⋄ f s←1 ¯1×-\2↑⍺,⍺+×⍵-⍺ ⋄ f+s×⍳0⌈1+⌊(⍵-f)÷s+s=0}
             ∆TOcode←'{⎕IO←0 ⋄ 0=80|⎕DR ⍬⍴⍺:⎕UCS⊃∇/⎕UCS¨⍺ ⍵ ⋄ f s←1 ¯1×-\2↑⍺,⍺+×⍵-⍺ ⋄ f+s×⍳0⌈1+⌊(⍵-f)÷s+s=0}'
             str←⍵
             str←{⍺←__MAX_EXPAND__       ⍝ If 0, macros including hex, bigInt, etc. are NOT expanded!!!
                 strIn←str←⍵
                 0≥⍺:⍵
             ⍝ Match/mExpand...
             ⍝ [1] pLongNmE: long names,
                 cSQe cCommentE cLNe←0 1 2
                 str←{
                     e1←'∆PRE: Value is too complex to represent statically:'
                     4::4 ⎕SIGNAL⍨e1,(⎕UCS 13),'⍝     In macro code: "',⍵,'"'
                     pSQe pCommentE pLongNmE ⎕R{
                         f0←⍵ ∆FLD 0 ⋄ case←⍵.PatternNum∘∊
                         case cSQe:f0
                         case cLNe:⍕get f0                ⍝ Let multilines fail
                       ⍝ case cLNe:1↓∊NL,⎕FMT get f0      ⍝ Deal with multilines...
                         else f0                          ⍝ comments
                     }⍠'UCP' 1⊣⍵
                 }str

              ⍝ [2] pShortNmE: short names (even within found long names)
              ⍝     pSpecialIntE: Hexadecimals and bigInts
                 cSQe cCommentE cShortNmE cSpecialIntE←0 1 2 3
                 str←pSQe pCommentE pShortNmE pSpecialIntE ⎕R{
                     f0←⍵ ∆FLD 0 ⋄ case←⍵.PatternNum∘∊

                     case cSpecialIntE:{⍵∊'xX':⍕h2d f0 ⋄ ∆QT ¯1↓f0}¯1↑f0
                     case cShortNmE:⍕get f0
                     else f0     ⍝ pSQe or pCommentE
                 }⍠'UCP' 1⊣str
                 str≢strIn:(⍺-1)∇ str    ⍝ mExpand is recursive, but only initial __MAX_EXPAND__ times.
                 str
             }str
         ⍝  Ellipses - constants (pDot1e) and variable (pDot2e)
         ⍝  Check only after all substitutions, so ellipses with macros that resolve to numeric constants
         ⍝  are optimized.
         ⍝  See __MAX_PROGRESSION__ below
             cSQe cCommentE cDot1E cDot2E cAtomsE←0 1 2 3 4
             str←pSQe pCommentE pDot1e pDot2e pATOMSe ⎕R{
                 ⋄ qt2←{(⊃⍵)∊'¯.',⎕D:⍵ ⋄ ∆QT ⍵}
                 case←⍵.PatternNum∘∊
                 case cSQe cCommentE:⍵ ∆FLD 0
                 case cAtomsE:'(',')',⍨,1↓∊' ',¨qt2¨' '(≠⊆⊢)⍵ ∆FLD 1
                 case cDot2E:∆TOcode
               ⍝ case cDot1E
                 ⋄ f1 f2←⍵ ∆FLD¨1 2
                 ⋄ progr←⍎f1,' ∆TO ',f2
                 __MAX_PROGRESSION__<≢progr:f1,' ',∆TOcode,' ',f2
                 ⍕progr
                                        ⍝  .. preceded or followed by non-constants

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
         ⋄ ppSetVal←' (?:(←)\h*(.*))?'
         ⋄ ppFiSpec←'  (?: "[^"]+")+ | (?:''[^'']+'')+ | ⍎ppName '
         ⋄ ppSN←'  [\pL∆⍙_\#⎕:] [\pL∆⍙_0-9\#]* '
         ⋄ ppLN←'     ⍎ppSN (?: \. ⍎ppSN )+'   ⍝ Note: Forcing Longnames to have at least one .
         ⋄ ppLN2←'    (?:\h+ (⍎ppLN) )'
         ⋄ ppName←'    ⍎ppSN (?: \. ⍎ppSN )*'   ⍝ ppName - long OR short

         cDEF←'def'reg'      ⍎ppBeg DEF(?:INE)?(Q)?  \h* (⍎ppTarg)  \h*  ⍎ppSetVal   $'
         cVAL←'val'reg'      ⍎ppBeg E?VAL(Q)?        \h* (⍎ppTarg)  \h*  ⍎ppSetVal   $'
         cINCL←'include'reg' ⍎ppBeg INCL(?:UDE)?     \h* (⍎ppFiSpec) .*               $'
         cIMPORT←'import'reg'⍎ppBeg IMPORT           \h* (⍎ppName) (?: \h+ (⍎ppName))?     $'
         cCDEF←'cond'reg'    ⍎ppBeg CDEF(Q)?         \h* (⍎ppTarg)  \h*  ⍎ppSetVal   $'
         cUNDEF←'undef'reg'  ⍎ppBeg UNDEF            \h* (⍎ppName ) .*               $'
         cOTHER←'apl'reg'   ^                                   .*               $'

      ⍝ patterns solely for the ∇mExpand∇ fn
         pDQe←'(?x)   (    (?: " [^"]*     "  )+   ) (R)?'  ⍝ R: raw (keep leading blanks)
         pSQe←'(?x)   (    (?: ''[^'']*'' )+  )'            ⍝ We trap elsewhere multi-line SQ strings...
         pCommentE←'(?x)   ⍝ .*  $'
       ⍝ ppNum: A non-complex signed APL number (float or dec)
         ppNum←' (?: ¯?  (?: \d+ (?: \.\d* )? | \.\d+ ) (?: [eE]¯?\d+ )?  )'~' '
         ppDot←'(?:  … | \.{2,} )'
         pDot1e←∆MAP'(?x)  ( ⍎ppNum (?: \h+ ⍎ppNum)* ) \h* ⍎ppDot \h* (⍎ppNum)'
         pDot2e←∆MAP'(?x)   ⍎ppDot'
      ⍝  Special Integer Constants: Hex (ends in X), Big Integer (ends in I)
         ppHex←'   ¯? \d [\dA-F]*             X'
         ppBigInt←'¯? \d [\d\.]* (?: E \d+ )? I'
         ⍝ pSpecialIntE: Allows both bigInt format and hex format
         ⍝ This is permissive (allows illegal options to be handled by APL),
         ⍝ but also VALID bigInts like 12.34E10 which is equiv to 123400000000
         ⍝ Exponents are invalid for hexadecimals, because the exponential range
         ⍝ is not defined/allowed.
         pSpecialIntE←∆MAP'(?xi)  (?<![\dA-F\.]) (?: ⍎ppHex | ⍎ppBigInt ) '
      ⍝ For MACRO purposes, names include user variables, as well as those with ⎕ or : prefixes (like ⎕WA, :IF)
      ⍝ pLongNmE Long names are of the form #.a or a.b.c
      ⍝ pShortNmE Short names are of the form a or b or c in a.b.c


         pLongNmE←∆MAP'(?x)  ⍎ppLN'
         pShortNmE←∆MAP'(?x) ⍎ppSN'
      ⍝       Convert multiline quoted strings "..." to single lines ('...',(⎕UCS 13),'...')
         pContE←'(?x) \h* \.{2,} \h* (⍝ .*)? \n \h*'
         pEOLe←'\n'
      ⍝ For  (names → ...) and (`names)
         ppNum←'¯?\.?\d[¯\dEJ.]*'    ⍝ Overgeneral, letting APL complain of errors
         ppNums←'  (?: ⍎ppName | ⍎ppNum ) (?: \h+ (?: ⍎ppName | ⍎ppNum ) )*'
         pATOMSe←∆MAP'(?xi)  (?| (⍎ppNums)  \h* → | \` \h* (⍎ppNums) ) '


      ⍝ -------------------------------------------------------------------------
      ⍝ [2] PATTERN PROCESSING
      ⍝ -------------------------------------------------------------------------
         processDirectives←{
             T F S←1 0 ¯1    ⍝ true, false, skip
             lineNum+←1
             f0 f1 f2 f3 f4←⍵ ∆FLD¨0 1 2 3 4
             case←⍵.PatternNum∘∊
             TOP←⊃⌽stack  ⍝ TOP can be T(true) F(false) or S(skip)...

          ⍝  Any non-directive, i.e. APL statement, comment, or blank line...
             case cOTHER:{
                 T=TOP:{str←mExpand ⍵ ⋄ QUIET∨str≡⍵:str ⋄ '⍝',⍵,YES,NL,' ',str}f0
                 ∆IF_VERBOSE f0,SKIP     ⍝ See ∆IF_VERBOSE, QUIET
             }0
           ⍝ ::IFDEF/IFNDEF name
             case cIFDEF:{
                 T≠TOP:∆IF_VERBOSE f0,SKIP⊣stack,←S
                 stack,←c←~⍣(1∊'nN'∊f1)⊣def f2
                 ∆IF_VERBOSE f0,' ➡ ',(⍕c),(c⊃NO YES)
             }0
           ⍝ ::IF cond
             case cIF:{
                 T≠TOP:∆IF_VERBOSE f0,SKIP⊣stack,←S
                 stack,←c←∆TRUE(e←mExpand f1)
                 ∆IF_VERBOSE f0,' ➡ ',(⍕e),' ➡ ',(⍕c),(c⊃NO YES)
             }0
          ⍝  ::ELSEIF
             case cELSEIF:{
                 S=TOP:∆IF_VERBOSE f0,SKIP⊣stack,←S
                 T=TOP:∆IF_VERBOSE f0,NO⊣(⊃⌽stack)←F
                 (⊃⌽stack)←c←∆TRUE(e←mExpand f1)
                 ∆IF_VERBOSE f0,' ➡ ',(⍕e),' ➡ ',(⍕c),(c⊃NO YES)
             }0
           ⍝ ::ELSE
             case cELSE:{
                 S=TOP:∆IF_VERBOSE f0,SKIP⊣stack,←S
                 T=TOP:∆IF_VERBOSE f0,NO⊣(⊃⌽stack)←F
                 (⊃⌽stack)←T
                 ∆IF_VERBOSE f0,' ➡ 1',YES
             }0
           ⍝ ::END(IF(N)(DEF))
             case cEND:{
                 stack↓⍨←¯1
                 c←S≠TOP
                 0=≢stack:∆IF_VERBOSE'⍝??? ',f0,ERR⊣stack←,0⊣⎕←'INVALID ::END statement at line [',lineNum,']'
                 ∆IF_VERBOSE f0     ⍝ Line up cEND with skipped IF/ELSE
             }0
           ⍝ Shared code for
           ⍝   ::DEF(Q) and ::(E)VALQ
             procDefVal←{
                 isVal←⍵
                 T≠TOP:∆IF_VERBOSE f0,(SKIP NO⊃⍨F=TOP)
                 qtFlag arrFlag←0≠≢¨f1 f3
                 val note←f2{
                     (~arrFlag)∧0=≢⍵:(∆QTX ⍺)''
                     0=≢⍵:'' '  [EMPTY]'
                     exp←mExpand ⍵

                     isVal:{                ⍝ ::EVAL | ::VAL
                         m←'WARNING: INVALID EXPRESSION DURING PREPROCESSING'
                         0::(⍵,' ∘∘INVALID∘∘')(m⊣⎕←m,': ',⍵)
                         qtFlag:(∆QTX⍕⍎⍵)''
                         (⍕⍎⍵)''
                     }exp

                     qtFlag:(∆QTX exp)''    ⍝ ::DEF...
                     exp''
                 }f4
                 _←put f2 val
                 nm←(isVal⊃'::DEF' '::VAL'),qtFlag/'Q'
                 f0 ∆IF_VERBOSE nm,' ',f2,' ← ',f4,' ➡ ',val,note,' ',YES
             }
          ⍝ ::DEF | ::DEFQ
          ⍝ ::DEF name ← val    ==>  name ← 'val'
          ⍝ ::DEF name          ==>  name ← 'name'
          ⍝ ::DEF name ← ⊢      ==>  name ← '⊢'     Make name a NOP
          ⍝ ::DEF name ← ⍝...      ==>  name ← '⍝...'
          ⍝   Define name as val, unconditionally.
          ⍝
          ⍝ ::DEFQ ...
          ⍝   Same as ::DEF, except quote val.
             case cDEF:procDefVal 0
           ⍝  ::EVAL | ::EVALQ
           ⍝  ::VAL  | ::VALQ
           ⍝  ::[E]VAL name ← val    ==>  name ← ⍎'val' etc.
           ⍝  ::[E]VAL i5   ← (⍳5)         i5 set to '(0 1 2 3 4)' (depending on ⎕IO)
           ⍝    Returns <val> executed in the caller namespace...
           ⍝  ::EVALQ: like EVAL, but returns the value QUOTED.
           ⍝    Experimental preprocessor-time evaluation
             case cVAL:procDefVal 1
          ⍝ ::CDEF name ← val      ==>  name ← 'val'
          ⍝ ::CDEF name            ==>  name ← 'name'
          ⍝  etc.
          ⍝ Set name to val only if name NOT already defined.
          ⍝ ::CDEFQ ...
          ⍝ Like ::CDEF, but quotes result of CDEF.
             case cCDEF:{
                 T≠TOP:∆IF_VERBOSE f0,(SKIP NO⊃⍨F=TOP)
                 def f2:∆IF_VERBOSE f0,NO   ⍝ If <name> defined, don't ::DEF...
                 qtFlag arrFlag←0≠≢¨f1 f3
                 val←f2{(~arrFlag)∧0=≢⍵:∆QTX ⍺ ⋄ 0=≢⍵:''
                     exp←mExpand ⍵
                     qtFlag:∆QTX exp
                     exp
                 }f4
                 _←put f2 val
                 f0 ∆IF_VERBOSE'::CDEF ',f2,' ← ',f4,' ➡ ',val,(' [EMPTY] '/⍨0=≢val),' ',YES
             }0
           ⍝ ::UNDEF name
           ⍝ Warns if <name> was not set!
             case cUNDEF:{
                 T≠TOP:∆IF_VERBOSE f0,(SKIP NO⊃⍨F=TOP)
                 _←del f1⊣{def ⍵:'' ⋄ ⎕←INFO,' UNDEFining an undefined name: ',⍵}f1
                 ∆IF_VERBOSE f0,YES
             }0
           ⍝ ::INCLUDE file or "file with spaces" or 'file with spaces'
           ⍝ If file has no type, .dyapp [dyalog preprocessor] or .dyalog are assumed
             case cINCL:{
                 T≠TOP:∆IF_VERBOSE f0,(SKIP NO⊃⍨F=TOP)
                 funNm←∆DEQUOTE f1
                 _←1 ∆IF_DEBUG INFO,2↓(bl←+/∧\f0=' ')↓f0
                 (_ fullNm dataIn)←getDataIn funNm
                 _←1 ∆IF_DEBUG',',msg←' file "',fullNm,'", ',(⍕≢dataIn),' lines',NL

                 _←fullNm{
                     includedFiles,←⊂⍺
                     ~⍵∊⍨⊂⍺:⍬
                   ⍝ See ::extern __INCLUDE_LIMITS__
                     count←+/includedFiles≡¨⊂⍺
                     warn err←(⊂INFO,'::INCLUDE '),¨'WARNING: ' 'ERROR: '
                     count≤1↑__INCLUDE_LIMITS__:⍬
                     count≤¯1↑__INCLUDE_LIMITS__:⎕←warn,'File "',⍺,'" included ',(⍕count),' times'
                     11 ⎕SIGNAL⍨err,'File "',⍺,'" included too many times (',(⍕count),')'
                 }includedFiles

                 includeLines∘←dataIn
                 ∆IF_VERBOSE f0,' ',INFO,msg
             }0
             case cIMPORT:{
                 f2←f2 f1⊃⍨0=≢f2
                 T≠TOP:∆IF_VERBOSE f0,(SKIP NO⊃⍨F=TOP)
                 info←' ','[',']',⍨{
                     0::'UNDEFINED. ',(∆DQT f2),' NOT FOUND',NO⊣del f1
                     'IMPORTED'⊣put f1((⊃⎕RSI).⎕OR f2)
                 }⍬
                 ∆IF_VERBOSE f0,info
             }⍬
         }

      ⍝ --------------------------------------------------------------------------------
      ⍝ EXECUTIVE
      ⍝ --------------------------------------------------------------------------------
       ⍝ User-settable options
       ⍝ See below
       ⍝ __DEBUG__            ⍝ See above...
       ⍝ __MAX_EXPAND__←5     ⍝ Maximum times to expand macros (if 0, none are expanded!)
                              ⍝ Set via ⎕DEF __MAX_EXPAND__
       ⍝ __MAX_PROGRESSION__←500  ⍝ Maximum expansion of constant dot sequences:  5..100 etc.
                              ⍝ Otherwise, does function call (to save space or preserve line size)
       ⍝ __INCLUDE_LIMITS__←5 10  ⍝ Max times a file may be ::INCLUDEd
                              ⍝ First # is min before warning. Second is max before error.
       ⍝ __PREFIX__←''
      ⍝ Set prepopulated macros
         names←vals←⍬
         _←0 put'__DEBUG__'__DEBUG__
         _←0 put'__MAX_EXPAND__' 5
         _←0 put'__MAX_PROGRESSION__' 500
         _←0 put'__INCLUDE_LIMITS__'(5 10)
         _←0 put'__PREFIX__' ''


       ⍝ Read in data file...
         funNm fullNm dataIn←getDataIn ⍵
         tmpNm←'__',funNm,'__'

       ⍝ Initialization
         stack←,1 ⋄ lineNum←0
         includedFiles←⊂fullNm
         NLINES←≢dataIn ⋄ NWIDTH←⌈10⍟NLINES

         _←∆IF_DEBUG'Processing object ',(∆DQT funNm),' from file ',∆DQT fullNm
         _←∆IF_DEBUG'Object has ',NLINES,' lines'

         dataFinal←⍬

         includeLines←⍬
         comment←⍬

       ⍝ Go!

       ⍝ Kludge: We remove comments from all directives up front...
       ⍝ Not ideal, but...
         pInDirective←'^\h*::'
         inDirective←0
       ⍝ Process double quotes and continuation lines that may cross lines
         lines←pInDirective pDQe pSQe pCommentE pContE pEOLe ⎕R{
             cInDirective cDQ cSQ cCm cCn cEOL←⍳6
             f0 f1 f2←⍵ ∆FLD¨0 1 2 ⋄ case←⍵.PatternNum∘∊

            ⍝  spec←⍵.PatternNum⊃'Spec' 'Std' 'DQ' 'SQ' 'CM' 'CONT' 'EOL'
            ⍝  ⎕←(¯4↑spec),': f0="',f0,'" inDirective="',inDirective,'"'

             case cInDirective:f0⊣inDirective⊢←1
             case cDQ:processDQ f1 f2                ⍝ DQ, w/ possible newlines...
             case cSQ:{                              ⍝ SQ  - passthru, unless newlines...
                 ~NL∊⍵:⍵
                 ⎕←'WARNING: Newlines in single-quoted string are invalid: treated as blanks!'
                 ⎕←'String: ','⤶'@{NL=⍵}⍵
                 ' '@{NL=⍵}⍵
             }f0
             case cCm:f0/⍨~inDirective                  ⍝ COM - passthru, unless in std directive
             case cCn:' '⊣comment,←(' '/⍨0≠≢f1),f1   ⍝ Continuation
           ⍝ case 4: EOL triggers comment processing from above
             ~case cEOL:⎕SIGNAL/'∆PRE: Logic error' 911
             inDirective⊢←0                             ⍝ Reset  flag after each NL
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
