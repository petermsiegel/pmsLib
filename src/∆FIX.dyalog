﻿∆FIX←{⎕IO ⎕ML←0 1   
  ⍝ See ∆FIX.help for documentation.
    DEBUG←1
    reOPTS←('Mode' 'M')('DotAll' 1)('EOL' 'CR')('UCP' 1)
    0/⍨~DEBUG::  ⎕SIGNAL ⊂⎕DMX.(('EN' EN) ('EM' EM)('Message' Message)('OSError' OSError)) 

  ⍝ Following ⎕FIX syntax, a single vector is the spec for a file whose lines are to be read.
    LoadLines←'file://'∘{ 1<|≡⍵: ⍵ ⋄ ⍺≡⍵↑⍨n←≢⍺: ⊃⎕NGET(n↓⍵)1 ⋄ ⎕FIX '∘err' }

  ⍝ SaveRunTime:  SaveRunTime ⍬
  ⍝ Save Run-time Utilities in ⎕SE if not set...
  ⍝     ⎕SE.⍙PTR
    SaveRunTime←{4=⎕SE.⎕NC '⍙PTR': 0 
      2:: ⎕SIGNAL/'∆FIX: Unable to set utility operator ⎕SE.⍙PTR' 11
      ⎕SE.⍙PTR←{(ns←⎕NS '').∆FN←⍺⍺ ⋄ ns⊣ns.⎕DF '[⍙PTR]'} ⋄ 1 
    }
  ⍝ Scan4Special: Search through lines (vector of vectors) for: 
  ⍝     "double-quoted strings", triple-quoted ("""\n...\n"""), and  ::: here-strings.
  ⍝     Return executable APL single-quoted equivalents, encoded into various format via Encode below.
  ⍝     Returns one or more vectors of vectors... (Use ⊃res if one line expected/required).
    Scan4Special←{⍺←0
        SQ DQ←'''"' ⋄ CR←⎕UCS 13  
        AddPar← '('∘,∘⊢,∘')' 
      ⍝ Encode: ⍺: 
      ⍝ Output format: options '[clsvm]'.   
      ⍝    'r' carriage returns for linends (def); 'l' LF for linends; 's' spaces replace linends 
      ⍝    'v' vector of vectors;    'm' APL matrix;    
      ⍝ Escape option. Works with any one above. 
      ⍝    'e' backslash (\) escape followed by eol => single space. Otherwise, as above.
      ⍝    'c' string is a comment to treat in toto as a blank.
      ⍝ indent: >0, use as is for indent of lines; <0, use indent of left-most line for indent; 0, as is.
        Encode←{ ⍺←'' ⋄ indent←⍺⍺  
          ⍝ options--   o1 (options1) (r|l|s|v|m); o2 (options2): [ec]; od(efault): 'r'.
            o1 o2 od ←'rlsvm' 'ec' 'r'  ⋄ o←(o1{1∊⍵∊⍺⍺: ⍵ ⋄ ⍵⍵,⍵}od) ⎕C ⍺
            R L S V M E C←o∊⍨∊o1 o2
            0≠≢err←o~∊o1 o2: 11 ⎕SIGNAL⍨'∆FIX: Invalid option "',err,'"'
            C: ' '
            SlashScan←  { '\\(\r|$)'⎕R' '⍠reOPTS⊣⍵ }     ⍝ \ at end of line in TrpQ or pHere pat suppress EOL char
            S2Vv←      { 2=|≡⍵:⍵ ⋄ CR(≠⊆⊢)⊢⍵ }                        
            TrimL←     { 0=⍺: ⍵ ⋄ 0=≢⍵: ⍵ ⋄ lb←+/∧\' '=↑⍵  ⋄  ⍺<0: ⍵↓⍨¨lb⌊⌊/lb ⋄ ⍵↓⍨¨lb⌊⍺ }
            DblSQ←     { ⍵/⍨1+⍵=SQ }¨    
            FormByOpt← { 
              AddSQ←SQ∘,∘⊢,∘SQ 
              V∨M: ∊ ' ',⍨∘AddSQ¨ ⍵ ⋄  M←0 ⋄ S: AddSQ 1↓∊' ',¨⍵ 
              AddSQ ∊{⍺,nlc,⍵}/⍵ ⊣ nlc←SQ,',(⎕UCS ',(⍕R⊃10 13 ),'),',SQ  
            }
            AddPar (M/'↑'),FormByOpt (SlashScan⍣E)DblSQ indent∘TrimL S2Vv ⍵
        }
      ⍝ GenBracePat ⍵.   Generates a pattern to match unquoted balanced braces ⍵='()', '[]', or '{}' across newlines...
        GenBracePat←{⎕IO←0 ⋄ ⍺←⎕A[,⍉26⊥⍣¯1⊢ ⎕UCS ⍵] ⋄ Nm←⍺  ⍝ ⍺ a generated unique name based on ⍵
          Lb Rb←⍵,⍨¨⊂'\\'
          pM←'(?: (?J) (?<Nm> Lb  (?> [^LbRb''"⍝]+ | ⍝\N*\R | (?: "[^"]*")+  | (?:''[^'']*'')+ | (?&Nm)* )+ Rb))'~' '
          'Nm' 'Lb' 'Rb'⎕R Nm Lb Rb⊣pM
        }
        DTB←{⍵↓⍨-+/∧\' '=⌽⍵}¨                          ⍝ Delete trailing blanks from each line...
        UnDQ←{ s/⍨1+SQ=s←s/⍨~(2⍴DQ)⍷s←d↓⍵↓⍨-d←DQ=1↑⍵ } ⍝ Remove surrounding DQs and APL-escaped DQs. Double SQs  

        pTrpQ ←  '"""\h*\R(.*?)\R(\h*)"""([a-z]*)'    ⋄  pDblQ ←  '(?i)((?:"[^"]*")+)([a-z]*)'
        pSingle ←  '(?:''[^'']*'')+'                  ⋄  pComments← '⍝\N*$' 
        pDots   ← '(?:\.{2,3}|…)\h*\r'
          pPAR pBRC ←GenBracePat¨'()'  '{}'           ⋄  pWRD← '[\w∆⍙_#\.⎕]+'
          pPtr    ← ∊'(?ix) \$ \h* (' pPAR '|' pBRC '|' pWRD ')'
          pHMID←'( [\w∆⍙_.#⎕]+ :? ) \h* ( \N* ) \R ( .*? ) \R ( \h* )'
      ⍝ Here-strings and Multiline ("Here-string"-style) comments 
        pHere←∊'(?x)       ::: \h*   'pHMID' :? \1 (?! [\w∆⍙_.#⎕] ) :? (\N*) $'   ⍝ Match just before newline
        pHCom←∊'(?x) ^ \h* ::: \h* ⍝ 'pHMID' ⍝? \1 (?! [\w∆⍙_.#⎕] ) :? (\N*) \R?' ⍝ Consume newline (none on last line)
                      iTrpQ iDblQ  iSkp              iDots iHere iHCom iPtr←0 1 (2 3) 4 5 6 7
        mainPatterns← pTrpQ pDblQ  pSingle pComments pDots pHere pHCom pPtr 
        FullScan←{    
            mainPatterns ⎕R{  
                ⋄ F←⍵.{Lengths[⍵]↑Offsets[⍵]↓Block}
                ⋄ CASE←⍵.PatternNum∘∊                         
                CASE iTrpQ: (F 3) ((≢F 2) Encode) F 1               
                CASE iDblQ: (F 2) (0 Encode) UnDQ F 1                
                CASE iDots: ' '                                
                CASE iPtr:  AddPar  (FullScan F 1),' ⎕SE.⍙PTR 0'⊣SaveRunTime ⍬
                CASE iSkp:                  F 0                ⍝ '...' ⍝...       Skip      N      N/A
              ⍝ ::: ENDH...ENDH  Here-doc  Y   Via Opts   ← :c :l :v :m :s
              ⍝     F 3: body of here_doc, F 2: opns,  4: spaces before end_token, 5: code after end-token 
                CASE iHere: {  
                  opt← {⍵/⍨¯1⌽⍵=':'}F 2                       ⍝ Get option after each :
                  l1←  opt ((≢F 4 ) Encode)  F 3
                  l1 {0=≢⍵~' ':⍺ ⋄ ⍺, CR, FullScan ⍵} F 5       ⍝ If no code after endToken, do nothing more...
                }0   
                CASE iHCom: '' 
                ∘Unreachable∘
            }⍠reOPTS⊣⍵
        }
        FullScan DTB⊆⍵
    }  
    ⍺←⊢  ⋄ fix←0=≢'-nof'⎕S 3⊣(⍕⍺),''    ⍝ Secret -nofix option...
    ⍺(⊃⎕RSI).⎕FIX⍣fix⊣ Scan4Special LoadLines ⍵  
}
