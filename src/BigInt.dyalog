﻿:NAMESPACE BigInt
⍝+++++  FOR HELP information, see :SECTION HELP_INTRO, followed by ⍝H comments throughout.

:Section HELP_INTRO
⍝H The BigInt Library
⍝H ¯¯¯ ¯¯¯¯¯¯ ¯¯¯¯¯¯¯
⍝H ∘ BI: Big Integer Operator (use this: returns a BigInt string)
⍝H     operator:  BI           BigIntE ←  [⍺] +BI ⍵          "Arithmetic+ Methods, returning ⍺ + ⍵ as a BigIntE (external-format BigInt)"
⍝H                                                            Args can be BigInt strings, APL numbers, or INTERNAL BigInts.
⍝H ∘ BII: Big Integer Internal Operator (same opts as BI, but returns a BigInt in INTERNAL BigInt format)
⍝H     operator:  BII          BIgIntI ←  [⍺] +BII ⍵         "Arithmetic+ Methods, returning ⍺ + ⍵ as a BigIntI (Internal BigInt)"
⍝H ∘ BIM: Big Integer Modulo Methods, optimized only for multiply and power.
⍝H     operator:  BIM          BigIntE ←  [⍺] +BIM mod⊣ ⍵  "Modulo Methods, returning  mod | ⍺ + ⍵⍵ as a BigIntE.
⍝H ∘ BI_DC: BigInt Desk Calculator
⍝H     function:  BI_DC                        BI_DC         "BigInt Desk Calculator"
⍝H ∘ BI_HELP                   BI_HELP       "Show BigInt HELP Information"
⍝H ∘ Other Routines
⍝H     function:  BIC                   [opts] BIC string    "BigInt ¨Compile¨, converting string with APL code subset as a BI call"
⍝H     function   BI_LIB       lib    ←        BI_LIB        "Return BigInt Namespace (useful for accessing internal
⍝H                                                            routines not visible via ⎕PATH)"
⍝H   EXAMPLE #1
⍝H       a←!BI 200  ⋄  ' a: ',(50↑a),'...',(¯10↑a) ⋄ '≢a:', ≢a
⍝H    a: 78865786736479050355236321393218506229513597768717...0000000000
⍝H   ≢a: 375
⍝H       a÷BI !BI 190
⍝H   81470204436547390464000 
⍝H       BIC '(!200)÷!190'                       ⎕FR←1287 ⋄ ⎕PP←30 ⋄ (!200)÷!190         ⎕FR←645 ⋄  (!200)÷!190
⍝H   81470204436547390464000                  81470204436547390464000                 DOMAIN ERROR
⍝H       BIC '(!5000)÷!4990'                     ⎕FR←1287 ⋄ ⎕PP←34 ⋄ (!5000)÷!4990
⍝H   9678073481456549436528438162585600000    DOMAIN ERROR
⍝H
⍝H   Built on dfns::nats, restructured for signed integers. Faster than dfns::big.
⍝H   Typically you all all routines via the interfaces here, rather than calling the BI_LIB.add, BI_LIB_sub (etc.) routines directly.
⍝H       BI - does all the operations: + - * etc.
⍝H            Input:  any "scalar" BigIntE (in external format) or BigIntI (internal format).  See details below.
⍝H            Output: a BigIntE normalized. ⍕BI shares normalized with underscores every five digits for readability.
⍝H       BII- does all the operations, just like BI.
⍝H            Input:  Same as BI
⍝H            Output: Always an internal format big integer (normalized, i.e. checks for leading 0s etc)
⍝H       BIM- does operation  ⍺<op>⍵ modulo m, returning an external-format BigIntE.
⍝H            Specifically:
⍝H                     ⍺ ×BIM m ⊣ ⍵   is the same as    m |BI ⍺ ×BII ⍵   (except faster)
⍝H            BIM is optimized for ops: × (mul) and * (pow) so far.  For other operations, calls modulo after performing <op>.
⍝H       BIC- Takes a standard APL-format mathematical expression without BI or BIC and inserts the BI calls.
⍝H            E.g.      BIC  '!500'
⍝H                      ≢a
⍝H                 100001     ⍝ Returns a 10,001-digit number
⍝H       BI_DC- Execute BI instructions in a desk calculator mode.
⍝H            To execute, call BI_DC (no args, no return value).
⍝H   NOTES
⍝H   1) Most binary routines were removed. APL intrinsically handles large bit arrays better...
⍝H
⍝H Table of Contents
⍝H   Preamble
⍝H      Preamble Utilities
⍝H      Preamble Variables
⍝H   BI/BII
⍝H      BigInt Namespace and Utility Initializations
⍝H      Executive: BI, BII, BIM, bi
⍝H      BigInt internal structure
⍝H      Monadic Operands/Functions for BII, BI, BIM
⍝H      Dyadic Operands/Functions for BII, BI, BIM
⍝H      Directly-callable Functions ⍵⍵ via BI_LIB.⍵⍵.
⍝H      BI Special Functions/Operations (More than 2 Args)
⍝H      Unsigned Utility Math Routines
⍝H      Service Routines
⍝H  Utilities
⍝H      BI_LIB   (returns the BigInt namespace).
⍝H      BI_DC    (desk calculator)
⍝H      BIC      (BI math "compiler")
⍝H  Postamble
⍝H      Exported and non-exported Utilities
⍝H   ----------------------------------
⍝H   INTERNAL-FORMAT BIs (BigIntI)
⍝H   ----------------------------------
⍝H    BIint  -internal-format signed Big Integer numeric vector:
⍝H          sign (data) ==>  sign (¯1 0 1)   data (a vector of integers)
⍝H          ∘ sign: If data is zero, sign is 0 by definition.
⍝H          ∘ data: Always 1 or more integers (if 0, it must be data is ,0).
⍝H                  Each element is a positive number <RX10 (10E6)
⍝H          ∘ depth: ¯2    shape: 2
⍝H    Given the canonical requirement, a BIint of 0 is (0 (,0)), 1 is (1 (,1)) and ¯1 is (¯1 (,1)).
⍝H
⍝H    BIu  -unsigned internal-format BIint (vector of integers) used in unsigned routines internally.
⍝H          ∘ Consists solely of the data vector (2nd element of BIint).
⍝H
⍝H   ---------------------------------
⍝H   EXTERNAL-FORMAT BIs (BigIntE)
⍝H   ---------------------------------
⍝H     ON INPUT
⍝H          an external-format Big Integer on input, i.e. a character string as entered by the user.
⍝H          a BIext has these characteristics:
⍝H          ∘ char. vector or scalar   ∘ leading ¯ or - prefix for minus, and no prefix for plus.
⍝H          ∘ otherwise, only the digits 0-9 plus optional use of _ to space digits.
⍝H          ∘ If no digits (''), it represents 0.
⍝H          ∘ spaces are disallowed, even leading or trailing.
⍝H     ON OUTPUT
⍝H          a canonical (normalized) external-format BIext string returned has a guaranteed format:
⍝H          ∘ char. vector     ∘ leading ¯ ONLY for minus.
⍝H          ∘ otherwise, only the digits 0-9. No spaces, or hyphen - for minus.
⍝H          ∘ underscores are optional. BI/BII produce underscores in Prettify mode only (see ⍕BI).
⍝H          ∘ leading 0's are removed.
⍝H          ∘ 0 is represented by (,'0'), unsigned with no extra '0' digits.
⍝H
⍝H   OTHER TYPES
⍝H    Int   -an APL-format single small integer ⍵, often specified to be in range ⍵<RX10 (the internal radix, 1E6).
⍝H --------------------------------------------------------------------------------------------------
⍝H  OPERANDS AND ARGUMENTS FOR BI, BII, and BIM
⍝H  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
⍝H        BI:  Usually returns a BigInt in External format. In specific cases, returns integer scalars (see ∧, ∨, etc.) or arrays (DIVREM, ⎕AT)
⍝H        BII: Usually returns a BigInt in Internal format. In specific cases, like BI above.
⍝H        BIM: Requires ⍺ and ⍵ as for (fn BII) and m (modulo) as right operand ⍵⍵. 
⍝              Valid only for operands above returning BigInts.
⍝H           23456 (×BIM 16) '9999999999'  
⍝H  MONADIC OPERANDS: +BI ⍵
⍝H  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
⍝H        Right argument: ⍵ in BigInt internal or external formats (BigIntI or BigIntE).
⍝H        Operators: BI or BII only. BIM is only used dyadically.
⍝H           -BI  ⍵             negate
⍝H           +BI  ⍵             canonical (returns BI  ⍵ in standard form, however entered)
⍝H           |BI  ⍵             absolute value
⍝H           ×BI  ⍵             signum
⍝H           ÷BI  ⍵             inverse (mostly useless)
⍝H           <BI  ⍵             decrement (alternate ≤). Optimized (wherever overflow/underflow do NOT occur).
⍝H           >BI  ⍵             increment (alternate ≥). Optimized (ditto).
⍝H           !BI  ⍵             factorial
⍝H           ?BI  ⍵             roll.  ⍵>0. Returns number between 0 and ⍵-1
⍝H           ⍎BI  ⍵             APL integer, if exponent in range. Else signals error.
⍝H           ⍕BI  ⍵             pretty format: returns canonical int with - for neg and _ separator every 5 digits
⍝H           ('√'BI)  ⍵         sqrt (alternate 'SQRT'). Use ⍺*0.5 (optimized special case).
⍝H           ⍳BI  ⍵             iota. Returns ⍳⍵ on APL-range integers only. Provided only for convenience.
⍝H           →BI  ⍵             internal: returns BI  ⍵ in internal form
⍝H           ⊥BI  ⍵             bit-encode: converts bits to BI: 1 sign bit, 20 bits per unsigned "hand"
⍝H           ⊤BI  ⍵             bit-decode: converts BI to equivalent bits: see ⊥.
⍝H           ~BI  ⍵             flip: flip all the bits in big integer BI  ⍵, returning a big integer (not bits)
⍝H           ⎕AT BI  ⍵          attributes: returns 3 integers: <num hands> <num bits> <num 1 bits>
⍝H                          (hands: a BigInt consists of a sign num (¯1 0 1) and a vector of unsigned integers, each such integer is called a hand.)
⍝H                          (num bits: We pretend each big integer consists of the ravel of a sign bit (1=neg) and a sequence of bits for each hand.)
⍝H                          (num 1 bits: Also known as a population count (popcount).)
⍝H  DYADIC OPERANDS: ⍺ ×BI ⍵, ⍺ ×BII ⍵, ⍺ ×BIM ⍵⍵ ⊣ modulo
⍝H  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
⍝H        BI, BII: Arguments ⍺ and ⍵ are Big Integer internal or external formats (BigIntI or BigIntE)
⍝H        BIM:     ⍺ (fn BIM modulo)⍵  <==>   modulo | ⍺ fn BI ⍵, except × and * are calculated efficiently within range <modulo>.
⍝H           ⍺ + BI  ⍵          add
⍝H           ⍺ - BI  ⍵          subtract
⍝H           ⍺ × BI  ⍵          multiply
⍝H           ⍺ ÷ BI  ⍵          divide
⍝H           ⍺ * BI  ⍵          power.    BI  ⍵ may be fractional to express integral root ÷BI  ⍵.    cube root:    ⍵ *BI ÷3
⍝H           ⍺ *∘÷ BI  ⍵        BI  ⍵th root ⍺                                                        cube root: 3 *∘÷ BI  ⍵
⍝H           ⍺ ('√' BI)  ⍵      BI  ⍵th root ⍺                                                    cube root: 3 ('√' BI) BI  ⍵
⍝H           ⍺ ⍟ BI  ⍵          log of ⍵ in base ⍺.    Optimized for ⍺∊2 10 only.
⍝H           ⍺ ↑ BI  ⍵          decimal shift of ⍵ left  by ⍺ digits. Special code.    May be slower than [⍺ ×BI 10*BI  ⍵]
⍝H           ⍺ ↓ BI  ⍵          decimal shift of ⍵ right by ⍺ digits. Special code.    Ditto.
⍝H           ⍺ ⌽ BI  ⍵          binary shift of ⍵ to left (⍺≥0) or right (⍺≤0) by ⍺ digits [same as ⍺ ×BI 2*BII  ⍵]
⍝H           ⍺ | BI  ⍵          remainder ⍺ | BI  ⍵
⍝H                          ALIAS:  BI  ⍵ ('MOD' BI) ⍺  or   BI  ⍵ |⍨BI ⍺   (or its equiv:  BI  ⍵ |BI⍨ ⍺)
⍝H           ⍺ ⌈ BI  ⍵          max
⍝H           ⍺ ⌊ BI  ⍵          min
⍝H           ⍺ ∨ BI  ⍵          gcd (not: or)
⍝H           ⍺ ∧ BI  ⍵          lcm (not: and)
⍝H           ⍺ 'DIVREM' BI  ⍵   returns two BigInts: ⌊⍺÷BI  ⍵ and  BI  ⍵|⍺
⍝H        Logical:  ⍺ < BI  ⍵ means   ⍺ <BI ⍵,  where ⍺ and ⍵ are bigints; each fn returns 1 if true, else 0
⍝H           < ≤ = ≥ > ≠
⍝H
⍝H        CONSTANTS (niladic functions findable by ⎕PATH)
⍝H           ZERO_BI← +BI 0     ONE_BI    ←+BI 1
⍝H           TWO_BI ← +BI 2     MINUS1_BI ←_BI ¯1
⍝H           TEN_BI ← +BI 10
⍝H         INTERNAL CONSTANTS (fast arrays found via their full namespace specification:
⍝H           BI_LIB.( ZERO_BI ONE_BI TWO_BI MINUS1_BI TEN_BI)
:EndSection HELP_INTRO

:Section BI
  :Section PREAMBLE
    DEBUG←0               ⍝ Set DEBUG here.
    ⎕IO ⎕ML ⎕PP ⎕CT ⎕DCT ⎕FR ← 0 1 34 0 0 645            ⍝ Nota Bene: ⎕FR determines OFL below
    Err←⎕SIGNAL/{⍺←1  ⋄ ⍺: ('BI ',⍵) 11 ⋄ 0}
  :EndSection PREAMBLE

  :Section Namespace and Utility Initializations
  ⍝+------------------------------------------------------------------------------+⍝
  ⍝+-- BI INITIALIZATIONS                            BI INITIALIZATIONS         --+⍝
  ⍝-------------------------------------------------------------------------------+⍝

  ⍝ Set key bigInt constants...
    NRX2←            20                                  ⍝ Num bits in a "hand"
    NRX10←           ⌊10⍟RX2←2*NRX2                      ⍝ Max num of dec digits in a hand
    NRX2BASE←        NRX2⍴2                              ⍝ Encode/decode binary base
    RX10BASE←        NRX10⍴10                            ⍝ Encode/decode decimal base
    RX10←            10*NRX10                            ⍝ Actual base for each hand (each hand ⍵ < RX10)
    RX10div2←        RX10÷2                              ⍝ Sqrt of each hand's base, for use in <pow> (power).
    OFL←             {⌊(2*⍵)÷RX10×RX10}(⎕FR=1287)⊃53 93  ⍝ Overflow bits for use in mulU (unsigned multiply)

  ⍝ Data field (unsigned) constants for internal unsigned utilities
    ZERO_D ←  ,0                                         ⍝ data field ZERO, i.e. unsigned canonical ZERO
    ONE_D  ←  ,1                                         ⍝ data field ONE,  i.e. unsigned canonical ONE
    TWO_D  ←  ,2                                         ⍝ data field TWO
    TEN_D  ← ,10                                         ⍝ data field TEN

  ⍝ BigInt signed CONSTANTS for users and internal utilities.
    ZERO_BI   ←   0 ZERO_D                               ⍝  0
    ONE_BI    ←   1  ONE_D                               ⍝  1
    TWO_BI    ←   1  TWO_D                               ⍝  2
    MINUS1_BI ←  ¯1  ONE_D                               ⍝ ¯1
    TEN_BI    ←   1  TEN_D                               ⍝ 10
  
  ⍝ Error messages. See dfn <Err>
    eIMPORT  ←'Obj cannot be converted to a valid BigInt.'
    eBADRAND ←'Arg to roll (?) must be integer >0.'
    eFACTOR  ←'Arg to factorial (!) must be ≥ 0'
    eBADRANGE←'BigInt too large to be approximated in APL: outside dynamic range (±1E6145)'
    eBIC     ←'BIC: arg must be a fn name or one or more code strings.'
    eBOOL    ←'Importing bits: boolean arg (1s or 0s) expected.'
    eCANTDO1 ←'Monadic function (operand) not implemented: '
    eCANTDO2 ←'Dyadic function (operand) not implemented: '
    eBIMDYAD ←'BIM Operator: only dyadic functions are supported.'
    eLOG     ←'Log of a non-positive BigInteger is undefined'
    eSMALLRT ←'Right argument must be a small APL integer ⍵<',⍕RX10
    eMUL10   ← eSMALLRT
    eROOT    ←'Base (⍺) for root must be small non-zero integer: ⍺<',⍕RX10
    eSUB     ←'subU LOGIC: unsigned subtraction may not become negative'

    :EndSection Namespace and Utility Initializations

    :Section Executive
    ∇ BI_HELP;⎕PW
     ⍝ extern: HELP_INFO
      :If 0=⎕NC'HELP_INFO' ⋄ HELP_INFO←'^\h*⍝H(.*)$'⎕S'\1'⎕SRC ⎕THIS ⋄ :EndIf
      ⎕PW←120 ⋄ (⎕ED⍠'ReadOnly' 1)&'HELP_INFO'
    ∇
    ⍝ --------------------------------------------------------------------------------------------------
    ⍝ monadFnsList, dyadFnsList - required for BIC to function, so keep the lists complete!
    ⍝    @(S SV):  [0] single-char symbols [1] multi-char names in upper case
    monadFnsList←'-+|×÷<>≤≥!?⊥⊤⍎→√~⍳'('SQRT' 'NOT' '⎕AT')
    ⍝             reg. fns            boolean               <use upper case here>
    dyadFnsList←('+-×*÷⌊⌈|∨∧⌽↑↓√≢~⍟','<≤=≥>≠⍴')('*∘÷' '*⊢÷' 'ROOT' 'SHIFTD' 'SHIFTB'  'DIVREM' 'MOD')

    ⍝ BII: Basic utility operator for using APL functions in special BigInt meanings.
    ⍝     BIint ← ∇ ⍵:BIext
    ⍝     Returns BIint, an internal format BigInteger structure (sign and data, per above).
    ⍝     See below for exceptions ⊥ ⊤ ⍎
    ⍝ BI: Basic utility operator built on BII.
    ⍝     BIext ← ∇ ⍵:BIext
    ⍝     Returns BIext, an external string-format BigInteger object ("[¯]\d+").
    ⍝ Note: __BI_SOURCE__ is a TEMPLATE fn to be replaced, after substitutions, by cover functions BI and BII.
    ⍝ Note: _COND_EXPORT_ is TEMPLATE name to be substituted by name "Export" or null string in BI and BII cover fns.

⍝ --------------------------------------------------------------------------------------------------
⍝   DecodeCall: Handle operator name plus monadic vs dyadic plus operands like +⍨. (We treat +⍨⍨ etc. like +⍨)
⍝   fnAtom monadFlag inverseFlag ←  ⍺ ⍺⍺ DecodeCall ⍵
⍝          inverseFlag: 0 - no inverse (⍺÷⍵ or +⍵), 1 - regular inverse (⍵+⍺), 2 - selfie ( ⍵ + ⍵)
      DecodeCall←{⍺←⊢
          getOpName←{aa←⍺⍺ ⋄ 3=⎕NC'aa':∊⍕⎕CR'aa' ⋄ 1 ⎕C aa}
          decode←{
              atom←{1=≢⍵:⍬⍴⍵ ⋄ ⊂⍵}
              monad name←⍺(atom ⍵~'⍨ ')
              '⍨'∊⍵:name 0(1+monad)
              name monad 0
          }
          (1≡⍺ 1)decode ⍺⍺ getOpName ⍵
      }

    ⍝ __BI_SOURCE__ is a template for ops BII and BI.
      __BI_SOURCE__←{⍺←⊢
          DEBUG↓0::⎕SIGNAL/⎕DMX.(EM EN)
          QT←''''
          fn monad inv←⍺(⍺⍺ DecodeCall)⍵
          CASE←fn∘∊∘⊆
     
        ⍝ Monadic...
          monad:{                                       ⍝ BI: _COND_EXPORT_: See Build BI/BII below.
            ⍝ math
              CASE'-':_COND_EXPORT_ neg ⍵              ⍝     -⍵
              CASE'+':_COND_EXPORT_ Import ⍵           ⍝     canon: ensures ⍵ is valid. Returns in canonical form.
              CASE'|':_COND_EXPORT_ abs ⍵              ⍝     |⍵
              CASE'×':_COND_EXPORT_⊃Import ⍵       ⍝     signum      Returns APL int (∊¯1 0 1), not BII.
              CASE'÷':_COND_EXPORT_ recip ⍵            ⍝     inverse     Why bother? Mostly 0!
            ⍝ Misc
              CASE'<':_COND_EXPORT_ dec ⍵              ⍝     decrement   Optimized for constant in ⍵-1.
              CASE'≤':_COND_EXPORT_ dec ⍵              ⍝     decrement   I prefer <, but J prefers ≤
              CASE'>':_COND_EXPORT_ inc ⍵              ⍝     increment   Optimized for constant in ⍵+1. I
              CASE'≥':_COND_EXPORT_ inc ⍵              ⍝     increment   I prefer >, but J prefers ≥
              CASE'!':_COND_EXPORT_ fact ⍵             ⍝     factorial   For smallish integers ⍵≥0
              CASE'?':_COND_EXPORT_ roll ⍵             ⍝     roll        For int ⍵>0 (0 invalid: result would always truncate to 0)
              CASE'⍎':ExportApl ⍵                      ⍝     aplint      If in range, returns a std APL number; else error
              CASE'⍕':Prettify Export ∆ ⍵              ⍝     pretty      Returns a pretty BII string: - for ¯, and _ separator every 5 digits.
              CASE'SQRT' '√':_COND_EXPORT_ sqrt ⍵      ⍝     sqrt        See dyadic *0.5
              CASE'⍳':⍳ReturnSmallAPLInt ⍵             ⍝     iota ⍵      Allow only small integers... Returns a set of APL integers
              CASE'→':Import ⍵                         ⍝     internal    Return ⍵ in internal form.
            ⍝ Bit manipulation
              CASE'⊥':_COND_EXPORT_ BitsImport ⍵       ⍝     BitsImport  Convert bits to bigint
              CASE'⊤':BitsExport ⍵                     ⍝     BitsExport  Convert bigint ⍵ to bits: sign bit followed by unsigned bit equiv to ⍵
              CASE'~':_COND_EXPORT_ BitsImport~BitsExport ⍵  ⍝  Reverses all the bits in a bigint (why?)
              CASE'⎕AT':GetBIAttributes ⍵              ⍝     ⎕AT         <num hands> <num bits> <num 1 bits>
              Err eCANTDO1,QT,QT,⍨fn                   ⍝     Not found.
          }⍵
      ⍝ Dyadic...
        ⍝ See discussion of ⍨ above...
          ⍺{
            ⍝ High Use: [Return BigInt]
              CASE'+':_COND_EXPORT_ ⍺ add ⍵
              CASE'-':_COND_EXPORT_ ⍺ sub ⍵
              CASE'×':_COND_EXPORT_ ⍺ mul ⍵
              CASE'÷':_COND_EXPORT_ ⍺ div ⍵                  ⍝ Integer divide: ⌊⍺÷⍵
              CASE'*':_COND_EXPORT_ ⍺ pow ⍵                  ⍝ Power / Roots I.    num *BI  ÷r
              CASE'*∘÷' '*⊢÷':_COND_EXPORT_ ⍵ root ⍺         ⍝         Roots II.   num *∘÷BI r
              CASE'√' 'ROOT':_COND_EXPORT_ ⍺ root ⍵          ⍝         Roots III.  r ('ROOT'BI) num
     
        ⍝ ↑ ↓ Decimal shift (mul, div by 10*⍵)
        ⍝ ⌽   Binary shift  (mul, div by 2*⍵)
              CASE'↑':_COND_EXPORT_ ⍵ mul10Exp ⍺             ⍝  ⍵×10*⍺,   where ±⍺. Decimal shift.
              CASE'↓':_COND_EXPORT_ ⍵ mul10Exp-⍺             ⍝  ⍵×10*-⍺   where ±⍺. Decimal shift right (+) or left (-).
              CASE'⌽':_COND_EXPORT_ ⍵ mul2Exp ⍺              ⍝  ⍵×2*⍺     where ±⍺. Binary shift left (+) or right (-).
              CASE'|':_COND_EXPORT_ ⍺ rem ⍵                  ⍝ remainder: |   (⍺ | ⍵) <==> (⍵ modulo a)
        ⍝ Logical: [Return single boolean, 1∨0]
              CASE'<':⍺ lt ⍵
              CASE'≤':⍺ le ⍵
              CASE'=':⍺ eq ⍵
              CASE'≥':⍺ ge ⍵
              CASE'>':⍺ gt ⍵
              CASE'≠':⍺ ne ⍵
        ⍝ Other fns
              CASE'⌈':_COND_EXPORT_(∆ ⍺){⍺ ge ⍵:⍺ ⋄ ⍵}∆ ⍵     ⍝ ⍺ ⌈ ⍵
              CASE'⌊':_COND_EXPORT_(∆ ⍺){⍺ le ⍵:⍺ ⋄ ⍵}∆ ⍵     ⍝ ⍺ ⌊ ⍵
              CASE'∨' 'GCD':_COND_EXPORT_ ⍺ gcd ⍵             ⍝ ⍺∨⍵ as gcd.  NOT boolean or.
              CASE'∧' 'LCM':_COND_EXPORT_ ⍺ lcm ⍵             ⍝ ⍺∧⍵ as lcm.  NOT boolean and.
              CASE'⍟':_COND_EXPORT_ ⍺ log ⍵                   ⍝ ⍺ log ⍵
              CASE'MOD':_COND_EXPORT_ ⍵ rem ⍺                 ⍝ modulo:  Same as |⍨
              CASE'SHIFTB':_COND_EXPORT_ ⍺ mul2Exp ⍵          ⍝ Binary shift:  ⍺×2*⍵,  where ±⍵.   See also ⌽
              CASE'SHIFTD':_COND_EXPORT_ ⍺ mul10Exp ⍵         ⍝ Decimal shift: ⍺×10*⍵, where ±⍵.   See also ↑ and ↓.
              CASE'DIVREM':_COND_EXPORT_¨⍺ divRem ⍵           ⍝ Returns pair:  (⌊⍺÷⍵) (⍵|⍺)
              CASE'⍴':(ReturnSmallAPLInt ⍺)⍴⍵                 ⍝ Standard ⍴: Requires ⍺ in ⍺ ⍴ ⍵ to be in range of APL int.
              Err eCANTDO2,QT,QT,⍨fn                          ⍝ Not found!
          }{2=inv:⍵ ⍺⍺ ⍵ ⋄ inv:⍵ ⍺⍺ ⍺ ⋄ ⍺ ⍺⍺ ⍵}⍵         ⍝ Handle ⍨.   inv ∊ 0 1 2 (0: not inv, 1: inv, 2: selfie)
      }
    ⍝H
    ⍝H BIM:   Perform BI modulo <mod>.
    ⍝H BIM:   x (fn BIM mod)y  ==>   mod |BI x (fn BII) y, but more efficient for fn: × or *. 
    ⍝H Example:    a←(100⍴⎕D)  ⋄   b←⌽'5',99⍴⎕D 
    ⍝H             c←88⍴⎕D,'321'
    ⍝H             a(×BIM c)⊢b 
    ⍝H          14316503065026389482323754496389255946041429392115238386058791621521416992113483598656
    ⍝H             c |BI a×BI b
    ⍝H          14316503065026389482323754496389255946041429392115238386058791621521416992113483598656
    ⍝H             a(*BIM '9999')⊢b       ⍝ *BIM   -- calculation fits in workspace (266M)
    ⍝H          2727
    ⍝H             (9999 |BI a*BI b)      ⍝ a*BI b -- too large to calculate!
    ⍝H          WS FULL
    ⍝H          (9999|BI a*BI b)
    ⍝H                    ∧
      BIM←{
          ⍺←⎕NULL ⋄  x y modulo←⍺ ⍵ ⍵⍵  
          fn←⊃x ⍺⍺ DecodeCall modulo
          ⍺≡⎕NULL:Err eBIMDYAD
          fn≡'×':Export x (modulo modMul) y 
          fn≡'*':Export x (modulo modPow) y
          ⋄ mod|BI x(fn BII)y
      }
    ⍝ Build BI and BII from __BI_SOURCE__.
    ⍝ BI:   Change _COND_EXPORT_ to "Export", __BI__SOURCE__ to "BI".
    ⍝ BII:  Change _COND_EXPORT_ or _COND_EXPORT_¨ to "", __BI__SOURCE__ to "BII".
    ⎕FX'__BI_SOURCE__' '_COND_EXPORT_'  ⎕R 'BI'  'Export'⊣⎕NR'__BI_SOURCE__'
    ⎕FX'__BI_SOURCE__' '_COND_EXPORT_¨?'⎕R 'BII' ''      ⊣⎕NR'__BI_SOURCE__'
    ___←⎕EX '__BI_SOURCE__'

    :EndSection BI Executive
    ⍝ ----------------------------------------------------------------------------------------

    :Section BigInt internal structure
      ⍝ ============================================
      ⍝ Import / ∆ - Import to internal bigInteger
      ⍝ ============================================
      ⍝  ⍺ ∆ ⍵  →→  (∆ ⍺)(∆ ⍵)
      ⍝  ∆ ⍵
      ⍝      from: 1) a BigInteger string,
      ⍝            2) an APL integer, or
      ⍝            3) an internal-format BigInteger (depth ¯2), passed through unchanged.
      ⍝      to:   internal format (BIint) BigIntegers  ⍵'
      ⍝            of the form sign (data), where sign is a scalar 1, 0, ¯1; data is an integer vector.
      ⍝ Let type=80|⎕DR ⍵    
      ⍝    depth=|⍵          return                      
      ⍝ ---------------+------------------------------------- 
      ⍝  Depth ¯2             ⍵                  internal Big Integer                    
      ⍝  Type   0             ImportStr ⍵        char 
      ⍝  Type   3             ImportInt ⍵        integers
      ⍝  Type   5, 7          ImportFloat ⍵      floats (integers with exponents only)        
      ⍝ Output: BIint, i.e.  (sign (,ints)), where ints∧.<RX10
      ⍝
      ⍝ [⍺] Import ⍵
      ⍝ [⍺] ∆ ⍵
      Import←{⍺←⊢
          1≢⍺ 1:(∇ ⍺)(∇ ⍵)
          ¯2=≡⍵:   ⍵             ⍝ Fast: BigInts (depth: ¯2) are of form:  [1|0|¯1] [int vector]
          type←80|⎕DR ⍵
          type=3:ImportInt ⍵  ⋄ type=0:ImportStr ⍵ ⋄ type∊5 7:ImportFloat ⍵
          Err eIMPORT
      }
      ∆←Import
 
      ⍝ ImportInt:    ∇ ⍵:I[1]
      ⍝          ⍵ MUST Be an APL native (1-item) integer ⎕DR type 83 163 323.
      ImportInt←{
          1≠≢⍵:       Err eIMPORT,⍕⍵       ⍝ singleton only...
          RX10>u←,|⍵: (×⍵)u                ⍝ Small integer
          (×⍵)(chkZ RX10⊥⍣¯1⊣u)            ⍝ Integer
      }
      ⍝ ImportFloat: Convert an APL integer into a BIint
      ⍝ Converts simple APL native numbers, as well as those with large exponents, e.g. of form:
      ⍝     1.23E100 into a string '123000...000', ¯1.234E1000 → '¯1234000...000'
      ⍝ These must be in the range of decimal integers (up to +/- 1E6145).
      ⍝ If not, you must use big integer strings of any length (exponents are disallowed in BigInt strings).
      ⍝ Normally, ImportFloat is not called by the user, since BII and BI call it automatically.
      ⍝ Usage:
      ⍝    (BI_LIB.∆  1E100)         ≡  bigInt.∆ '1',100⍴'0'   <==>  1
      ImportFloat←{⎕FR←1287 ⍝ 1287: to handle large exponents
          (1=≢⍵)∧(⍵=⌊⍵):(×⍵)(chkZ RX10⊥⍣¯1⊣|⍵)
          Err eIMPORT,⍕⍵
      }
      ⍝ ImportStr: Convert a BigInt in string format into an internal BigInt
      ⍝       ImportStr ⍵:S[≥1]   (⍵ must have at least one digit, possibly a 0)
      ImportStr←{
          s←1 ¯1⊃⍨'-¯'∊⍨1↑⍵            ⍝ Get sign, if any
          w←'_'~⍨⍵↓⍨s=¯1               ⍝ Remove initial sign and embedded _ (spacer: ignored).
          (0=≢w)∨0∊w∊⎕D:Err eIMPORT     ⍝ w must include only ⎕D and at least one.
          d←rep ⎕D⍳w                   ⍝ d: data portion of BIint
          ∆dlzNorm s d                 ⍝ Normalize (remove leading 0s). If d is zero, return ZERO_BI.
      }
      ⍝ ReturnSmallAPLInt: Import ⍵ only if (when Imported) it is a single-hand integer
      ⍝          i.e. equivalent to a number (|⍵) < RX10.
      ⍝ Returns a small APL integer!
      ⍝ Usage: so far, we only use it in BI/BII where we are passing data to an APL fn (⍳).
      ReturnSmallAPLInt←{
          s w←∆ ⍵ ⋄ 1≠≢w:Err eSMALLRT ⋄ s×,w
      }
    ⍝ ---------------------------------------------------------------------
    ⍝ Export: EXPORT a SCALAR BigInt to external "standard" bigInteger
    ⍝ ---------------------------------------------------------------------
    ⍝    r:BIc ← ∇ ⍵:BIint
    Export←{ ('¯'/⍨¯1=⊃⍵),⎕D[dlzRun,⍉RX10BASE⊤|⊃⌽⍵]}
    
    :EndSection BigInt internal structure
⍝ --------------------------------------------------------------------------------------------------

     ⍝ _RawCall fn_name
     ⍝ Converts core numeric function named to lower-overhead version.
     ⍝ From routine "add", creates "_add" with conversion code 
     ⍝     (∆ ⍵) and (⍺ ∆ ⍵)
     ⍝ removed. 
    ∇ {fnNmOut}←_RawCall fnNm
        ;fnInP;fnOutA;inP;outA
      fnInP fnOutA←('\b',fnNm,'\b')('_',fnNm)
      inP outA←(fnInP '←⍺ ∆ ⍵'  '←∆ ⍵' )(fnOutA '←⍺ ⍵'  '←⍵')
      fnNmOut←⎕FX inP ⎕R outA ⍠('UCP' 1)⊣⎕NR fnNm
      :IF 0=1↑0⍴fnNmOut 
          Err '_RawCall: Error ⎕FXing variant of ',fnNm
      :ENDIF 
    ∇

    :Section BI Monadic Operations/Functions
    ⍝H
    ⍝H BI Monadic Internal Functions            
    ⍝H    neg                       
    ⍝H    sig                       
    ⍝H    abs                       
    ⍝H    inc                       
    ⍝H    dec                       
    ⍝H    fact                      
    ⍝H    roll                    
    ⍝H    BitsExport 
    ⍝H    root
    ⍝H    GetBIAttributes
    ⍝H    BitsImport (requires ⍵ boolean vector)

    ⍝ neg[ate] / _neg[ate]
      neg←{                                ⍝ -
          (sw w)←∆ ⍵
          (-sw)w
      }
    ⍝ sig[num], _signum
      sig←{                                ⍝ ×
          (sw w)←∆ ⍵
          sw(|sw)
      }
    ⍝ abs: absolute value
      abs←{                                ⍝ |
          (sw w)←∆ ⍵
          (|sw)w
      }
    ⍝ inc[rement]:                         ⍝ ⍵+1
      inc←{
          (sw w)←∆ ⍵
          sw=0:1 ONE_D                     ⍝ ⍵=0? Return 1.
          sw=¯1:∆dlzNorm sw(⊃⌽_dec 1 w)    ⍝ ⍵<0? inc ⍵ becomes -(dec |⍵). ∆dlzNorm handles 0.
          î←1+⊃⌽w                          ⍝ trial increment (most likely path)
          RX10>î:sw w⊣(⊃⌽w)←î              ⍝ No overflow? Increment and we're done!
          sw w _add 1 ONE_D                ⍝ Otherwise, do long way.
      }
    ⍝ dec[rement]:                         ⍝ ⍵-1
      dec←{
          (sw w)←∆ ⍵
          sw=0:¯1 ONE_D                    ⍝ ⍵ is zero? Return ¯1
          sw=¯1:∆dlzNorm sw(⊃⌽_inc 1 w)    ⍝ ⍵<0? dec ⍵  becomes  -(inc |⍵). ∆dlzNorm handles 0.
                                           ⍝ If the last digit of w>0, w-1 can't underflow.
          0≠⊃⌽w:∆dlzNorm sw w⊣(⊃⌽w)-←1     ⍝ No underflow?  Decrement and we're done!
          sw w _sub 1 ONE_D                ⍝ Otherwise, do long way.
      }
    _RawCall¨'neg' 'sig' 'abs'  'inc' 'dec'

    ⍝ fact: compute BI factorials.
    ⍝       r:BIc ← fact ⍵:BIext
    ⍝ We allow ⍵ to be of any size, but numbers larger than NRX10 are impractical.
    ⍝ We deal with 3 cases:
    ⍝    ⍵ ≤ 31:    We let APL calculate, with ⎕PP←34.   Fast.
    ⍝    ⍵ ≤ NRX10:   We calculate r as a BigInt, while counting down ⍵ as an APL integer. Moderately fast.
    ⍝    Otherwise: We calculate entirely using BigInts for r and ⍵. Slowwwwww.
      fact←{                                ⍝ !⍵
          sw w←∆ ⍵
          sw=0:ONE_BI                       ⍝ !0
          sw=¯1:Err eFACTOR                 ⍝ ⍵<0
          factBig←{
              1=≢⍵:⍺ factSmall ⍵            ⍝ Skip to factSmall when ≢⍵ is 1 hand.
              (⍺ mulU ⍵)∇⊃⌽_dec 1 ⍵
          }
          factSmall←{
              ⍵≤1:1 ⍺
              (⍺ mulU ⍵)∇ ⍵-1
          }
          1 factBig w
      }
    ⍝ roll ⍵: Compute a random number between 0 and ⍵-1, given ⍵>0.
    ⍝    r:BIint ← ∇ ⍵:BIint   ⍵>0.
    ⍝ With inL the # of dec digits in ⍵, excluding any leading '0' digits...
    ⍝ Proceed as shown here, where (Export ⍵) is "exported" BIext format; (∆ ⍵) is internal BIint format.
      roll←{
          sw w←∆ ⍵
          sw≠1:Err eBADRAND
          ⎕PP←16 ⋄ ⎕FR←645                       ⍝ 16 digits per ?0 is optimal
          inL←≢Export sw w                          ⍝ ⍵: in Export form. in: ⍵ with leading 0's removed.
     
          res←inL⍴{                              ⍝ res is built up to ≥inL random digits...
              ⍺←''                               ⍝ ...
              ⍵≤≢⍺:⍺ ⋄ (⍺,2↓⍕?0)∇ ⍵-⎕PP          ⍝ ... ⎕PP digits at a time.
          }inL                                   ⍝ res is then truncated to exactly inL digits
          '0'=⊃res:∆ res                         ⍝ If leading 0, guaranteed (∆ res) < ⍵.
          ⍵ rem ∆ res                            ⍝ Otherwise, compute rem r: 0 ≤ r < ⍵.
      }
  ⍝⍝  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  ⍝⍝  Bit Management Utilities
  ⍝⍝  ⊥    bits→bi
  ⍝⍝  ⊤    bi→bits,
  ⍝⍝  ~    reverses bits of bi ⍵, i.e.   (⊥ ~ ⊤ ⍵)
  ⍝⍝  We allow
  ⍝⍝      1. Importing from a simple bit array ⍵ ravelled to: bits←,⍵
  ⍝⍝          [sign] bits
  ⍝⍝           sign: 1 for negative, 0 for positive.
  ⍝⍝           bits: 1 or more bits
  ⍝⍝         Returns a bigint in internal format, normalized as required.
  ⍝⍝         If <bits> are not multiple of 20 (NRX2), the non-sign <bits> are padded on the left with 0s (unsigned)
  ⍝⍝      2. Exporting from a signed bigint object to a vector:
  ⍝⍝          [sign] bits
  ⍝⍝          sign, bits: as above
  ⍝⍝  For bit array manipulation, perform entirely using APL's more powerful intrinsics, then convert to a bigint.
  ⍝⍝  ~ included in BI(I) calls for demonstration purposes.
  ⍝⍝
  ⍝⍝  Bugs: Except for the overall sign bit, the bigint data is handled as unsigned in every case,
  ⍝⍝        not in a  2s-complement representation.
  ⍝⍝        That is, ¯1 is stored as (sign bit: 1) plus (data: 0 0 0 ... 0 1), not as all 1s (as expected for 2s-complement).
  ⍝⍝            ¯1 can be represented as   1 1    OR    1 0 1    OR    1 0 0 0 ... 0 1, etc.
  ⍝⍝  See  ⊥BI ⍵ OR 'BITSIN' BI ⍵ and  ⊤BI ⍵ OR 'BITSOUT' BI ⍵
      BitsImport←{
        ⍝ Allow quoted args, as presented by BI_DC desk calculator
          ' '=1↑0⍴⍵:∇{ ~0∊⍵∊'01': ⍺⍺ '1'=⍵  ⋄ Err eBOOL }⍵~' ' 
          0∊⍵∊0 1:Err eBOOL
          bits←,⍵
          sgn←(⊃bits)⊃1 ¯1 ⋄ bits←1↓bits    ⍝ 1st bit is sign bit.
          nhands←⌈exact←NRX2÷⍨≢bits         ⍝ Process remaining bits into hands of <nbits> each
          bits←nhands NRX2⍴{
              nhands=exact:⍵
              (-nhands×NRX2)↑⍵              ⍝ Padding first hand on left with 0s (unsigned)
          }bits
          ∆dlzNorm sgn(2⊥⍉bits)         ⍝ Convert to bigint:  (sign) (integer array)
      }
      BitsExport←{
          sw w←∆ ⍵
          sw=0:0,NRX2⍴0
          (sw=¯1),,⍉NRX2BASE⊤w
      }

    ⍝ GetBIAttributes: Returns    #Hands   #Bits*   #1-bits*         *=(in bit representations)
    ⍝        ≢bits is also  1 + 20 × #hands
    GetBIAttributes←{hands←≢⊃⌽w←∆ ⍵ ⋄ bits←BitsExport w ⋄ hands (≢bits) (+/1=bits) }


    ⍝ ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

    ⍝ root: A fast integer nth root.
    ⍝ Syntax:    x@BIint ← nth@BIext<RX10 ∇ N@BIext
    ⍝            x ← nth root N  ==>   x ← ⌊N *÷nth
    ⍝   nth: a small, positive integer (<RX10); default 2 (for sqrt).
    ⍝   N:   any BIext
    ⍝   x:   the nth root as an internal big integer.
    ⍝   ∘ Uses Fredrick Johanssen's algorithm with optimization for APL integers.
    ⍝   ∘ Estimator based on guesstimate for sqrt N, no matter what root.
    ⍝     (Better than using N).
    ⍝   ∘ As fast for sqrt as a "custom" version.
    ⍝   ∘ If N is small, calculate directly via APL.
    ⍝ x:BIint ← nth:small_(BIint|BIext) ∇ N:(BIint|BIext)>0
      root←{
        ⍝ Check radix in  N*÷radix
        ⍝ We work with bigInts here for convenience. Could be done unsigned...
          ⍺←2 ⍝ sqrt by default...
          sgn rdx←⍺{   ⍝ Get the sign, (÷radix), radix based on ⍺.
              ⍵:1 2
              sgn rdx←Import ⍺
              sgn=0:Err eROOT 
              1<≢rdx:Err eROOT 
              sgn rdx
          }900⌶⍬
          sgn<0:0    ⍝  ⌊N*÷nth ≡ 0, if nth<0 (nth a small int)
        ⍝ Check N
          sN N←Import ⍵
          0=sN:sN N                    ⍝  0=×N?   0
          ¯1=sN:Err eROOT        ⍝ ¯1=×N?   error
          rootU←*∘(÷rdx)
     
          1=ndig←≢N:1(,⌊rootU N)    ⍝ N small? Let APL calc value
        ⍝ Initial estimate for N*÷nth must be ≥ the actual solution, else this will terminate prematurely.
        ⍝ Initial estimate (x):
        ⍝   DECIMAL est: ¯1+10*⌈num_dec_digits(N)÷2   ←-- We use this one.
        ⍝   BINARY  est:  2*⌈numbits(N)÷2
          x←{ ⍝ We use DECIMAL est(sqrt N) as initial estimate for ANY root. Not ideal, but safe.
              0::1((⌈rootU⊃⍵),(RX10-1)⍴⍨⌈0.5×ndig-1) ⍝ Too big for APL est. Use DECIMAL est. above.
              ⎕FR←1287
              ⊃⌽Import 1+⌈rootU⍎Export 1 ⍵     ⍝ Est from APL: works for ⍵ ≤ ⌊/⍬ 1E6145
          }N
        ⍝ Refine x, aka ⍵, until y > x
        ⍝ All unsigned here
          {x←⍵
              y←(x addU N quotientU x)quotientU rdx    ⍝ y is next guess: y←⌊((x+⌊(N÷x))÷nth)
              ≥cmp y mix x:1(,x)
              ∇ y                              ⍝ y is smaller than ⍵. Make x ← y and try another.
          }x
      }
    sqrt←root
    rootX←{⍺←⊢ ⋄ Export ⍺ root ⍵}

  ⍝ recip:  ÷⍵ ←→ 1÷⍵ Almost useless, since ÷⍵ is 0 unless ⍵ is 1 or ¯1.
    recip←{{0=≢⍵: ÷0 ⋄ 1≠≢⍵:0 ⋄ 1=|⍵:⍵ ⋄ 0}dlzRun ⍵}

    :Endsection BI Monadic Functions/Operations
⍝ --------------------------------------------------------------------------------------------------

    :Section BI Dyadic Functions/Operations
    ⍝H    Does Arg Conversions   Requires BI-Internal Args   Details
    ⍝H    For general use          For sophisticated use  
    ⍝H       slower                     faster         
    ⍝H         add                       _add
    ⍝H         sub                       _sub
    ⍝H         mul                       _mul
    ⍝H         div                       _div
    ⍝H         divRem                    _divRem
    ⍝H         pow                       _pow
    ⍝H         rem                       _rem                 ⍺ rem ⍵  ==  ⍺ | ⍵  (APL style)
    ⍝H         mod                       _mod                 ⍺ mod ⍵  ==  ⍵ | ⍺  (CS style)
    ⍝H         mul2Exp, shiftB           _mul2Exp             Shift ⍺ left or right by ⍵ binary digits (SLOW)
    ⍝H         mul10Exp, shiftD          _mul10Exp            Shift ⍺ left or right by ⍵ decimal digits (FAST)
    ⍝H         gcd                                            Greatest common divisor
    ⍝H         lcm                                            Lowest common multiple
    ⍝H
    ⍝H BI Boolean Functions (return 1 or 0)
    ⍝H         lt <, le ≤, eq =, ge ≥, gt >, ne ≠

  ⍝ dyad:    compute all supported dyadic functions
      add←{
          (sa a)(sw w)←⍺ ∆ ⍵
          sa=0:sw w                           ⍝ optim: ⍺+0 → ⍺
          sw=0:sa a                           ⍝ optim: 0+⍵ → ⍵
          sa=sw:sa(ndnZ 0,+⌿a mix w)          ⍝ 5 + 10 or ¯5 + ¯10
          sa<0:sw w _sub 1 a                  ⍝ Use unsigned vals: ¯10 +   5 → 5 - 10
          sa a _sub 1 w                       ⍝ Use unsigned vals:   5 + ¯10 → 5 - 10
      }
      sub←{
          (sa a)(sw w)←⍺ ∆ ⍵
          sw=0:sa a                            ⍝ optim: ⍺-0 → ⍺
          sa=0:(-sw)w                          ⍝ optim: 0-⍵ → -⍵
          sa≠sw:sa(ndnZ 0,+⌿a mix w)           ⍝ 5-¯3 → 5+3 ; ¯5-3 → -(5+3)
          <cmp a mix w:(-sw)(nupZ-⌿dck w mix a)  ⍝ 3-5 →  -(5-3)
          sa(nupZ-⌿dck a mix w)                ⍝ a≥w: 5-3 → +(5-3)
      }
      mul←{
          (sa a)(sw w)←⍺ ∆ ⍵
          0∊sa,sw:ZERO_BI
          TWO_D≡a:(sa×sw)(addU⍨w) ⋄ TWO_D≡w:(sa×sw)(addU⍨a)
          ONE_D≡a:(sa×sw)w ⋄ ONE_D≡w:(sa×sw)a
        ⍝ Performs more slowly:
        ⍝    TEN_D≡a: (sa×sw) w mul10Exp ONE_BI ⋄  TEN_D≡w: (sa×sw) a mul10Exp ONE_BI
          (sa×sw)(a mulU w)
      }
    ⍝ div: 
    ⍝ For special cases (except ⍺÷10), see divU.
      div←{ 
          (sa a)(sw w)←⍺ ∆ ⍵
          TEN_D≡w:  (sa×sw)a mul10Exp MINUS1_BI       ⍝ This can be hundreds of times faster than using divU.
          ∆normFromSign(sa×sw)(⊃a divU w)
      }
    ⍝ Since divU returns both quotient and remainder, calling divRem is preferred  over div and mod calls if you need both
    ⍝    (⍺ div ⍵)  and (⍺ mod ⍵)
    ⍝ For special cases, see divU.
      divRem←{
          (sa a)(sw w)←⍺ ∆ ⍵
          quot rem←a divU w
          (∆normFromSign(sa×sw)quot)(∆normFromSign sw rem)
      }
    _RawCall¨'add' 'sub' 'mul'  'div' 'divRem'

    ⍝ ⍺ pow ⍵:
    ⍝   General case:  ⍺*⍵ where both are BIint
    ⍝   Special case:  (÷⍵) (or ÷⍎⍵) is an integer: (÷⍵) root ⍺. Example:  ⍺*BI 0.5 is sqrt; ⍺*BI (÷3) is cube root; etc.
    ⍝                  (÷⍵) must be an integer to the limit of the current ⎕CT.
    ⍝ _decodeRoot (pow utility): Allow special syntax ( ⍺ *BI ÷⍵ ) in place of  ( ⍵ root ⍺ ).
    ⍝       ⍵ must be an integer such that 0<⍵<1 or a string representation of such an integer.
    ⍝       For 3 root 27, use:
    ⍝             I.e. '27' *BI ÷3    '27' *BI '÷3'
    ⍝       The root is truncated to an integer.
      _decodeRoot←{              ⍝ If not a root, return 0 to signify skip. Otherwise, return the radix (small positive number).
          0::0 ⋄ 0>≡⍵:0         ⍝ Bigint internal format? Skip
            ⍝             skip   ÷3   ←integer                 '÷3'                            '0.33'
          ⌊{extract←{1≤⍵:0 ⋄ ÷⍵} ⋄ 0=1↑0⍴⍵:extract ⍵ ⋄ '÷'=1↑⍵:⊃⊃⌽⎕VFI 1↓⍵ ⋄ extract⊃⊃⌽⎕VFI ⍵}⍵
      }
      pow←{
          0≠rt←_decodeRoot ⍵:rt root ⍺
        ⍝ Not a root, so decode as usual
        ⍝ Special cases ⍺*2, ⍺*1, ⍺*0 handled in powU.
          (sa a)(sw w)←⍺ ∆ ⍵
          sa sw∨.=0 ¯1:ZERO_BI     ⍝ r←⍺*¯⍵ is 0≤r<1, so truncates to 0.
          p←a powU w
          sa≠¯1:1 p                ⍝ sa= 1 (can't be 0).
          0=2|⊃⌽w:1 p ⋄ ¯1 p       ⍝ ⍺ is neg, so result is pos. if ⍵ is even.
      }
      rem←{                        ⍝ remainder/residue. APL'S DEF: ⍺=base.
          (sa a)(sw w)←⍺ ∆ ⍵
          sw=0:ZERO_BI
          sa=0:sw w
          r←,a remU w              ⍝ remU is fast if a>w
          sa=sw:∆dlzNorm sa r      ⍝ sa=sw: return (R)        R←sa r
          ZERO_D≡r:ZERO_BI         ⍝ sa≠sw ∧ R≡0, return 0
          ∆dlzNorm sa a _sub sa r  ⍝ sa≠sw: return (A - R')   A←sa a; R'←sa r
      }

    res←rem                        ⍝ residue (APL name)
    _RawCall¨ 'pow' 'rem'
    mod←rem⍨  ⋄  _mod←_rem⍨        ⍝ ⍺ mod ⍵  <== ⍵ rem ⍺

    ⍝ mul2Exp:  Shift ⍺:BIext left or right by ⍵:Int binary digits
    ⍝  r:BIint ← ⍺:BIint   ∇  ⍵:aplInt
    ⍝     Note: ⍵ must be an APL integer (<RX10).
    ⍝  -  If ⍵>0: shift ⍺ left by ⍵ binary digits
    ⍝  -  If ⍵<0: shift ⍺ rght by ⍵ binary digits
    ⍝  -  If ⍵=0: then ⍺ will be unchanged
    ⍝ Very slow!
      mul2Exp←{
          (sa a)(sw w)←⍺ ∆ ⍵
          1≠≢w:Err eMUL10                         ⍝ ⍵ must be small integer.
          sa=0:0 ZERO_D                           ⍝ ⍺ is zero: return 0.
          sw=0:sa a                               ⍝ ⍵ is zero: ⍺ stays as is.
          pow2←2*w
          sw>0:sa a mul pow2
          sa a div pow2
      }
      div2Exp←{
          ⍺ mul2Exp negate ⍵
      }
    shiftBinary←mul2Exp
    shiftB←mul2Exp

    ⍝ mul10Exp: Shift ⍺:BIext left or right by ⍵:Int decimal digits.
    ⍝      Converts ⍺ to BIc, since shifts are a matter of appending '0' or removing char digits from right.
    ⍝  r:BIint ← ⍺:BIint   ∇  ⍵:Int
    ⍝     Note: ⍵ must be an APL  big integer, BigIntA (<RX10).
    ⍝  -  If ⍵>0: shift ⍺ left by ⍵-decimal digits
    ⍝  -  If ⍵<0: shift ⍺ rght by ⍵ decimal digits
    ⍝  -  If ⍵=0: then ⍺ will be unchanged
    ⍝  WARNING: THIS APPEARS TO RUN ABOUT 80% SLOWER THAN A SIMPLE MULTIPLY FOR MEDIUM AND LONG ⍺, unless ⍵ is long, e.g. 1000 digits.
    ⍝           It is however much faster for ⍺ div  10 or ⍺ divRem 10, which use  ⍺ mul10Exp ¯1
      mul10Exp←{
          (sa a)(sw w)←⍺ ∆ ⍵
          1≠≢w:Err eMUL10                          ⍝ ⍵ must be small integer.
          sa=0:ZERO_BI                             ⍝ ⍺ is zero: return 0.
          sw=0:sa a                                ⍝ ⍵ is zero: sa a returned.
          ustr←Export 1 a                          ⍝ ⍺ as unsigned string.
          ss←'¯'/⍨sa=¯1                            ⍝ sign as string
          sw=1:∆ ss,ustr,w⍴'0'                     ⍝ sw= 1? shift right by appending zeroes.
          ustr↓⍨←-w                                ⍝ sw=¯1? shift right by dec truncation
          0=≢ustr:ZERO_BI                          ⍝ No chars left? It's a zero
          ∆ ss,ustr                                ⍝ Return in internal form...
      }
    shiftDecimal←mul10Exp                          ⍝ positive/left
    shiftD←mul10Exp
    _RawCall¨ 'mul10Exp' 'shiftD' 'mul2Exp'  'shiftB'

    ⍝ ∨ Greatest Common Divisor
      gcd←{
          (sa a)(sw w)←⍺ ∆ ⍵
          1(a gcdU w)
      }
    ⍝ ∧ Lowest Common Multiple
      lcm←{
          (sa a)(sw w)←⍺ ∆ ⍵
          (sa×sw)(a lcmU w)
      }
    _RawCall¨ 'gcd' 'lcm'

    ⍝ genBooleanFn-- generate Boolean functions lt <, le ≤, eq =, ge ≥, gt >, ne ≠
    ∇ {r}←genBooleanFn(NAME SYM);model;∆TEMPLATE;in;out
      ∆TEMPLATE←{
        ⍝ ⍺ ∆TEMPLATE ⍵: emulates (⍺ ∆SYM ⍵)
        ⍝ ⍺, ⍵: BigIntegers
          (sa a)(sw w)←⍺ ∆ ⍵
          0∊sa sw:sa ∆SYM sw        ⍝ ⍺, ⍵, or both are 0
          sa≠sw:sa ∆SYM sw          ⍝ ⍺, ⍵ different signs
          sa=¯1:∆SYM cmp w mix a    ⍝ ⍺, ⍵ both neg
          ∆SYM cmp a mix w          ⍝ ⍺, ⍵ both pos
      }
      in←'∆TEMPLATE' '∆SYM' ⋄ out←NAME SYM
      :If ' '≠1↑0⍴r←⎕THIS.⎕FX in ⎕R out⊣⎕NR'∆TEMPLATE'
          ∘∘∘⊣⎕←'⎕FIX-time LOGIC ERROR: unable to create boolean function: ',NAME,' (',SYM,')'
      :EndIf
    ∇
    genBooleanFn¨ ('lt' '<')('le' '≤')('eq' '=')('ge' '≥')('gt' '>')('ne' '≠')
    _RawCall¨ 'lt' 'le'  'eq' 'ge' 'gt' 'ne'
    ⎕EX 'genBooleanFn'

  ⍝ log:  L ← B log N
  ⍝  integer logarithm base <B> of big integer <N>. B defaults to (base) 10.
  ⍝ Returns <L> in BigIntI format.
    log2_10←(2⍟10)
      log←{
        log10←{¯1+≢Export ⍵}
        log2←{⌊log2_10×log10 ⍵}      ⍝ Verify.  FIX ME!!!
        ⍺←TEN_BI ⋄ B N←⍺ ∆ ⍵
      ⍝ Hidden way to calculate  2 log N the slow mathematical way. VERY SLOW!
        MINUS1_BI≡B:ZERO_BI{⍵ le ONE_BI:⍺ ⋄ (inc ⍺)∇ ⍵ _div B}N⊣B←TWO_BI
        0≥⊃N:Err eLOG        ⍝ N ≤ 0
        TEN_BI≡B:∆ log10 N
        TWO_BI≡B:∆ log2 N    ⍝ Magical, but sometimes off by a digit (???)
        ZERO_BI{⍵ _le ONE_BI:⍺ ⋄ (_inc ⍺)∇ ⍵ _div B}N   ⍝  0 {⍵ ≤ 1: ⍺  ⋄ (>⍺) ∇ ⍵ ÷ B} ⍵}
      }


    :EndSection BI Dyadic Operators/Functions

    :Section BI Special Functions/Operations (More than 2 Args)
    ⍝ modMul:  modulo m of product a×b
    ⍝ A faster method than (m|a×b), when a, b are large and m is substantially smaller.
    ⍝ r ← a (m modMul) b   →→→    r ← m | a × b
    ⍝ BIint ← ⍺:BIint ∇ ⍵:BIint m:BIint
    ⍝ Naive method: (m|a×b)
    ⍝      If a,b have 1000 digits each and m is smaller, the m| operates on 2000 digits.
    ⍝ Better method: (m | (m|a)×(m|b)).
    ⍝      Here, the multiply is on len(m) digits, and the final m operates on 2×len(m).
    ⍝ For large a b of length 5000 dec digits or more, this alg can be 2ce the speed (13 sec vs 26).
    ⍝ It is nominally faster at lengths around 75 digits.
    ⍝ Only for smaller a and b, the cost of 3 modulos instead of 1 predominates.
      modMul←{
          (a b)m←(⍺ ∆ ⍵)(∆ ⍺⍺)
          m _rem(m _rem a)_mul(m _rem b)
      }
    ⍝ modPow -- a (m modPow) n -- from article by Roger Hui Aug 2020  
    ∇ z←a(m modPow)n;s;mmM
      ⍝ m|a*n  ==>   a (m modPow) n  
      (a n)m←(a ∆ n)(∆ m)
      z←ONE_BI ⋄ s←m rem a
      mmM←m modMul 
      :While ZERO_BI lt n
          :If 1 eq 2 rem n ⋄ z←z mmM s ⋄ :EndIf    ⍝ z←m| z×s
          s←s mmM s                                ⍝ s←m| s×s
          n←n div 2
      :EndWhile
    ∇
    :EndSection BI Special Functions/Operations (More than 2 Args)
⍝ --------------------------------------------------------------------------------------------------

    :Section BI Unsigned Utility Math Routines
    ⍝ These are the workhorses of bigInt; most are from dfns:nats (handling unsigned bigInts).
    ⍝ Note: ⍺ and ⍵ are guaranteed by BII and BI to be vectors, but not
    ⍝       by internal functions or if called directly.
    ⍝       So tests for 2, 1, 0 (TWO_D etc) use ravel:  (TWO_D≡,⍺)

    ⍝ addU:   ⍺ + ⍵
      addU←{
          dlzRun ndn 0,+⌿⍺ mix ⍵    ⍝ We use dlzRun in case ⍺ or ⍵ have multiple leading 0s. If not, use ndnZ
      }
    ⍝ subU:  ⍺ - ⍵   Since unsigned, if ⍵>⍺, there are two options:
    ⍝        [1] Render as 0
    ⍝        [2] signal an error...
      subU←{
          <cmp ⍺ mix ⍵:Err eSUB                   ⍝ [opt 2] 3-5 →  -(5-3)
          dlzRun nup-⌿dck ⍺ mix ⍵                 ⍝ a≥w: 5-3 → +(5-3). ⍺<⍵: 0 [opt 1]
      }
    ⍝ mulU:  multiply ⍺ × ⍵  for unsigned Big Integer (BigIntU) ⍺ and ⍵
    ⍝ r:BIint ← ⍺:BIint ∇ ⍵:BIint
    ⍝ This is dfns:nats mul.
    ⍝ It is faster than dfns:xtimes (FFT-based algorithm)
    ⍝ even for larger numbers (up to xtimes smallish design limit)
    ⍝ We call ndnZ to remove extra zeros, esp. so zero is exactly ,0 and 1 is ,1.
      mulU←{
          dlzRun ⍺{                               ⍝ product.
              ndnZ 0,↑⍵{                          ⍝ canonicalised vector.
                  digit take←⍺                    ⍝ next digit and shift.
                  +⌿⍵ mix digit×take↑⍺⍺           ⍝ accumulated product.
              }/(⍺,¨(≢⍵)+⌽⍳≢⍺),⊂,0                ⍝ digit-shift pairs.
          }{                                      ⍝ guard against overflow:
              m n←,↑≢¨⍺ ⍵                         ⍝ numbers of hands (RX10-digits) in each arg.
              m>n:⍺ ∇⍨⍵                           ⍝ quicker if larger number on right.
              n<OFL:⍺ ⍺⍺ ⍵                        ⍝ ⍵ won't overflow: proceed.
              s←⌊n÷2                              ⍝ digit-split for large ⍵.
              p q←⍺∘∇¨(s↑⍵)(s↓⍵)                  ⍝ sub-products (see notes).
              ndnZ 0,+⌿(p,s↓n⍴0)mix q             ⍝ sum of sub-products.
          }⍵
      }
   ⍝ powU: compute ⍺*⍵ for unsigned ⍺ and ⍵. (⍺ may not be omitted).
   ⍝       Note: ⍺ and ⍵ must be vectors!!!
   ⍝ RX10div2: (Defined above.)
      powU←{powCase←(,⍵)∘≡
        ⍝ (1≠⍴⍴⍵)∨1≠⍴⍴⍺:  Err 'powU: ⍺ and ⍵ must be vectors'
          powCase ZERO_D:ONE_D                     ⍝ =cmp ⍵ mix,0:,1 ⍝ ⍺*0 → 1
          powCase ONE_D:,⍺                         ⍝ =cmp ⍵ mix,1:⍺  ⍝ ⍺*1 → ⍺. Return "odd," i.e. use sa in caller.
          powCase TWO_D:⍺ mulU ⍺                   ⍝ ⍺×⍺
          hlf←{,ndn(⌊⍵÷2)+0,¯1↓RX10div2×2|⍵}       ⍝ quick ⌊⍵÷2.
          evn←ndnZ{⍵ mulU ⍵}ndn ⍺ ∇ hlf ⍵          ⍝ even power
          0=2|¯1↑⍵:evn ⋄ ndnZ ⍺ mulU evn           ⍝ even or odd power.
      }
   ⍝ divU/: unsigned division
   ⍝  divU:   Removes leading 0s from ⍺, ⍵ ...
   ⍝    Optimizations for ⍵÷⍵ handled here, as well as ⍵÷0, where ⍵≠0.
   ⍝ Returns:  (int. quotient) (remainder)
   ⍝           (⌊ua ÷ uw)      (ua | uw)
   ⍝   r:BIint[2] ← ⍺:BIint ∇ ⍵:BIint
      divU←{
          a w←dlzRun¨⍺ ⍵
          a≡w:  ONE_D ZERO_D                  ⍝ ⍺÷⍵ => (,1)(,0), including 0÷0.
          ZERO_D≡w: 1÷0                       ⍝ ⍺÷⍵ => ERROR!, for all other ⍺÷0.
          svec←(≢w)+⍳0⌈1+(≢a)-≢w              ⍝ shift vector.
          dlzRun¨↑w{                          ⍝ fold along dividend.
              r p←⍵                           ⍝ result & dividend.
              q←⍺↑⍺⍺                          ⍝ shifted divisor.
              ppqq←RX10⊥⍉2 2↑p mix q          ⍝ 2 most signif. digits of p & q.
              r∆←p q{                         ⍝ next RX10-digit of result.
                  (p q)(lo hi)←⍺ ⍵            ⍝ div and high-low test.
                  lo=hi-1:p{                  ⍝ convergence:
                      (≥cmp ⍺ mix ⍵)⊃lo hi    ⍝ low or high.
                  }dLZ ndn 0,hi×q             ⍝ multiple.
                  mid←⌊0.5×lo+hi              ⍝ mid-point.
                  nxt←dLZ ndn 0,q×mid         ⍝ next multiplier.
                  gt←>cmp p mix nxt           ⍝ greater than:
                  ⍺ ∇ gt⊃2,/lo mid hi         ⍝ choose upper or lower interval.
              }⌊0 1+↑÷/ppqq+(0 1)(1 0)        ⍝ lower and upper bounds of ratio.
              mpl←dLZ ndn 0,q×r∆              ⍝ multiple.
              p∆←dLZ nup-⌿p mix mpl           ⍝ remainder.
              (r,r∆)p∆                        ⍝ result & remainder.
          }/svec,⊂⍬ a                         ⍝ fold-accumulated result.
      }
    quotientU←⊃divU
    gcdU←{ZERO_D≡,⍵:⍺ ⋄ ⍵ ∇⊃⌽⍺ divU ⍵}        ⍝ greatest common divisor.
    lcmU←{⍺ mulU⊃⍵ divU ⍺ gcdU ⍵}             ⍝ least common multiple.
      remU←{                                  ⍝ BigIntU remainder. ⍺ and ⍵ should be vectors only.
          TWO_D≡,⍺:2|⊃⌽⍵                      ⍝ fast (short-circuit) path for modulo 2
          <cmp ⍵ mix ⍺:⍵                      ⍝ ⍵ < ⍺? remainder is ⍵
          ⊃⌽⍵ divU ⍺                          ⍝ Otherwise, do full divide
      }
    :Endsection BI Unsigned Utility Math Routines
⍝ --------------------------------------------------------------------------------------------------

    :Section Service Routines
 ⍝  Prettify: Add underscores every 5 digits; ⍺=0 (default): replace ¯ by - .
    Prettify←  {0:: ⍵ ⋄ ⍺←0 ⋄ n← '(\d)(?=(\d{5})+$)' ⎕R '\1_'⊣⍵  ⋄  ⍺=0: n ⋄ '-'@('¯'∘=) n}
  ⍝ ExportApl:    Convert valid bigint ⍵ to APL, with error if exponent too large.
    ExportApl←{ 0:: Err eBADRANGE ⋄  ⍎Export ∆ ⍵}

    ⍝ ∆dlzNorm ⍵:BIint  If ⊃⌽⍵ is zero after removing leading 0's,
    ⍝                   return canonical 0 (0 (,0)).
    ⍝                   Otherwise return ⍵ w/o leading zeroes.
    ⍝ ∆normFromSign ⍵:BIint  If ⊃⌽⍵ is zero, ensure sign is 0. Otherwise, pass ⍵ as is.
    ∆dlzNorm←{ZERO_D≡w←dlzRun⊃⌽⍵: ZERO_BI ⋄ (⊃⍵) w}
    ∆normFromSign←{ZERO_D≡⊃⌽⍵:ZERO_BI ⋄ ⍵}
  ⍝ These routines operate on unsigned BIu data unless documented… (Mostly from dfn utilities)
    dLZ←{(0=⊃⍵)↓⍵}                          ⍝ drop FIRST leading zero.
    dlzRun←{0≠≢v←(∨\⍵≠0)/⍵:v ⋄ ,0}          ⍝ drop RUN of leading zeros, but [PMS] make sure at least one 0
    chkZ←{0≠≢⍵:,⍵ ⋄ ,0}                     ⍝ ⍬ → ,0. Ensure canonical Bii, so even 0 has one digit (,0).

    ndn←{ +⌿1 0⌽0 RX10⊤⍵}⍣≡                 ⍝ normalise down: 3 21 → 5 1 (RH).
    ndnZ←dLZ ndn                            ⍝ ndn, then remove (earlier added) leading zero, if still 0.
    nup←{⍵++⌿0 1⌽RX10 ¯1∘.×⍵<0}⍣≡           ⍝ normalise up:   3 ¯1 → 2 9
    nupZ←dLZ nup                            ⍝ PMS

    mix←{↑(-(≢⍺)⌈≢⍵)↑¨⍺ ⍵}                  ⍝ right-aligned mix.
    dck←{(2 1+(≥cmp ⍵)⌽0 ¯1)⌿⍵}             ⍝ difference check.
    rep←{10⊥⍵{⍉⍵⍴(-×/⍵)↑⍺}(⌈(≢⍵)÷NRX10),NRX10}  ⍝ radix RX10 rep of number.
    cmp←{⍺⍺/,(<\≠⌿⍵)/⍵}                     ⍝ compare first different digit of ⍺ and ⍵.


    :Endsection Service Routines
⍝ --------------------------------------------------------------------------------------------------
    :Endsection Big Integers

    :Section Utilities: BI_LIB, BI_DC (desk calc), BIB, BIC
   ⍝ BI_LIB      - simple niladic fn, returns this bigint namespace #.BigInt
   ⍝           If ⎕PATH points to bigInt namespace, BI_LIB will be found without typing explicit path.
   ⍝ BI_DC   - desk calculator (self-documenting)
   ⍝ BIC     - Utility to compile code strings or functions with BI arithmetic

   ⍝¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⍝
   ⍝ Utilities…

  ⍝ BI_LIB:  Returns ⎕THIS namespace
    ⎕FX 'ns←BI_LIB' 'ns←⎕THIS'    ⍝ Appears in ⎕PATH, for use by user utilities...

  ⍝ ∆F-- ⎕R/⎕S Regex utility-- returns field #n or ''
    ∆F←{ ⍝ Returns Regex field ⍵N in ⎕R ⍵⍵ dfn. Format:  f2 f3←⍵ ∆F¨2 3
        ⍵=0:⍺.Match ⋄ ⍵≥≢⍺.Offsets:'' ⋄ ¯1=⍺.Offsets[⍵]:'' ⋄ ⍺.(Lengths[⍵]↑Offsets[⍵]↓Block)
    }
   ⍝¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⍝
    ∇ {r}←_LoadPats
      ;actBiCallNoQ;actBiCallQ;actKeep;actKeepParen;actQuoted;lD;lM;p2Fancy;p2Funs1;p2Funs2
      ;p2Ints;p2Plain;p2Vars;pAplInt;pCom;pFancy;pFunsBig;pFunsNoQ;pFunsQ;pFunsSmall;pIntExp
      ;pIntOnly;pLongInt;pNonBiCode;pQot;pVar;t1;t2;tD1;tDM;tM1;tMM;_Q;_E
   ⍝ fnRep pattern: Match 0 or more lines
   ⍝ between :BIX… :EndBI keywords or  ⍝:BI … ⍝:ENDBI keywords
   ⍝ Match   ⍝:BI \n <BI code> … ⍝:EndBI. No spaces between ⍝ and :BI (bad: ⍝ :BI).
   ⍝ \R: any linend.  \N: any char but linend
      pFnRep←'(?ix)   ^ \h* ⍝?:BI \b \R* $ (.*?)  \R \h* ⍝?:ENDBI \b \R* '
   ⍝ Field:    #1                              #2    #3
   ⍝ #1: :BII; #2: text in :BII scope;  #3: text :ENDBI
   ⍝¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⍝
   ⍝ actionFnRep: fnRep Action
      actionFnRep←{match←⍵ ∆F 1 ⋄ pBiCalls ⎕R actBiCalls⊣match}
   ⍝ fnRep options for ⎕R
      optsFnRep←('Mode' 'M')('EOL' 'LF')('NEOL' 1)('IC' 1)('UCP' 1)('DotAll' 1)
   ⍝ fnRep call - expects string vector(s) as from ⎕NR name
      matchFnRep←{pFnRep ⎕R actionFnRep⍠optsFnRep⊣⍵}
   ⍝¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⍝
   ⍝ BI (Big Integer) patterns
   ⍝ …p2: Pattern building blocks
      p2Vars←'\p{L}_∆⍙'
       ⍝ Decode list…Fns.
       ⍝ [0] are single char fns   '+-⌽?'      → [+\-⌽\?]
       ⍝ [1] are multiple char fns 'aaa' 'bbb' → ('aaa' | 'bbb') etc.
       ⋄ tD1 tDM←dyadFnsList
       ⋄ tM1 tMM←monadFnsList
       ⋄ t1←tD1{'[\-\?\*]'⎕R'\\\0'⊣∪⍺,⍵}tM1    ⍝ Escape expected length-1 special symbols
      _Q _E←⊂¨'\Q' '\E'
      t2←¯1↓∊(_Q,¨_E,⍨¨tDM,tMM),¨'|'
      p2Funs1←'(?:⍺⍺|⍵⍵)'                      ⍝ See pFunsSmall.
      p2Funs2←'(?:',t2,')|(?:[',t1,'])'        ⍝ See pFunsBig. Case is respected for MUL10, SQRT…
     
      ⍝ …P:  Patterns. Most have a field#1
      pCom←'(⍝.*?)$'                           ⍝ Keep comments as is
      pVar←'([',p2Vars,'][',p2Vars,'\d]*)'     ⍝ Keep variable names as is, except MUL10 and SQRT
      pQot←'((?:''[^'']*'')+)'                 ⍝ Keep quoted numbers as is and anything else quoted
      pFunsNoQ←'(',p2Funs1,'(?!\h*BII))'       ⍝ ⍺⍺, ⍵⍵ operands NOT quoted. → (⍺⍺ BII) (⍵⍵ BII)
      pFunsQ←'((?:',p2Funs2,')⍨?(?!\h*BII))'   ⍝ All fns: APL or named are quoted. Simpler/faster.
                                               ⍝ SQRT → ('SQRT'BII), + → ('+' BII), √ 100 → ('√' BI '100')
      pNonBiCode←'\(:(.*?):\)'                 ⍝ Anything in (: … :) treated as APL
     
      pIntExp←'([\-¯]?[\d.]+[eE]¯?\d+)'        ⍝ [-¯]4.4E55 will be padded out. Underscores invalid.
      pIntOnly←'([\-¯]?[\d_.]+)'               ⍝ Put other valid BII-format integers in quotes
   ⍝¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⍝
   ⍝ BII Actions
   ⍝ …AB: BII (Big Integer) action building-blocks
      actBiCallNoQ←'(\1',(⍕⎕THIS),'.BI)'       ⍝ See pFunsNoQ above
      actBiCallQ←'(''\1''',(⍕⎕THIS),'.BI)'     ⍝ See pFunsQ above
      actKeep actKeepParen actQuoted actBool←'\1' '(\1)' '''\1''' '⊥BI \1'
   ⍝ EXTERN pBiCalls:     Full BI (Big Integer) pattern
      pBiCalls←pCom pFunsQ pVar pQot pFunsNoQ pNonBiCode pIntExp pIntOnly
   ⍝ EXTERN actBiCalls:   BI (Big Integer) action
   ⍝ In this version, we quote all APL integers unless they have exponents...
   ⍝ WAS:
   ⍝   actBiCalls←actKeep actBiCallQ actKeep actKeep actBiCallNoQ actKeepParen actKeepParen actQuoted
   ⍝ NOW:
      actBiCalls←actKeep actBiCallQ actKeep actKeep actBiCallNoQ actKeepParen actKeepParen actKeep
   ⍝ EXTERN matchBiCalls: BI (Big Integer) matching calls…
      matchBiCalls←{⍺←1
          res←⊃⍣(1=≢res)⊣res←pBiCalls ⎕R actBiCalls⍠('UCP' 1)⊣⊆⍵
          ⍺=1:res
          prefix←'\Q','.\E',⍨⍕⎕THIS   ⍝ remove the prefixes!
          prefix ⎕R' '⊣res
      }
      r←'OK'
    ∇
    _LoadPats


   ⍝¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯⍝
   ⍝H
   ⍝H BIC: Compile a function ⍵ with BII directives...
   ⍝H  opt=⍺ BIC command=⍵
   ⍝H
   ⍝H  opt DEFAULT  DESCRIPTION
   ⍝H  ¯¯¯
   ⍝H  0   YES      Compile and execute string ⍵ in CALLER space. Returns the value of execution
   ⍝H  1            Compile string ⍵ and return compiled string with BI utility fn names fully specified. Returns the string.
   ⍝H ¯1            Compile string ⍵ and return compiled string w/o BI namespace prefixes (for ease of viewing). Returns the string.
   ⍝H  2            Compile and ⎕FX function whose ⎕NR (code) is ⍵, containing :BI and :ENDBI statements as above. Returns result of ⎕FX
   ⍝H               To replace a fn <myfn>  in place with its BI counterpart:    2 BIC 'myfn'
   ⍝H  Examples:
   ⍝H         !50
   ⍝H 3.04140932E64
   ⍝H         BIC '!50'    ⍝ Same as: 0 BIC '!50'
   ⍝H 30414093201713378043612608166064768844377641568960512000000000000
   ⍝H        1 BIC '!50'   ⍝ To execute, do: ⍎1 BIC '!50' . Equiv to 0 BIC '!50'
   ⍝H ('!'⎕SE.⍙⍙.⍙.BigInt.BI)50
   ⍝H        2 BIC 'r←BigFact big'  ':bi'  'r←!big'  ':endbi'
   ⍝H BigFact
   ⍝H        ⎕CR 'BigFact'     
   ⍝H  ∇ r←BigFact big                                       
   ⍝H    r←('!'⎕SE.⍙⍙.⍙.BigInt.BI)big
   ⍝H  ∇

      BIC←{
          ⍺←0
          compileFixLines←{
              fx←((1+⎕IO)⊃⎕RSI,#).⎕FX matchFnRep ⍵
              0≠1↑0⍴fx:fx ⋄ 11 ⎕SIGNAL⍨'BIC: Unable to ⎕FX lines into fn'
          }
          DEBUG↓0::⎕SIGNAL/⎕DMX.(('bigInt: ',EM)EN)
          ⍺=0:((0+⎕IO)⊃⎕RSI,#)⍎matchBiCalls ⍵        ⍝  1      Compile and execute string ⍵ in CALLER space, returning value of execution
          ⍺=1:matchBiCalls ⍵                         ⍝  0      Compile string ⍵ and return compiled string
          ⍺=¯1:0 matchBiCalls ⍵                      ⍝ ¯1      Compile string ⍵ and return compiled string w/o BI namespace prefixes
          ⍺=2:compileFixLines ⍵                      ⍝ ¯2      Compile lines of function whose ⎕NR is ⍵, fixing (⎕FX) ⍵, and returning ⎕FX result
          Err eBIC
      }

    ∇ {ok}←BI_DC
      ;caller;code;lastResult;exprIn;exec;isShy;HelpInfo;help1Cmd;help2Cmd;offon;pretty;prettyCmd;verbose;verboseCmd
      ;⎕PW
     
      ⎕PW←132
    ⍝ extern:  BigInt.dc_HELP (help information)
      verbose pretty offon lastResult←0 1('OFF' 'ON')'0'
      help2Cmd help1Cmd verboseCmd prettyCmd←,¨'??' '?' '!' '⍕'
     
      HelpInfo←{
          ⎕←'BI_DC:       Big integer desk calculator.'
          ⎕←'In any expression you type:'
          ⎕←'             ⍵     refers to the most recent calculated value (or 0)'
          ⎕←'At the prompt only (followed by return ⏎):'
          ⎕←'             !     toggles VERBOSE mode; currently VERBOSE ',verbose⊃offon
          ⎕←'             ⍕     toggles PRETTY  mode; currently PRETTY  ',pretty⊃offon
          ⎕←'Need help?'
          ⎕←'             ?     shows this basic HELP information.'
          ⎕←'             ??    shows more detailed HELP information.'
          ⎕←'Finished?'
          ⎕←'             ⏎     entering a completely empty line (just a return char ⏎) terminates BI_DC mode'
          ⎕←'                   a non-empty line with only blanks is ignored.'
      }
      HelpInfo ⍬
     
      :While ok←1
          :Trap 1000
              exprIn←⍞↓⍨≢⍞←'> '
              :If 0=≢exprIn ⋄ :Return                     ⍝ Empty line:  Done
              :Else
                  :Select exprIn~' '
                  :Case '' ⍝ Blank line: ignore
                  :Case help1Cmd ⋄ HelpInfo ⍬
                  :Case help2Cmd ⋄ BI_HELP
                  :Case verboseCmd ⋄ verbose←~verbose ⋄ ⎕←'>>> VERBOSE ',verbose⊃offon
                  :Case prettyCmd ⋄ pretty←~pretty ⋄ ⎕←'>>> PRETTY ',pretty⊃offon
                  :Else ⋄ :GoTo IS_CODE     ⍝ Evil, but less bulky here!
                  :EndSelect
              :EndIf
              :Continue
     IS_CODE:
              :Trap 0
                  caller←(1+⎕IO)⊃⎕RSI,#
                  code←1 BIC exprIn
                  :If verbose ⋄ ⎕←'> ',code ⋄ :EndIf
                  exec←{⍵⍵:⍺⍎⍺⍺ ⋄ ⊢⎕←1∘Prettify⍣pretty⊣⍺⍎⍺⍺}               ⍝ ⍎ sees ⍵←lastResult
                  isShy←×≢('^\(?(\w+(\[[^]]*\])?)+\)?←'⎕S 1⍠'UCP' 1)⊣code~' ' ⍝ Kludge to see if code has an explicit result.
                  lastResult←caller(code exec isShy)lastResult
              :Else
                  :If ~verbose ⋄ ⎕←'> ',code ⋄ :EndIf
                  :Select ⎕EN
                  :Case 2
                      ⎕←'SYNTAX ERROR'
                  :Else
                      ⎕←{dm0 dm1 dm2←⍵.DM ⋄ p←1+dm1⍳']' ⋄ (p↑dm1)←' ' ⋄ ↑dm0 dm1(' ',dm2)}⎕DMX
                  :EndSelect
              :EndTrap
          :Else
              :If ~1∊'nN'∊⍞↓⍨≢⍞←'Interrupted. Exit? Y/N [Yes] '
                  :Return
              :EndIf
          :EndTrap
      :EndWhile
    ∇
    :Endsection Utilities: BI_LIB, BI_DC (desk calc), BIC

    :Section Bigint Namespace - Postamble
   _namelist_←'BI_LIB BI BII BIM BI_DC BIC BI_HELP' 
    ___←0 ⎕EXPORT ⎕NL 3 4
    ___←1 ⎕EXPORT {⍵[⍋↑⍵]}{⍵⊆⍨' '≠⍵}  _namelist_
    ⎕PATH←⎕THIS{0=≢⎕PATH:⍕⍺⊣⎕← '⎕PATH was "". Setting to "',(⍕⍺),'"'⋄ ⍵}⎕PATH
    ⎕EX '___'
    :EndSection Bigint Namespace - Postamble
:ENDNAMESPACE
