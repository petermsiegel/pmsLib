 require2←{⍺←⊃⎕RSI
     ⍝ require [flags] [object1 [object2] ... ]]
     ⍝
     ⍝ object:   name OR  dir:name OR wsid::name  OR  dir:(name1 name2 ...)  OR wsid::(name1 name2 ...)
     ⍝ 

    DEBUG←1   ⋄   ⎕IO←0 ⋄ Err←⎕SIGNAL∘11
    LIB_SFX←'⍙⍙.require'
    CALLER←{0:: Err 'Left arg (CALLER) must be a valid namespace name or reference: ',⍕⍵
       9=⎕NC '⍵': ⍵ ⋄  2=⎕NC '⍵': (⊃⎕RSI)⍎⍵
    }⍺

    NL←⎕UCS 10

⍝ ------ UTILITIES
⍝ ∆F:  Find a pcre field by name or field number
     ∆F←{⎕IO←0
         N O B L←⍺.(Names Offsets Block Lengths)
         def←'' ⋄ isN←0≠⍬⍴0⍴⍵
         p←N⍳∘⊂⍣isN⊣⍵ ⋄ 0≠0(≢O)⍸p:def ⋄ ¯1=O[p]:def
         B[O[p]+⍳L[p]]
     }
     GetEnv←{⊢2 ⎕NQ'.' 'GetEnvironment'⍵}
     DLB←{⍵↓⍨+/∧\⍵=' '}                                   ⍝ Delete leading blanks

  GetObj←{⎕IO←0
    ⍝⍝ object of form
    ⍝⍝    namesp:name, namesp::name, namesp:(name1 name2 ...) namesp::(name1 name2 ...)
    ⍝⍝    namesp: any chars but space--
    ⍝⍝    name:   any valid APL name chars
    ⍝⍝ Returns
    ⍝⍝    [0] name (or null if no : or ::)
    ⍝⍝    [1] ':' or '::' or ''
    ⍝⍝    [2] name1 [name2 ...]
        obj←⍵
        namesp punct obj←{
            ~⍵:'' '' '' ''
            na←obj↑⍨p
            pu←':'⍴⍨∆←1+':'=1↑obj↓⍨p+1
            ob←DLB obj↓⍨p+∆
            na pu ob
        }(≢obj)>p←obj⍳':'

        names←{
            ~⍵:⊂obj
            ~')'∊obj:('GetObj: namelist terminator not found: ',obj)⎕SIGNAL 11
            p←')'⍳⍨obj←1↓obj
            ' '(≠⊆⊢)p↑obj
        }'('=1↑obj
        ¯1∊⎕NC↑names:'GetObj: at least one object name is invalid'⎕SIGNAL 11
        namesp punct names
 }

  ⍝ ========= MAIN

     ScanOptions←{  ⍝ Process options -fff, returning unaffected tokens...
         0=≢⍵:⍺ ⋄ opt←0⊃⍵ ⋄ tokens←1↓⍵ ⋄ done←0
         '-'≠1↑opt:(⍺,⊂opt)∇ tokens
         toksLeft←tokens{toks opt←⍺ ⍵
             case←(1↑1↓opt)∘≡∘, ⋄ with←⊣
             case'f':toks with oForce∘←1
             case'R':toks with oCaller oLib∘←#''                  ⍝ -Root           also sets -lib ""
             case'r':toks with oCaller oLib∘←# LIB_SFX            ⍝ -root           also sets -lib '⍙⍙.require'
             case'S':toks with oCaller oLib∘←⎕SE''                ⍝ -Session        also sets -lib ""
             case's':toks with oCaller oLib∘←⎕SE LIB_SFX          ⍝ -session        also sets -lib '⍙⍙.require'
             case'd':toks with oDebug∘←1                          ⍝ -debug
             case'-':toks with done∘←1                            ⍝ --                  (done with options)
             skip←1↓toks
             case'c':skip with oCaller∘←⊃toks                     ⍝ -Caller namespace
             case'l':skip with oLib∘←⊃toks                        ⍝ -lib    prefix
             case'p':skip with oPath,⍨←⊃toks                       ⍝ -path   addition     (augment search path: colon sep.)
             case'P':skip with oPath∘←⊃toks                       ⍝ -Path   replacement  (replace search path: colon sep.)
         
             Err'Invalid option: ',opt
         }opt
         done:⍺,toksLeft
         ⍺ ∇ toksLeft
     }∘,

     ScanTokens←{
         UnDQ←{s/⍨~DQ2⍷s←1↓¯1↓⍵} ⋄ DQ2←2⍴'"'               ⍝ Convert DQ strings to SQ strings
         ⍝     DQ           SQ              WorD    SPaces
         pList←'("[^"]*")+' '(''[^'']*'')+' '[^ ]+' ' +'
         eDQ eSQ eWD eSP←⍳≢pList
         ResolveTokens←{
             f0←⍵ ∆F 0 ⋄ case←⍵.PatternNum∘∊
             case eWD:f0 ⋄ case eDQ:UnDQ f0 ⋄ case eSQ:1↓¯1↓f0 ⋄ case eSP:NL
             Err'Logic Error'
         }
         pList ⎕R ResolveTokens⊣⊆DLB ⍵
     }
     ReportAndReturn←{
        ~DEBUG: ⍵
          ⎕←'  oDebug'oDebug'oForce'oForce'  oCaller'oCaller'  oLib'oLib
          ⎕←('  oPath [',(⍕≢oPath),' entries]') oPath
          ⍵
     }

     oDebug oForce oCaller oLib←DEBUG 0 CALLER LIB_SFX
     oPath← ∊':',¨ ':',¨GetEnv¨ 'WSPATH' 'FSPATH'         ⍝ directories separated by ':'
     DEBUG←oDebug
     tokens←⍬ ScanOptions ScanTokens ⍵
     oPath←∪':' (≠⊆⊢) oPath
     ReportAndReturn tokens
 }
