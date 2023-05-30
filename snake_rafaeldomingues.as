;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR                      EQU     0Ah
FIM_TEXTO               EQU     '@'
IO_READ                 EQU     FFFFh
IO_WRITE                EQU     FFFEh
IO_STATUS               EQU     FFFDh
INITIAL_SP              EQU     FDFFh
CURSOR		              EQU     FFFCh
CURSOR_INIT		          EQU		  FFFFh
INTERRUPTOR             EQU     FFF9h

GET_ROW                 EQU     ff00h
GET_COL                 EQU     00ffh
TRUE                    EQU     1d
FALSE                   EQU     0d
WIN_CONDITION           EQU     5d

ROW_POSITION	          EQU		  0d
COL_POSITION	          EQU		  0d
ROW_SHIFT		            EQU		  8d
COLUMN_SHIFT	          EQU		  8d

; Controle do Timer
TIMER_START             EQU     FFF7h ; Controla o timer, 0 para e 1 inicia
TIMER_INTERVAL          EQU     FFF6h ; Controla a quantidade de intervalos de 100ms
TIMER_MS                EQU     3d    ; Quantidade padrão de intervalos

MAX_ROWS                EQU     24d
MAX_COLS                EQU     80d

; Linhas ou Colunas das paredes
WALL_TOP                EQU     0100h
WALL_BOTTOM             EQU     1700h
WALL_RIGHT              EQU     004fh
WALL_LEFT               EQU     0000h

; Posições iniciais
SNAKE_INITIAL           EQU     0c28h

; Controles
UP                      EQU     0d
LEFT                    EQU     1d
DOWN                    EQU     2d
RIGHT                   EQU     3d

; Caracteres usados
SNAKE_HEAD              EQU     'X'
SNAKE_BODY              EQU     'o'
EMPTY_SPACE             EQU     ' '
FOOD                    EQU     '*'

; Padrao de bits para geracao de numero aleatorio
RND_MASK		            EQU     8016h	; 1000 0000 0001 0110b
LSB_MASK		            EQU	    0001h	; Mascara para testar o bit menos significativo do Random_Var

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
                        ORIG    8000h
Header                  STR     'PONTUACAO: 000                        SNAKE                                     ', FIM_TEXTO

Mapa1                   STR     '--------------------------------------------------------------------------------'
Mapa2                   STR     '-                                                                              -'
Mapa3                   STR     '-                                                                              -'
Mapa4                   STR     '-                                                                              -'
Mapa5                   STR     '-                                                                              -'
Mapa6                   STR     '-                                                                              -'
Mapa7                   STR     '-                                                                              -'
Mapa8                   STR     '-                                                                              -'
Mapa9                   STR     '-                                                                              -'
Mapa10                  STR     '-                                                                              -'
Mapa11                  STR     '-                                                                              -'
Mapa12                  STR     '-                                       X                                      -'
Mapa13                  STR     '-                                                                              -'
Mapa14                  STR     '-                                                                              -'
Mapa15                  STR     '-                                                                              -'
Mapa16                  STR     '-                                                                              -'
Mapa17                  STR     '-                                                                              -'
Mapa18                  STR     '-                                                                              -'
Mapa19                  STR     '-                                                                              -'
Mapa20                  STR     '-                                                                              -'
Mapa21                  STR     '-                                                                              -'
Mapa22                  STR     '-                                                                              -'
Mapa23                  STR     '--------------------------------------------------------------------------------', FIM_TEXTO

Lose1                    STR     '--------------------------------------------------------------------------------'
Lose2                    STR     '-                                                                              -'
Lose3                    STR     '-                                                                              -'
Lose4                    STR     '-     ______  ______  __    __  ______                                         -'
Lose5                    STR     '-    /\  ___\/\  __ \/\ "-./  \/\  ___\                                        -'
Lose6                    STR     '-    \ \ \__ \ \  __ \ \ \-./\ \ \  __\                                        -'
Lose7                    STR     '-     \ \_____\ \_\ \_\ \_\ \ \_\ \_____\                                      -'
Lose8                    STR     '-      \/_____/\/_/\/_/\/_/  \/_/\/_____/                                      -'
Lose9                    STR     '-                                                                              -'
Lose10                   STR     '-                                      ______  __   ________  ______           -'
Lose11                   STR     '-                                     /\  __ \/\ \ / /\  ___\/\  == \          -'
Lose12                   STR     '-                                     \ \ \/\ \ \ \ /\ \  __\\ \  __<          -'
Lose13                   STR     '-                                      \ \_____\ \__| \ \_____\ \_\ \_\        -'
Lose14                   STR     '-                                       \/_____/\/_/   \/_____/\/_/ /_/        -'
Lose15                   STR     '-                                                                              -'
Lose16                   STR     '-                                                                              -'
Lose17                   STR     '-                                                                              -'
Lose18                   STR     '-                                                                              -'
Lose19                   STR     '-                        PRESSIONE "C" PARA JOGAR NOVAMENTE                    -'
Lose20                   STR     '-                                                                              -'
Lose21                   STR     '-                                                                              -'
Lose22                   STR     '-                                                                              -'
Lose23                   STR     '--------------------------------------------------------------------------------', FIM_TEXTO

Win1                     STR     '--------------------------------------------------------------------------------'
Win2                     STR     '-                                                                              -'
Win3                     STR     '-                                                                              -'
Win4                     STR     '-                                                                              -'
Win5                     STR     '-                                                                              -'
Win6                     STR     '-                                                                              -'
Win7                     STR     '-           __  __  ______  __  __       __     __  __  __   __                -'
Win8                     STR     '-          /\ \_\ \/\  __ \/\ \/\ \     /\ \  _ \ \/\ \/\ "-.\ \               -'
Win9                     STR     '-          \ \____ \ \ \/\ \ \ \_\ \    \ \ \/ ".\ \ \ \ \ \-.  \              -'
Win10                    STR     '-           \/\_____\ \_____\ \_____\    \ \__/".~\_\ \_\ \_\\"\_\             -'
Win11                    STR     '-            \/_____/\/_____/\/_____/     \/_/   \/_/\/_/\/_/ \/_/             -'
Win12                    STR     '-                                                                              -'
Win13                    STR     '-                                                                              -'
Win14                    STR     '-                                                                              -'
Win15                    STR     '-                                                                              -'
Win16                    STR     '-                                                                              -'
Win17                    STR     '-                                                                              -'
Win18                    STR     '-                                                                              -'
Win19                    STR     '-                        PRESSIONE "C" PARA JOGAR NOVAMENTE                    -'
Win20                    STR     '-                                                                              -'
Win21                    STR     '-                                                                              -'
Win22                    STR     '-                                                                              -'
Win23                    STR     '--------------------------------------------------------------------------------', FIM_TEXTO

; Score (Centena, Dezena, Unidade)
Score                   WORD    0d
ScoreU                  WORD    '0'
ScoreD                  WORD    '0'
ScoreC                  WORD    '0'

; Posicao da comida
FoodPos                 WORD    0000h

; Posicao da lista
; Fazer uma lista de posições 2 a 2 com a linha e coluna das posições da cobra, a cada movimento deletar a ultima posição e mover todas as posições para sobreescrever
; Linha 12 (000ch), Coluna 40(0028h)
NextPos                 WORD    0000h
HeadAddress             WORD    A000h ; Endereço da cabeça (40960d)
TailAddress             WORD    A000h ; Endereço da cauda

; Parametros para rotinas
TextIndex	              WORD	  0d
Caracter                WORD    ' '
LastAction              WORD    0d
PosCursor               WORD    0000h
Random_Var	            WORD	  A5A5h  ; 1010 0101 1010 0101
GameOver                WORD    FALSE

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                        ORIG    FE00h
INT0                    WORD    PressUp
INT1                    WORD    PressLeft
INT2                    WORD    PressDown
INT3                    WORD    PressRight
INT4                    WORD    Restart

                        ORIG    FE0Fh
INT15                   WORD    RepeatAction ; 15 é reservado para o temporizador


;------------------------------------------------------------------------------
; Press: Interrupções para mudar a direção
;------------------------------------------------------------------------------
PressUp:                PUSH    R1

                        MOV     R1, M[ LastAction ]
                        CMP     R1, DOWN
                        JMP.Z   FimPressUp

                        MOV     R1, UP
                        MOV     M[ LastAction ], R1

FimPressUp:             POP     R1
                        RTI

;------------------------------------------------------------------------------
PressLeft:              PUSH    R1

                        MOV     R1, M[ LastAction ]
                        CMP     R1, RIGHT
                        JMP.Z   FimPressLeft

                        MOV     R1, LEFT
                        MOV     M[ LastAction ], R1

FimPressLeft:           POP     R1
                        RTI

;------------------------------------------------------------------------------
PressDown:              PUSH    R1

                        MOV     R1, M[ LastAction ]
                        CMP     R1, UP
                        JMP.Z   FimPressDown

                        MOV     R1, DOWN
                        MOV     M[ LastAction ], R1

FimPressDown:           POP     R1
                        RTI

;------------------------------------------------------------------------------
PressRight:             PUSH    R1

                        MOV     R1, M[ LastAction ]
                        CMP     R1, LEFT
                        JMP.Z   FimPressRight

                        MOV     R1, RIGHT
                        MOV     M[ LastAction ], R1

FimPressRight:          POP     R1
                        RTI


;------------------------------------------------------------------------------
; RepeatAction
;------------------------------------------------------------------------------
RepeatAction:           PUSH    R1
                        PUSH    R2
                        
                        MOV     R1, M[ HeadAddress ]
                        MOV     R1, M[ R1 ]
                        MOV     R2, M[ LastAction ]

                        CMP     R2, UP
                        JMP.Z   MoveUp

                        CMP     R2, DOWN
                        JMP.Z   MoveDown

                        CMP     R2, LEFT
                        JMP.Z   MoveLeft

                        CMP     R2, RIGHT
                        JMP.Z   MoveRight

MoveUp:                 SUB     R1, 0100h
                        MOV     M[ NextPos ], R1
                        JMP     EndRepeatAction

MoveDown:               ADD     R1, 0100h
                        MOV     M[ NextPos ], R1
                        JMP     EndRepeatAction

MoveLeft:               DEC     R1
                        MOV     M[ NextPos ], R1
                        JMP     EndRepeatAction

MoveRight:              INC     R1
                        MOV     M[ NextPos ], R1

EndRepeatAction:        CALL    Move
                        CALL    StartTimer

                        POP     R2
                        POP     R1
                        RTI

;------------------------------------------------------------------------------
; Restart
;------------------------------------------------------------------------------
Restart:                PUSH    R1
  
                        MOV     R1, TRUE
                        CMP     M[ GameOver ], R1
                        CALL.Z  StartGame

                        POP     R1
                        RTI

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                        ORIG    0000h
                        JMP     Main

;------------------------------------------------------------------------------
; StartTimer: Inicializa o temporizador
;------------------------------------------------------------------------------
StartTimer:             PUSH    R1

                        MOV     R1, TRUE
                        CMP     M[ GameOver ], R1
                        JMP.Z   StartTimerEnd

                        MOV     R1, TIMER_MS
                        MOV     M[ TIMER_INTERVAL ], R1
                        MOV     R1, 1d
                        MOV     M[ TIMER_START ], R1

StartTimerEnd:          POP     R1
                        RET

;------------------------------------------------------------------------------
; Função: RandomV1 (versão 1)
;
; Random: Rotina que gera um valor aleatório - guardado em M[Random_Var]
; Entradas: M[Random_Var]
; Saidas:   M[Random_Var]
;------------------------------------------------------------------------------
RandomV1:	              PUSH	  R1

                        MOV	    R1, LSB_MASK
                        AND	    R1, M[ Random_Var ] ; R1 = bit menos significativo de M[Random_Var]
                        BR.Z	Rnd_Rotate
                        MOV	    R1, RND_MASK
                        XOR	    M[ Random_Var ], R1

Rnd_Rotate:	            ROR	    M[ Random_Var ], 1
                        POP	    R1
                        RET

;------------------------------------------------------------------------------
; ImprimeCaracter:
;               Parametros: M[ PosCursor ] - Posição Cursor
;                           M[ Caracter ] - caratere a ser imprimido
;------------------------------------------------------------------------------
ImprimeCaracter:        PUSH    R1

                        MOV     R1, M[ PosCursor ]
                        MOV     M[ CURSOR ], R1
                        MOV     R1, M[ Caracter ]
                        MOV     M[ IO_WRITE ], R1

                        POP     R1
                        RET

;------------------------------------------------------------------------------
; ImprimeTela
;           Parametros: M[ TextIndex ] - Posição inicial do texto
;------------------------------------------------------------------------------
ImprimeTela:            PUSH    R1
                        PUSH    R2
                        PUSH    R3 ; Controla linha
                        PUSH    R4 ; Controla coluna

                        MOV     R3, 1d
                        MOV     R4, 0d

LoopImprimeTela:        CMP     R3, MAX_ROWS
                        JMP.Z   FimImprimeTela

                        MOV		  R1, M[ TextIndex ]
                        MOV		  R1, M[ R1 ]
                        CMP 	  R1, FIM_TEXTO
                        JMP.Z	  FimImprimeTela

                        MOV     R2, R3
                        SHL     R2, ROW_SHIFT
                        OR      R2, R4
                        MOV		  M[ PosCursor ], R2
                        MOV     M[ Caracter ], R1
                        CALL    ImprimeCaracter

                        INC		  M[ TextIndex ] ; Muda de caracter
                        INC		  R4 ; Muda de coluna
                        CMP     R4, MAX_COLS
                        JMP.Z   MudaLinha

                        JMP     LoopImprimeTela

MudaLinha:              INC     R3
                        MOV     R4, 0d
                        JMP     LoopImprimeTela

FimImprimeTela:         POP     R4
                        POP     R3
                        POP     R2
                        POP     R1
                        RET

;------------------------------------------------------------------------------
; ImprimeHeader
;           Parametros: M[ TextIndex ] - Posição inicial do texto
;------------------------------------------------------------------------------
ImprimeHeader:          PUSH    R1
                        PUSH    R2
                        PUSH    R3 ; Controla linha
                        PUSH    R4 ; Controla coluna

                        MOV     R3, 0d
                        MOV     R4, 0d

ImprimeHeaderLoop:      CMP     R4, MAX_COLS
                        JMP.Z   FimImprimeHeader
                        
                        MOV		  R1, M[ TextIndex ]
                        MOV		  R1, M[ R1 ]
                        CMP 	  R1, FIM_TEXTO
                        JMP.Z	  FimImprimeHeader

                        MOV     R2, R3
                        SHL     R2, ROW_SHIFT
                        OR      R2, R4
                        MOV		  M[ PosCursor ], R2
                        MOV     M[ Caracter ], R1
                        CALL    ImprimeCaracter

                        INC		  M[ TextIndex ] ; Muda de caracter
                        INC		  R4 ; Muda de coluna

                        JMP     ImprimeHeaderLoop

FimImprimeHeader:       POP     R4
                        POP     R3
                        POP     R2
                        POP     R1
                        RET

;------------------------------------------------------------------------------
;   Fim de Jogo - Derrota
;------------------------------------------------------------------------------
EndGame:                PUSH    R1

                        MOV     R1, TRUE
                        MOV     M[ GameOver ], R1

                        MOV     R1, Lose1
                        MOV		  M[ TextIndex ], R1
                        CALL    ImprimeTela

Fim_EndGame:            POP     R1
                        RET

;------------------------------------------------------------------------------
;   Fim de Jogo - Vitoria
;------------------------------------------------------------------------------
WinGame:                PUSH    R1

                        MOV     R1, TRUE
                        MOV     M[ GameOver ], R1

                        MOV     R1, Win1
                        MOV		  M[ TextIndex ], R1
                        CALL    ImprimeTela

Fim_WinGame:            POP     R1
                        RET

;------------------------------------------------------------------------------
;   Move: Rotina para mover a cobra em uma direção
;                   Parametros: M[ NextPos ] - Proxima posicao desejada
;------------------------------------------------------------------------------
Move:                   PUSH    R1
                        PUSH    R2
                        PUSH    R3
                        
                        ; Verifica se a proxima posição é uma das paredes
                        MOV     R1, M[ NextPos ]

                        MOV     R2, R1
                        AND     R2, GET_ROW
                        CMP     R2, WALL_TOP
                        CALL.Z  EndGame
                        JMP.Z   EndMove

                        MOV     R2, R1
                        AND     R2, GET_ROW
                        CMP     R2, WALL_BOTTOM
                        CALL.Z  EndGame
                        JMP.Z   EndMove

                        MOV     R2, R1
                        AND     R2, GET_COL
                        CMP     R2, WALL_LEFT
                        CALL.Z  EndGame
                        JMP.Z   EndMove

                        MOV     R2, R1
                        AND     R2, GET_COL
                        CMP     R2, WALL_RIGHT
                        CALL.Z  EndGame
                        JMP.Z   EndMove

                        ; Verifica se a proxima posição é uma comida
                        MOV     R1, M[ NextPos ]
                        MOV     R2, M[ FoodPos ]
                        CMP     R1, R2
                        CALL.Z  EatFood
                        CMP     R1, R2
                        JMP.Z   EndMove

                        ; Verifica se a proxima posição é o proprio corpo
                        MOV     R1, M[ NextPos ]
                        MOV     R2, M[ TailAddress ]
BodyColisionLoop:       CMP     R2, M[ HeadAddress ]
                        JMP.Z   EndBodyColisionLoop

                        CMP     R1, M[ R2 ]
                        CALL.Z  EndGame
                        JMP.Z   EndMove

                        DEC     R2
                        JMP     BodyColisionLoop

                        ; Substitui ultima posição da cobra por um caracter em branco
EndBodyColisionLoop:    MOV     R2, M[ TailAddress ]
                        MOV     R2, M[ R2 ]
                        MOV     R3, EMPTY_SPACE
                        MOV     M[ Caracter ], R3
                        MOV     M[ PosCursor ], R2
                        CALL    ImprimeCaracter

                        ; Anda todo corpo 1 posição
                        MOV     R2, M[ TailAddress ]
MoveLoop:               CMP     R2, M[ HeadAddress ]
                        JMP.Z   EndMoveLoop

                        MOV     R3, R2
                        DEC     R3
                        MOV     R3, M[ R3 ]
                        MOV     M[ R2 ], R3

                        MOV     R1, SNAKE_BODY
                        MOV     M[ Caracter ], R1
                        MOV     M[ PosCursor ], R3
                        CALL    ImprimeCaracter

                        DEC     R2
                        JMP     MoveLoop

                        ; Imprime cabeça da cobra na nova posição 
EndMoveLoop:            MOV     R2, M[ HeadAddress ]
                        MOV     R1, M[ NextPos ]
                        MOV     M[ R2 ], R1
                        
                        MOV     R3, SNAKE_HEAD
                        MOV     M[ Caracter ], R3
                        MOV     M[ PosCursor ], R1
                        CALL    ImprimeCaracter

EndMove:                POP     R3
                        POP     R2
                        POP     R1
                        RET

;------------------------------------------------------------------------------
;   Função EatFood
;------------------------------------------------------------------------------
EatFood:                PUSH    R1
                        PUSH    R2
                        PUSH    R3
                        PUSH    R4

                        ; Aumenta lista em uma posição
                        INC     M[ TailAddress ]
                        MOV     R1, M[ TailAddress ]

                        ; Move todo conteudo da lista para endereço a direita
EatFoodLoop:            CMP     R1, M[ HeadAddress ]
                        JMP.Z   FimEatFoodLoop

                        MOV     R4, R1
                        DEC     R1
                        MOV     R3, M[ R1 ]
                        MOV     M[ R4 ], R3

                        MOV     R2, SNAKE_BODY
                        MOV     M[ Caracter ], R2
                        MOV     M[ PosCursor ], R3
                        CALL    ImprimeCaracter

                        JMP     EatFoodLoop

                        ; Imprime cabeça da cobra na nova posição 
FimEatFoodLoop:         MOV     R2, M[ HeadAddress ]
                        MOV     R1, M[ NextPos ]
                        MOV     M[ R2 ], R1
                        
                        MOV     R3, SNAKE_HEAD
                        MOV     M[ Caracter ], R3
                        MOV     M[ PosCursor ], R1
                        CALL    ImprimeCaracter

                        CALL    UpdateScore

                        MOV     R1, FALSE
                        CMP     M[ GameOver ], R1
                        CALL.Z  SpawnFood
                
End_EatFood:            POP     R4
                        POP     R3
                        POP     R2
                        POP     R1
                        RET

;------------------------------------------------------------------------------
;   Função UpdateScore
;------------------------------------------------------------------------------
UpdateScore:            PUSH    R1

                        INC     M[ Score ]
                        
                        MOV     R1, M[ ScoreU ]
                        CMP     R1, '9'
                        JMP.Z   ChangeDecimal

                        INC     M[ ScoreU ]
                        JMP     PrintScore

ChangeDecimal:          MOV     R1, '0'
                        MOV     M[ ScoreU ], R1
                        MOV     R1, M[ ScoreD ]
                        CMP     R1, '9'
                        JMP.Z   ChangeCentesimal

                        INC     M[ ScoreD ]
                        JMP     PrintScore

ChangeCentesimal:       MOV     R1, '0'
                        MOV     M[ ScoreD ], R1
                        INC     M[ ScoreC ]

PrintScore:             MOV     R1, 0d
                        SHL     R1, ROW_SHIFT
                        OR      R1, 13d
                        MOV     M[ PosCursor ], R1
                        MOV     R1, M[ ScoreU ]
                        MOV     M[ Caracter ], R1
                        CALL    ImprimeCaracter

                        MOV     R1, 0d
                        SHL     R1, ROW_SHIFT
                        OR      R1, 12d
                        MOV     M[ PosCursor ], R1
                        MOV     R1, M[ ScoreD ]
                        MOV     M[ Caracter ], R1
                        CALL    ImprimeCaracter

                        MOV     R1, 0d
                        SHL     R1, ROW_SHIFT
                        OR      R1, 11d
                        MOV     M[ PosCursor ], R1
                        MOV     R1, M[ ScoreC ]
                        MOV     M[ Caracter ], R1
                        CALL    ImprimeCaracter

                        MOV     R1, M[ Score ]
                        CMP     R1, WIN_CONDITION
                        CALL.Z  WinGame

                        POP     R1
                        RET

;------------------------------------------------------------------------------
;   Função SpawnFood
;------------------------------------------------------------------------------
SpawnFood:              PUSH    R1
                        PUSH    R2 ; FoodRow
                        PUSH    R3 ; FoodCol

                        ; Gera FoodRow
GenerateFood:           CALL    RandomV1
                        MOV     R1, M[ Random_Var ]
                        MOV     R2, MAX_ROWS
                        DEC     R2
                        DIV     R1, R2
                        ADD     R2, 2d

                        ; Gera FoodCol
                        CALL    RandomV1
                        MOV     R1, M[ Random_Var ]
                        MOV     R3, MAX_COLS
                        DEC     R3
                        DIV     R1, R3
                        ADD     R3, 1d

                        SHL     R2, ROW_SHIFT
                        OR      R2, R3

                        ; Verifica se a comida não vai spawnar na mesma posição da cobra
                        MOV     R1, M[ TailAddress ]
FoodPosLoop:            CMP     R1, M[ HeadAddress ]
                        JMP.Z   EndFoodPosLoop

                        MOV     R3, M[ R1 ]
                        CMP     R3, R2
                        JMP.Z   GenerateFood

                        DEC     R1
                        JMP     FoodPosLoop

EndFoodPosLoop:         MOV     M[ FoodPos ], R2
                        MOV     M[ PosCursor ], R2
                        MOV     R1, FOOD
                        MOV     M[ Caracter ], R1
                        CALL    ImprimeCaracter

                        POP     R3
                        POP     R2
                        POP     R1
                        RET

;------------------------------------------------------------------------------
; StartGame: Inicializa as variaveis do jogo (cobra, fruta, pontuação)
;------------------------------------------------------------------------------
StartGame:              PUSH    R1
                        PUSH    R2

                        MOV     R1, M[ HeadAddress ]
                        MOV     M[TailAddress], R1 ; Zera tamanho da cobra

                        MOV     R1, SNAKE_INITIAL
                        MOV     R2, M[ HeadAddress ]
                        MOV     M[ R2 ], R1 ; Guarda posicao inicial da cobra no inicio da lista

                        MOV     R1, FALSE
                        MOV     M[ GameOver ], R1 ; Define GameOver como falso

                        MOV     R1, 0d
                        MOV     M[ Score ], R1
                        MOV     R1, '0'
                        MOV     M[ ScoreU ], R1
                        MOV     M[ ScoreD ], R1
                        MOV     M[ ScoreC ], R1 ; Zera scoreboard

                        MOV     R1, UP
                        MOV     M[ LastAction ], R1 ; Define Primeira ação como UP

                        MOV     R1, Header
                        MOV		  M[ TextIndex ], R1
                        CALL    ImprimeHeader

                        MOV     R1, Mapa1
                        MOV		  M[ TextIndex ], R1
                        CALL    ImprimeTela

                        CALL    SpawnFood
                        CALL    StartTimer

                        POP     R2
                        POP     R1
                        RET

;------------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------
Main:			              ENI

                        MOV		  R1, INITIAL_SP
                        MOV		  SP, R1		 		; We need to initialize the stack
                        MOV		  R1, CURSOR_INIT		; We need to initialize the cursor 
                        MOV		  M[ CURSOR ], R1		; with value CURSOR_INIT
                        
                        CALL    StartGame

Cycle: 			            BR		Cycle	
Halt:                   BR		Halt