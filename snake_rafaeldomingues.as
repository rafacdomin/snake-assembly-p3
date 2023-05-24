;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
PULA_LINHA      EQU     '#'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
INTERRUPTOR     EQU     FFF9h
WIN_CONDITION   EQU     10d

ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d

; Controle do Timer
TIMER_START     EQU     FFF7h ; Controla o timer, 0 para e 1 inicia
TIMER_INTERVAL  EQU     FFF6h ; Controla a quantidade de intervalos de 100ms
TIMER_MS        EQU     3d    ; Quantidade padrão de intervalos

MAX_ROWS        EQU     24d
MAX_COLS        EQU     80d

; Linhas ou Colunas das paredes
WALL_TOP        EQU     0100h
WALL_BOTTOM     EQU     1700h
WALL_RIGHT      EQU     0079h
WALL_LEFT       EQU     0000h

; Controles
UP              EQU     0d
LEFT            EQU     1d
DOWN            EQU     2d
RIGHT           EQU     3d

; Caracteres usados
SNAKE_HEAD      EQU     'X'
EMPTY_SPACE     EQU     ' '
FOOD            EQU     'o'

; Padrao de bits para geracao de numero aleatorio
RND_MASK		EQU     8016h	; 1000 0000 0001 0110b
LSB_MASK		EQU	    0001h	; Mascara para testar o bit menos significativo do Random_Var

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
                ORIG    8000h
Mapa0        STR     'PONTUACAO: 000                        SNAKE                                     '
Mapa1        STR     '--------------------------------------------------------------------------------'
Mapa2        STR     '-                                                                              -'
Mapa3        STR     '-                                                                              -'
Mapa4        STR     '-                                                                              -'
Mapa5        STR     '-                                                                              -'
Mapa6        STR     '-                                                                              -'
Mapa7        STR     '-                                       o                                      -'
Mapa8        STR     '-                                                                              -'
Mapa9        STR     '-                                                                              -'
Mapa10       STR     '-                                                                              -'
Mapa11       STR     '-                                                                              -'
Mapa12       STR     '-                                       X                                      -'
Mapa13       STR     '-                                                                              -'
Mapa14       STR     '-                                                                              -'
Mapa15       STR     '-                                                                              -'
Mapa16       STR     '-                                                                              -'
Mapa17       STR     '-                                                                              -'
Mapa18       STR     '-                                                                              -'
Mapa19       STR     '-                                                                              -'
Mapa20       STR     '-                                                                              -'
Mapa21       STR     '-                                                                              -'
Mapa22       STR     '-                                                                              -'
Mapa23       STR     '--------------------------------------------------------------------------------', FIM_TEXTO

FimTexto0       STR     'FIM DE JOGO', PULA_LINHA
FimTexto1       STR     'VOCE PERDEU!', FIM_TEXTO
WinTexto        STR     'PARABENS, VOCE GANHOU!', FIM_TEXTO

; Score (Centena, Dezena, Unidade)
Score           WORD    0d
ScoreU          WORD    '0'
ScoreD          WORD    '0'
ScoreC          WORD    '0'

; Posicao inicial comida
FoodRow         WORD    7d
FoodCol         WORD    40d

; Posicao da lista
; Fazer uma lista de posições 2 a 2 com a linha e coluna das posições da cobra, a cada movimento deletar a ultima posição e mover todas as posições para sobreescrever
; Linha 12 (000ch), Coluna 40(0028h)
InitialPos      WORD    0c28h
HeadAddress     WORD    9000h ; Endereço da cabeça (36864d)
TailAddress     WORD    9000h ; Endereço da cauda

; Parametros para rotinas
TextIndex	    WORD	0d
Caracter        WORD    ' '
LastAction      WORD    0d
LinhaCursor     WORD    0d
ColunaCursor    WORD    0d
PosCursor       WORD    0000h
Random_Var	    WORD	A5A5h  ; 1010 0101 1010 0101

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    PressUp
INT1            WORD    PressLeft
INT2            WORD    PressDown
INT3            WORD    PressRight

                ORIG    FE0Fh
INT15           WORD    RepeatAction ; 15 é reservado para o temporizador

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
;   Fim de Jogo - Derrota
;------------------------------------------------------------------------------
EndGame:        PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R2, 10d
                MOV     R3, 35d
                MOV     R1, FimTexto0
                MOV     M[ TextIndex ], R1            

Loop_EndGame:   MOV		R1, M[ TextIndex ]
				MOV		R1, M[ R1 ]
				CMP 	R1, FIM_TEXTO
				JMP.Z	Fim_EndGame

                MOV		R1, M[ TextIndex ]
				MOV		R1, M[ R1 ]
				CMP 	R1, PULA_LINHA
				JMP.Z	Linha_EndGame

                MOV     M[ Caracter ], R1
                MOV     M[ LinhaCursor ], R2
                MOV     M[ ColunaCursor ], R3
                CALL    ImprimeCaracter

                INC     M[ TextIndex ]
                INC     R3
                JMP     Loop_EndGame

Linha_EndGame:  INC     R2
                MOV     R3, 35d
                INC     M[ TextIndex ]
                JMP     Loop_EndGame

Fim_EndGame:    POP     R3
                POP     R2
                POP     R1
                CALL    Cycle

;------------------------------------------------------------------------------
;   Fim de Jogo - Vitoria
;------------------------------------------------------------------------------
WinGame:        PUSH    R1
                PUSH    R2
                PUSH    R3

                MOV     R2, 12d
                MOV     R3, 32d
                MOV     R1, WinTexto
                MOV     M[ TextIndex ], R1            

Loop_WinGame:   MOV		R1, M[ TextIndex ]
				MOV		R1, M[ R1 ]
				CMP 	R1, FIM_TEXTO
				JMP.Z	Fim_WinGame


                MOV     M[ Caracter ], R1
                MOV     M[ LinhaCursor ], R2
                MOV     M[ ColunaCursor ], R3
                CALL    ImprimeCaracter

                INC     M[TextIndex]
                INC     R3
                JMP     Loop_WinGame

Fim_WinGame:    POP     R3
                POP     R2
                POP     R1
                CALL    Cycle

;------------------------------------------------------------------------------
; ImprimeCaracterV2:
;               Parametros: M[ PosCursor ] - Posição Cursor
;                           M[ Caracter ] - caratere a ser imprimido
;------------------------------------------------------------------------------
ImprimeCaracterV2:  PUSH R1

                    MOV     R1, M[ PosCursor ]
                    MOV     M[ CURSOR ], R1
                    MOV     R1, M[ Caracter ]
                    MOV     M[ IO_WRITE ], R1

                    POP     R1
                    RET

;------------------------------------------------------------------------------
; ImprimeCaracter:
;               Parametros: M[ LinhaCursor ] - linha cursor
;                           M[ ColunaCursor ] - coluna cursor
;                           M[ Caracter ] - caratere a ser imprimido
;------------------------------------------------------------------------------
ImprimeCaracter:    PUSH R1
                    PUSH R2

                    MOV     R1, M[ LinhaCursor ]
                    MOV     R2, M[ ColunaCursor ]
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1
                    MOV     R1, M[ Caracter ]
                    MOV     M[ IO_WRITE ], R1

                    POP     R2
                    POP     R1
                    RET

;------------------------------------------------------------------------------
; ImprimeMapa
;           Parametros: M[ TextIndex ] - Posição inicial do texto
;------------------------------------------------------------------------------
ImprimeMapa:    PUSH    R1
                PUSH    R2
                PUSH    R3 ; Controla linha
                PUSH    R4 ; Controla coluna

                MOV     R3, 0d
                MOV     R4, 0d

Loop1:          CMP     R3, MAX_ROWS
                JMP.Z   FimImprimeMapa

                MOV		R1, M[ TextIndex ]
				MOV		R1, M[ R1 ]
				CMP 	R1, FIM_TEXTO
				JMP.Z	FimImprimeMapa

                MOV     M[ Caracter ], R1
                MOV		M[ LinhaCursor ], R3 ; Linha do cursor
				MOV		M[ ColunaCursor ], R4 ; Coluna do cursor
                CALL    ImprimeCaracter

				INC		M[ TextIndex ] ; Muda de caracter
                INC		R4 ; Muda de coluna
                CMP     R4, MAX_COLS
                JMP.Z   MudaLinha

                JMP     Loop1

MudaLinha:      INC     R3
                MOV     R4, 0d
                JMP     Loop1

FimImprimeMapa: POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
; Rotina de Interrupção MoveUp
;------------------------------------------------------------------------------
MoveUp:         PUSH    R1
                PUSH    R2
                PUSH    R3

                ; Verifica se a proxima posição é uma parede 
				MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
                SUB     R1, 0100h
				AND     R1, ff00h
				CMP     R1, WALL_TOP
				CALL.Z  EndGame

                ; Substitui posição da cobra por um caracter em branco
                MOV     R1, M[ TailAddress ]
                MOV     R1, M[ R1 ]
				MOV     R3, EMPTY_SPACE
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

                ; Anda 1 posição
                MOV     R2, M[ TailAddress ]

UpLoop:         CMP     R2, M[ HeadAddress ]
                JMP.Z   EndUpLoop

                MOV     R1, R2
                DEC     R1
                MOV     R1, M[ R1 ]
                MOV     M[ R2 ], R1

                DEC     R2

                JMP     UpLoop

                ; Imprime cobra na nova posição 
EndUpLoop:      MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
                SUB     R1, 0100h
                MOV     R2, M[ HeadAddress ]
                MOV     M[ R2 ], R1
				
                MOV     R3, SNAKE_HEAD
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

FimMoveUp:      POP     R3
				POP     R2
                POP     R1

				RET

;------------------------------------------------------------------------------
; Rotina de Interrupção MoveDown
;------------------------------------------------------------------------------
MoveDown:       PUSH    R1
                PUSH    R2
                PUSH    R3

                ; Verifica se a proxima posição é uma parede 
				MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
                ADD     R1, 0100h
				AND     R1, ff00h
				CMP     R1, WALL_BOTTOM
				CALL.Z  EndGame

                ; Substitui posição da cobra por um caracter em branco
                MOV     R1, M[ TailAddress ]
                MOV     R1, M[ R1 ]
				MOV     R3, EMPTY_SPACE
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

                ; Anda 1 posição
                MOV     R2, M[ TailAddress ]

DownLoop:       CMP     R2, M[ HeadAddress ]
                JMP.Z   EndDownLoop
                
                MOV     R1, R2
                DEC     R1
                MOV     R1, M[ R1 ]
                MOV     M[ R2 ], R1

                DEC     R2

                JMP     DownLoop


                ; Imprime cobra na nova posição 
EndDownLoop:    MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
                ADD     R1, 0100h
                MOV     R2, M[ HeadAddress ]
                MOV     M[ R2 ], R1
				
                MOV     R3, SNAKE_HEAD
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

FimMoveDown:    POP     R3
				POP     R2
                POP     R1

				RET

;------------------------------------------------------------------------------
; Rotina de Interrupção MoveLeft
;------------------------------------------------------------------------------
MoveLeft:       PUSH    R1
                PUSH    R2
                PUSH    R3

                ; Verifica se a proxima posição é uma parede 
				MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
				DEC     R1
                AND     R1, 00ffh
				CMP     R1, WALL_LEFT
				CALL.Z  EndGame

                ; Substitui a ultima posição da cobra por um caracter em branco
                MOV     R1, M[ TailAddress ]
                MOV     R1, M[ R1 ]
				MOV     R3, EMPTY_SPACE
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

                ; Anda 1 posição
                MOV     R2, M[ TailAddress ]

LeftLoop:       CMP     R2, M[ HeadAddress ]
                JMP.Z   EndLeftLoop
                
                MOV     R1, R2
                DEC     R1
                MOV     R1, M[ R1 ]
                MOV     M[ R2 ], R1

                DEC     R2

                JMP     LeftLoop

                ; Imprime a cabeça da cobra na nova posição
EndLeftLoop:    MOV     R2, M[ HeadAddress ] 
				DEC     M[ R2 ]
                MOV     R1, M[ R2 ]
				
                MOV     R3, SNAKE_HEAD
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

FimMoveLeft:    POP     R3
				POP     R2
                POP     R1

				RET

;------------------------------------------------------------------------------
; Rotina de Interrupção MoveRight
;------------------------------------------------------------------------------
MoveRight:      PUSH    R1
                PUSH    R2
                PUSH    R3

                ; Verifica se a proxima posição é uma parede 
				MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
				INC     R1
                AND     R1, 00ffh
				CMP     R1, WALL_RIGHT
				CALL.Z  EndGame

                ; Substitui posição da cobra por um caracter em branco
                MOV     R1, M[ TailAddress ]
                MOV     R1, M[ R1 ]
				MOV     R3, EMPTY_SPACE
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

                ; Anda 1 posição
                MOV     R2, M[ TailAddress ]

RightLoop:      CMP     R2, M[ HeadAddress ]
                JMP.Z   EndRightLoop
                
                MOV     R1, R2
                DEC     R1
                MOV     R1, M[ R1 ]
                MOV     M[ R2 ], R1

                DEC     R2

                JMP     RightLoop

                ; Imprime cobra na nova posição 
EndRightLoop:   MOV     R2, M[ HeadAddress ] 
				INC     M[ R2 ]
                MOV     R1, M[ R2 ]
				
                MOV     R3, SNAKE_HEAD
                MOV     M[ Caracter ], R3
                MOV     M[ PosCursor ], R1
                CALL    ImprimeCaracterV2

FimMoveRight:   POP     R3
				POP     R2
                POP     R1

				RET

;------------------------------------------------------------------------------
; StartTimer: Inicializa o temporizador
;------------------------------------------------------------------------------
StartTimer:     PUSH    R1

                MOV     R1, TIMER_MS
                MOV     M[ TIMER_INTERVAL ], R1
                MOV     R1, 1d
                MOV     M[ TIMER_START ], R1

                POP     R1
                RET

;------------------------------------------------------------------------------
; Press: Interrupções para mudar a direção
;------------------------------------------------------------------------------
PressUp:        PUSH    R1

                MOV     R1, M[ LastAction ]
                CMP     R1, DOWN
                JMP.Z   FimPressUp

                MOV     R1, UP
                MOV     M[ LastAction ], R1

FimPressUp:     POP     R1
                RTI


;------------------------------------------------------------------------------
PressLeft:      PUSH    R1

                MOV     R1, M[ LastAction ]
                CMP     R1, RIGHT
                JMP.Z   FimPressLeft

                MOV     R1, LEFT
                MOV     M[ LastAction ], R1

FimPressLeft:   POP     R1
                RTI


;------------------------------------------------------------------------------
PressDown:      PUSH    R1

                MOV     R1, M[ LastAction ]
                CMP     R1, UP
                JMP.Z   FimPressDown

                MOV     R1, DOWN
                MOV     M[ LastAction ], R1

FimPressDown:   POP     R1
                RTI


;------------------------------------------------------------------------------
PressRight:     PUSH    R1

                MOV     R1, M[ LastAction ]
                CMP     R1, LEFT
                JMP.Z   FimPressRight

                MOV     R1, RIGHT
                MOV     M[ LastAction ], R1

FimPressRight:  POP     R1
                RTI

;------------------------------------------------------------------------------
;   Função EatFood
;------------------------------------------------------------------------------
EatFood:        PUSH    R1
                PUSH    R2
                PUSH    R3
                PUSH    R4

                MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]

                MOV     R2, M[ FoodRow ]
                MOV     R3, M[ FoodCol ]
                SHL     R2, ROW_SHIFT
                OR      R2, R3

                CMP     R1, R2
                JMP.NZ  End_EatFood

                CALL    UpdateScore
                CALL    SpawnFood

                ; Aumenta lista em uma posição
                INC     M[ TailAddress ]
                MOV     R1, M[ TailAddress ]
                ; Move todo conteudo para a direita
EatFoodLoop:    CMP     R1, M[ HeadAddress ]
                JMP.Z   FimEatFoodLoop

                MOV     R4, R1
                DEC     R1
                MOV     R3, M[ R1 ]
                MOV     M[ R4 ], R3

                JMP     EatFoodLoop

                ; Adiciona posição da comida na cabeça da cobra
FimEatFoodLoop: MOV     R4, M[ HeadAddress ]
                MOV     R4, M[ R4 ]
                MOV     M[ R4 ], R2
                
End_EatFood:    POP     R4
                POP     R3
                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
; RepeatAction
;------------------------------------------------------------------------------
RepeatAction:   PUSH    R1

                MOV     R1, M[ LastAction ]
                CMP     R1, UP
                CALL.Z  MoveUp
                JMP.Z   FimRepeatAction

                CMP     R1, LEFT
                CALL.Z  MoveLeft
                JMP.Z   FimRepeatAction

                CMP     R1, DOWN
                CALL.Z  MoveDown
                JMP.Z   FimRepeatAction

                CMP     R1, RIGHT
                CALL.Z  MoveRight

FimRepeatAction:    CALL    EatFood
                    CALL    StartTimer
                    POP     R1
                    RTI

;------------------------------------------------------------------------------
; Função: RandomV1 (versão 1)
;
; Random: Rotina que gera um valor aleatório - guardado em M[Random_Var]
; Entradas: M[Random_Var]
; Saidas:   M[Random_Var]
;------------------------------------------------------------------------------

RandomV1:	PUSH	R1

			MOV	    R1, LSB_MASK
			AND	    R1, M[ Random_Var ] ; R1 = bit menos significativo de M[Random_Var]
			BR.Z	Rnd_Rotate
			MOV	    R1, RND_MASK
			XOR	    M[ Random_Var ], R1

Rnd_Rotate:	ROR	    M[ Random_Var ], 1
			POP	    R1
			RET


;------------------------------------------------------------------------------
;   Função UpdateScore
;------------------------------------------------------------------------------
UpdateScore:    PUSH    R1

                INC     M[ Score ]
                
                MOV     R1, M[ ScoreU ]
                CMP     R1, '9'
                JMP.Z   ChangeDecimal

                INC     M[ ScoreU ]
                JMP     PrintScore

ChangeDecimal:  MOV     R1, '0'
                MOV     M[ ScoreU ], R1
                MOV     R1, M[ ScoreD ]
                CMP     R1, '9'
                JMP.Z   ChangeCentesimal

                INC     M[ ScoreD ]
                JMP     PrintScore

ChangeCentesimal:   MOV     R1, '0'
                    MOV     M[ ScoreD ], R1
                    INC     M[ ScoreC ]

PrintScore:     MOV     R1, 0d
                MOV     M[ LinhaCursor ], R1
                MOV     R1, 13d
                MOV     M[ ColunaCursor ], R1
                MOV     R1, M[ ScoreU ]
                MOV     M[ Caracter ], R1
                CALL    ImprimeCaracter

                MOV     R1, 12d
                MOV     M[ ColunaCursor ], R1
                MOV     R1, M[ ScoreD ]
                MOV     M[ Caracter ], R1
                CALL    ImprimeCaracter

                MOV     R1, 11d
                MOV     M[ ColunaCursor ], R1
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
SpawnFood:      PUSH    R1
                PUSH    R2

GenerateFood:   CALL    RandomV1
                MOV     R1, M[ Random_Var ]
                MOV     R2, MAX_ROWS
                DEC     R2
                DIV     R1, R2
                ADD     R2, 2d
                MOV     M[ FoodRow ], R2

                CALL    RandomV1
                MOV     R1, M[ Random_Var ]
                MOV     R2, MAX_COLS
                DEC     R2
                DIV     R1, R2
                ADD     R2, 1d
                MOV     M[ FoodCol ], R2

                ; Verifica se a comida não vai spawnar na mesma posição da cobra
                MOV     R1, M[ HeadAddress ]
                MOV     R1, M[ R1 ]
                
                MOV     R2, M[ FoodRow ]
                MOV     R3, M[ FoodCol ]
                SHL     R2, ROW_SHIFT
                OR      R2, R3

                CMP     R1, R2
                JMP.Z   GenerateFood

                MOV     R1, M[ FoodRow ]
                MOV     M[ LinhaCursor ], R1
                MOV     R1, M[ FoodCol ]
                MOV     M[ ColunaCursor ], R1
                MOV     R1, FOOD
                MOV     M[ Caracter ], R1
                CALL    ImprimeCaracter

                POP     R2
                POP     R1
                RET

;------------------------------------------------------------------------------
; Função Main
;------------------------------------------------------------------------------
Main:			ENI

				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
				
                MOV     R1, Mapa0
				MOV		M[ TextIndex ], R1
                CALL    ImprimeMapa

                MOV     R1, M[ InitialPos ]
                MOV     R2, M[ HeadAddress ]
                MOV     M[ R2 ], R1 ; Guarda posicao inicial da cobra no inicio da lista

                CALL    StartTimer

Cycle: 			BR		Cycle	
Halt:           BR		Halt