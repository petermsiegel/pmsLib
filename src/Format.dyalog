:namespace Format
    DEBUG←0    ⍝ Set to 1 to suppress error trapping...
    _←{DEBUG:⎕←(⍕⎕THIS),': DEBUG ENABLED'  ⋄  ''}DEBUG

    :Section For Documentation, see Section "Documentation"
⍝  ∆FMT - a modest Python-like APL Array-Oriented Format Function
⍝
⍝  Generate and Return a 1 or 2D Formatted String
⍝      string←  [⍺0 [⍺1 ...]] ∆FMT specification [⍵0 [⍵1 ... [⍵99]]]]
⍝
⍝  Displays Format Help info!
⍝               ∆FMT ⍬
    :EndSection


    ⎕IO←0
    CR←⎕UCS 13  ⋄ DQ SQ←'"'''

⍝ ------ UTILITIES
     ⍝ ∆F:  Find a pcre field by name or field number
      ∆F←{N O B L←⍺.(Names Offsets Block Lengths)
          def←'' ⋄ isN←0≠⍬⍴0⍴⍵
          p←N⍳∘⊂⍣isN⊣⍵ ⋄ 0≠0(≢O)⍸p:def ⋄ ¯1=O[p]:def
          B[O[p]+⍳L[p]]
      }

    ⍝ GenBalanced: generates a pattern that matches balanced parens or equivalent,
    ⍝  P ← GenBalanced '()'
    ⍝  (Default) Recursive, matches balanced delimiters, skipping embedded single-quoted or double-quoted strings.
    ⍝         skipping embedded SQ strings, DQ strings.
    ⍝         ∘ Skips comments ⍝...
    ⍝         ∘ Skips "escaped" closing parens: ⍎)
    ⍝
      GenBalanced←{L R←⍵
          Nm←'bal',⍕bpCount_ ⋄ bpCount_+←1     ⍝ local N- unique pattern-internal name.
          ∊'(?:(?J)(?<'Nm'>\'L'(?>[^\'L'\'R'"''⍝]+|⍝.*\R|(?:"[^"]*")+|(?:''[^''\r\n]*'')+|(?&'Nm')*)+(?<!⍎)\'R'))'
      }
    bpCount_←1    ⍝ Use the ctr to generate a unique name balNNN for referencing inside the pattern.

  ⍝ ∆XR: Execute and Replace
  ⍝      Replace names of the form ⍎XXX in a string with its executed value in the calling context (in string form)...
  ⍝      ⍺: caller_NS[=⊃⎕RSI]  [err=1] [count=25]
  ⍝         caller_NS: Where to execute each expression found.  Default is caller env.
  ⍝         error:     If 1 (default), signals an error if it can't make the requisite replacements.
  ⍝                    If 0, - if ⍎'my_str' failed, the vector 'my_str' is returned.
  ⍝                          - results of more than one line will be raveled.
  ⍝                          - if it exceeds count, returns current replacement (If a b c d e f←'⍎',¨'bcdefa', try with count of 5).
  ⍝         count:     How many times to scan the ENTIRE string for replacements. Default is 25.
    XRCallE←'∆XR: 1st element of ⍺ (caller) must be a namespace.'  ⋄  XRLoopE←'∆XR: looping on runaway replacement strings.'
    XRExecE←{'∆XR: An error occurred executing ⍎"',⍵,'".'}         ⋄  XRFormE←{'∆XR: Result not a single line in ⍎"',⍵,'".'}
      ∆XR←{⍺←⊃⎕RSI
          caller err cnt←3↑⍺,1 25↑⍨¯3+≢⍺           ⍝ Declaring caller, err, cnt
          9≠⎕NC'caller':⎕SIGNAL∘11 XRCallE
          CondErr←{cnt∘←0 ⋄ ~err:⍺ ⋄ ⎕SIGNAL∘11 ⍵}
          cnt{cnt←⍺
              cnt≤0:⍵ CondErr XRLoopE
              S←'⍎([\w∆⍙#⎕\.]+)'⎕R{f1←⍵ ∆F 1
                  0::f1 CondErr XRExecE f1
                  1=≢r←⎕FMT caller.⍎f1:,r
                  (∊r,' ')CondErr XRFormE f1
              }⍠('UCP' 1)⊣⍵
              ⍵≡S:S ⋄ '⍎'(~∊)S:S ⋄ (cnt-1)∇ S
          }⍵
      }
  ⍝ ∆XRL: Execute and Replace Locally
    ∆XRL←⎕THIS∘∆XR

  ⍝ ========= MAIN ∆FMT Formatting Function
  ⍝ ∆FMT - Major formatting patterns:
  ⍝    ...P the pattern, ...C the pattern number
  ⍝ Braces: Embedded balanced braces are allowed, as are quoted strings (extended to double-quoted strings).
    nextFC←0⊣nextFP←'\{\h*\}'                     ⍝ Next Omega.
    endFC←1⊣endFP←'⋄|\{\h*[⍬:]\h*\}'              ⍝ End of Field. This optimizes. The <codeFP> path has the same result, just slower.
    codeFC←2⊣codeFP←GenBalanced '{}'              ⍝ Code field.
    textFC←3⊣textFP←'(?x) (?: \\. | [^{\\⋄]+ )+'  ⍝ Text Field

  ⍝ Pseudo-format strings specs:
  ⍝     Strings of the form {specs: expression}
  ⍝ In place of APL  ('specs' ⎕FMT expression), we have shorthand
  ⍝       {specs:   expression}.
  ⍝ E.g.  {I5,F4.2: ivec fvec}
  ⍝ fmtP matches the specs and following colon.
  ⍝ Fmt Patterns: < >, ⊂ ⊃, ⎕ ⎕ or ¨ ¨ by APL ⎕FMT rules (no embedded matching delims).
  ⍝
  ⍝ Special pseudo-format spec extensions
  ⍝    Lnn, Cnn, Rnn, as in
  ⍝    {C15,I5,F4.2: ivec fvec}, which centers the result of ('I5,F4.2' ⎕FMT ivec fvec)
  ⍝ Must be first (or only) specification given, with optional comma following.
  ⍝    Lnn: obj on left, padded on right to width nn. Ignored if the object is ≥nn in width.
  ⍝    Rnn: obj on right, padded on left to with nn.   Ditto.
  ⍝    Cnn: obj centered.                              Ditto.
    _fmtQts←'⍞' '<>'  '⊂⊃' '⎕' '¨'
    _fmtQuoters←¯3↓∊{L R←⍵ ⋄ L,' [^',R,']* ',R,' | '}¨_fmtQts
    _uptoColonP←'[^ : ⍎DQ ⍎SQ ⍎_FQ ]+'~' '  ⊣ _FQ←∊_fmtQts      ⍝ quotes are valid only within _fmtQuoters above.
    fmtP← ∆XRL '(?xi) (?| ((?: ⍎_fmtQuoters | ⍎_uptoColonP )*) : (.*) $ | () (.*) ) $'

    ⍝ Special:   \⍎ \{  \n==>  ⍎ { \r (=CR).  (CR works as newline with APL ⎕FMT).
      ProcEscapes←{
          '\\(\{)' '\\\\n' '\\n' '\\⋄'⎕R'\1' '\\n' '\r' '⋄'⊣⍵
      }
    ⍝ Join ⍺ and ⍵:  Treat ⍺, ⍵ each as a matrix and attach ⍺ to left of ⍵, adding rows to ⍺ or ⍵ as needed..
      Join←{
          new←⎕FMT ⍵ ⋄ 0=≢⍺:new
          LH LW←⍴old←⎕FMT ⍺
          RH RW←⍴new
          CH←LH⌈RH ⋄ (CH LW↑old),(CH RW↑new)
      }
    ⍝ omega type ScanCode format_string
    ⍝ Handle strings of the form   ⍵NN in format specs, strings within code, and code outside strings:
    ⍝   type=0:  In format specs:  The value of (⍕NN⊃⍵) will be immediately interpolated into the spec (⎕IO=0).
    ⍝   type=1:  In code outside strings:  The code (⍵⊃⍨NN+⎕IO) will replace ⍵NN (⎕IO-independent).
    ⍝ If index N is out of range of alpha or omega, signals an index error.
      ScanCode←{
          env isCode←⍺ ⍺⍺     ⍝ env fields: env.(caller alpha omega index)
          '("[^"]*")+|(''[^'']*'')+' '\\([⍵⍺])' '([⍵⍺])(\d{1,2})' '(?|(⍵)⍵|(⍺)⍺)'⎕R{  ⍝ ⍵00 to ⍵99
              case←⍵.PatternNum∘=
              case 0:CanonQuotes ⍵ ∆F 0     ⍝ Convert double quote sequences to single quote sequences...
              case 1:⍵ ∆F 1                 ⍝ \⍵ istreated as char ⍵
            ⍝ cases 2 3 together: ⍵3, ⍺3, ⍵⍵, ⍺⍺
              k←'⍵'=f1←⍵ ∆F 1
              f2←{0≠≢⍵:⍵ ⋄ ⍕1+env.index[k]}⍵ ∆F 2   ⍝ If ⍵NN, return NN; if ⍵⍵, return 1+env.index<⍺ or ⍵>
              ix←env.index[k]←⍎f2 ⋄ alom←k⊃env.(alpha omega)
              ix≥≢alom:3 ⎕SIGNAL⍨(⍵ ∆F 0),' out of range'
              isCode:'(',f1,'⊃⍨',f2,'+⎕IO)'
              ⍕ix⊃alom
          }⍵
      }

    CanonQuotes←{DQ≠1↑⍵: ⍵ ⋄ SQ,SQ,⍨{⍵/⍨1+SQ=⍵}{⍵/⍨~(DQ,DQ)⍷⍵}1↓¯1↓⍵  }

      ExecCode←{
          env cod←⍺ ⍵     ⍝ env fields: env.(caller alpha omega index)
          6⍴⍨~DEBUG::⎕SIGNAL/⎕DMX.(EM EN)⊣⎕←'Error executing code: ',cod
        ⍝ Handle omegas
        ⍝ Find formatting prefix, if any
          (pfx cod)←fmtP ⎕R'\1\n\2'⊣⊆cod
          pfx←env(0 ScanCode)pfx              ⍝ 0: ~isCode
          cod←env(1 ScanCode)cod              ⍝ 1:  isCode
     
        ⍝ Spacing / Justification
        ⍝ Get special specification, if any:
        ⍝     (noTrunc=0):  Lnn, Cnn, Rnn   (noTrunc=1): lnn, cnn, rnn
        ⍝ Set locals: lcr, pfc, pad, noTrunc
          lcr pad noTrunc←' ' 0 1
          pfx←'^(?i)([LCR])(\d+),?'⎕R{f1 f2←⍵ ∆F¨1 2
              ''⊣pad∘←⍎f2⊣noTrunc∘←f1≡lcr∘←1 ⎕C f1
          }pfx
     
        ⍝ Apply standard Dyalog ⎕FMT dyadically, if a prefix is presented, else monadically...
        ⍝ ... to the value of executing <cod> in the caller environment!
          val←pfx{
              0=≢⍺:⎕FMT ⍵ ⋄ ⍺ ⎕FMT ⍵
          }{
              0=≢⍵:'' ⋄ env⍎'alpha caller.{',(ProcEscapes ⍵),'}omega'
          }cod
     
        ⍝ Apply special justification: [Ll]nn [Rr]nn or [Cc] nn. [LRC]: noTrunc=0; [lrc]: noTrunc=1.
        ⍝ No padding/truncation requested OR (noTrunc=1 and truncation
          wid←⊃⌽⍴val
          noTrunc∧pad≤wid:val
        ⍝ Process padding specs for Left, Right, and Center, enlarging or truncating as required.
          lcr='L':pad↑[1]val ⋄ lcr='R':(-pad)↑[1]val ⋄ pad↑[1](-⌊0.5×wid+pad)↑[1]val
      }

    ⍝ Main user function ∆FMT
    ∇ text←{leftArgs}∆FMT rightArgs;env;_
      :Trap 0⍴⍨~DEBUG
          :If rightArgs≡⍬ ⋄ FORMAT_HELP ⋄ :Return ⋄ :EndIf
     
          text←''
          env←⎕NS''   ⍝ fields: env.(caller alpha omega index)
           ⋄ env.caller←0⊃⎕RSI
           ⋄ env.alpha←,{⍵:⍬ ⋄ ⍺←leftArgs ⋄ 1<⍴⍴⍺:,⊂⍺ ⋄ ' '≡⍬⍴0⍴⍺:⊆⍺ ⋄ ⍺}900⌶⍬
           ⋄ env.omega←1↓rightArgs←⊆rightArgs
           ⋄ env.index←2⍴¯1    ⍝ "Next" element of alpha ([0]: ⍺, ⍺⍺) and omega ([1]: ⍵, ⍵⍵) to read in ExecCode is index+1.
     
          _←nextFP endFP codeFP textFP ⎕S{
              case←⍵.PatternNum∘= ⋄ f0←⍵ ∆F 0
              case textFC:0⍴text∘←text Join ProcEscapes f0          ⍝ Any text except {...} or ⋄
              case codeFC:0⍴text∘←text Join env ExecCode 1↓¯1↓f0    ⍝ {[fmt:] code}
              case nextFC:0⍴text∘←text Join env ExecCode'⍵⍵'        ⍝ {}    - Shortcut for '{⍵⍵}'
              case endFC:⍬                                          ⍝ ⋄     - End of Field (ends preceding field). Syn: {⍬} {:}
              ⎕SIGNAL/'∆FMT: Unreachable stmt.' 11
          }⊣⊃rightArgs    
          text←,⍣(1=≢text)⊣text     ⍝ 1 row matrix quietly converted to a vector...
      :Else
          ⎕SIGNAL/⎕DMX.(EM EN)
      :EndTrap
    ∇

    ∇ FORMAT_HELP;h
      h←'_HELP'
      :If 0=⎕NC h ⋄ _HELP←(⊂'  '),¨3↓¨{⍵/⍨(⊂'⍝H')≡¨2↑¨⍵}⎕SRC ⎕THIS ⋄ :EndIf
      ⎕ED⍠('ReadOnly' 1)&h
    ∇

  ⍝ Add ⎕THIS to ⎕PATH cleanly and exactly once (if not already present).
    ##.⎕PATH← 1↓∊' ',¨∪(' ' (≠⊆⊢) ##.⎕PATH),⊂⍕⎕THIS

  ⍝ Delete underscore-prefixed vars (those not used at runtime)
    ⎕EX '_' ⎕NL 2 3 4


    :Section Documentation
⍝H ∆FMT - a modest Python-like APL Array-Oriented Format Function
⍝H
⍝H Syntax:
⍝H    string← [⍺0 [⍺1 ... [⍺99]]] ∆FMT specification [⍵0 [⍵1 ... [⍵99]]]]
⍝H
⍝H    Preview!
⍝H          what←'rain' ⋄ where←'Spain' ⋄ does←'falls' ⋄ locn←'plain'
⍝H          ∆FMT 'The {what} in {where} {does} mainly on the {locn}.'
⍝H    The rain in Spain falls mainly on the plain.
⍝H        'you' 'know'  ∆FMT 'The {} in {} {} mainly on the {}, {⍺⍺} {⍺⍺}.' 'rain' 'Spain' 'falls' 'plain'
⍝H    The rain in Spain falls mainly on the plain, you know.
⍝H
⍝H    Specification: a string containing text, variable names, code, and ⎕FMT specifications, in a single vector string.
⍝H    ∘ In addition to ⍺ or ⍵ (each entire array) or selections therefrom,
⍝H      special variable names within code include
⍝H         ⍺0 (short for (0⊃⍺)), ⍺⍺ (for the next element of ⍺), and
⍝H         ⍵0 (short for (0⊃⍵)), ⍵⍵ (for the next element of ⍵), ... ⍺99 and ⍵99.
⍝H      These may appear one or more times within a Code field and are processed left to right.
⍝H
⍝H  Types of Fields:
⍝H  type:    TEXT      | SIMPLE | PREFIXED |  BLANK  |  END OF  |  NEXT ARG
⍝H                     | CODEa  |  CODEb   |  CODEc  |  FIELD   |  CODEe
⍝H  format:  any\ntext | {code} | {fmt:code}| {Lnn:} |   ⋄      |  {}  {⍵⍵}  {⍺⍺}
⍝H
⍝H  Special chars in format specifications:
⍝H    Escaped chars:  \{  \\ \⋄   - Represented in output as { (left brace), \ (backslash) and ⋄ (lozenge).
⍝H    Newlines        \n          - In TEXT fields or inside quotes within CODE fields.
⍝H                                  \n is actually a CR char (Unicode 13), forcing a new APL line in ⎕FMT.
⍝H
⍝H Fields:
⍝H  1.  TEXT field: Arbitrary text, requiring escaped chars \{ \⍎ and \\ for {⍎\ and \n for newline.
⍝H
⍝H  2.  CODE field
⍝H   a. SIMPLE CODE: {code}   returns the value of the code executed as a 2-d object.
⍝H      ⍵0..⍵99, ⍵⍵, ⍵, ⍺0..⍺99, ⍺⍺, ⍺ may be used anywhere in a code field (see above).
⍝H
⍝H   b. PREFIXED CODE: {prefix: code}
⍝H      executes <code> and then formats it as (prefix ⎕FMT value).
⍝H      prefix: any valid ⎕FMT specification,
⍝H         with these additions as the first or only specification.
⍝H         A.  The first "field" may be [truncate ok] Lnn, Rnn, or Cnn; or
⍝H                                      [no truncate] lnn, rnn, or cnn.
⍝H             L/l- object on left side, padded on right.
⍝H               L20: Pad a left-anchored object on right to 20 chars. Do not truncate.
⍝H               l20: Ditto. Truncate as required.
⍝H             C/c- centered.
⍝H               C15: Pad  a field with 8 chars on left and 7 on right. Do not truncate.
⍝H               c15: Ditto. Truncate as required.
⍝H             R/r- right side.
⍝H               R5:  Pad a right-anchored object on left to 5 chars. Do not truncate.
⍝H               r5:  Ditto. Truncate as required.
⍝H             Examples:                               12345678901234567890
⍝H             #1  ∆FMT '<{C20,I3: 1 5⍴⍳5}>'   ==>    <    0  1  2  3  4   >
⍝H             #2  ∆FMT '<{C2,I5:  1 5 ⍴⍳5}>'  ==>    <    0    1    2    3    4>
⍝H             #3  ∆FMT '<{C5:"1234567890"}>'  ==>    <1234567890>
⍝H                 ∆FMT '<{R5:"1234567890"}>'  ==>    <1234567890>
⍝H                 ∆FMT '<{c5:"1234567890"}>'  ==>    <45678>
⍝H         B.  A field spec may include any of ⍵0 through ⍵99. If there is a right argument ⍵[N] matching ⍵N, it will
⍝H             be converted to string form and replace the latter.
⍝H         Example:
⍝H             ∆FMT 'Random: {C⍵0,⊂< ⊃,F⍵1,⎕ >⎕: ?3⍴0}' 8 4.2  (or '8' '4.2')
⍝H         Random: < 0.30 >
⍝H                 < 1.00 >
⍝H                 < 0.64 >
⍝H         If a standard format specification is used, APL ⎕FMT rules are followed, treating
⍝H         vectors as 1-column matrices:
⍝H         Example:
⍝H             ∆FMT 'a: {3↑⎕TS} b: {I4: 3↑⎕TS} c: {ZI2,⊂/⊃,ZI2,⊂/⊃,I4: ⍉⍪1⌽3↑⎕TS}'
⍝H         a: 2020 9 6 b: 2020 c: 09/06/2020
⍝H                           9
⍝H                           6
⍝H
⍝H      Code fields (only) may also contain double-quoted strings "like this" or single-quoted strings
⍝H      entered ''like this'' which appears 'like this'. Valid: "A cat named ""Felix"" is ok!"
⍝H      Quotes entered into TEXT fields are treated as ordinary text and not processed in any way.
⍝H
⍝H      Example:
⍝H         ∆FMT '{⍪6⍴"|"} {↑"one\ntwo" "three\nfour" "five\nsix"}'
⍝H      | one
⍝H      | two
⍝H      | three
⍝H      | four
⍝H      | five
⍝H      | six
⍝H
⍝H      Code fields may be arbitrarily complicated. Only the first "prefix:" specification
⍝H      is special:
⍝H      Example:
⍝H         ∆FMT 'Today is {now←1 ⎕DT ⊂⎕TS ⋄ spec←"__en__Dddd, DDoo Mmmm YYYY hh:mm:ss"⋄ ∊spec(1200⌶)now}.'
⍝H      Today is Sunday, 06th September 2020 17:25:21.
⍝H
⍝H   c. BLANK field: {Lnn:}
⍝H      Create a field nn blanks wide, where nn is a non-negative integer.
⍝H      Only these cases are allowed: {Lnn:} | {Cnn:} | {Rnn:}. All are equivalent.
⍝H      E.g. to insert 10 blanks between fields:  {L10:}.
⍝H
⍝H   d: END OF FIELD (EOF): ⋄
⍝H      An unescaped lozenge ⋄ terminates the preceding field (if any).
⍝H      Equivalents: Since {⍬} or {:} evaluates to an empty (0-width) field, they are synonyms for EOF.
⍝H      Example:
⍝H          ∆FMT 'The cat ⋄is\nisn''t{⍬}here {:}and\nAND {"It isn''t here either"}'
⍝H      The cat is   here and It isn't here either
⍝H              isn't     AND
⍝H
⍝H   e. NEXT OMEGA FIELD:  {} is equiv to {⍵⍵}, i.e. the next element in ⍵.
⍝H    - if no explicit {⍵NN} is specified, {} is {⍵0} {⍵1} ....
⍝H    - if {⍵10} is specified, {} to its right selects {⍵11};
⍝H      i.e. after {⍵N},  {} or {⍵⍵} refers to ⍵M, M=N+1.
⍝H    - There is no short-cut for the next alpha field (⍺⍺); it is useful nonetheless.
⍝H    Example:
⍝H      ⍝ 1. A long line.
⍝H         ∆FMT '{} {} lives at {} in {}, {} in {}' 'John' 'Smith' '424 Main St.' 'Milwaukee' 'WI' 'the USA'
⍝H      John Smith lives at 424 Main St. in Milwaukee, WI in the USA
⍝H      ⍝ 2. A bit of magic to pass format specs and args as peer strings (vectors).
⍝H         info←'John' 'Smith' '424 Main St.' 'Milwaukee' 'WI' 'the USA'
⍝H         ∆FMT '{} {} lives at {} in {}, {} in {}' {⍵,⍨⊂⍺} info
⍝H      John Smith lives at 424 Main St. in Milwaukee, WI in the USA
⍝H      ⍝ 3. Using ⍺ on the left to pass a list of strings is simple.
⍝H         info  ∆FMT '{⍺⍺} {⍺⍺} lives at {⍺⍺} in {⍺⍺}, {⍺⍺} in {⍺⍺}'
⍝H      John Smith lives at 424 Main St. in Milwaukee, WI in the USA
⍝H
⍝H Returns: a matrix-format string if 2 or more lines are generated.
⍝H If 1 line, returns it as a vector.
⍝H
⍝H ∆FMT ⍬  -- Displays Format Help info!
    :EndSection Documentation

:EndNamespace
