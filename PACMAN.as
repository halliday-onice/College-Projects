;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    EQU     FFFCh
CURSOR_INIT		EQU		FFFFh
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d
MAX_COUNTER		EQU     41d
FIM_NIVEL       EQU     '!'
DIR_PARADO      EQU     0d
DIR_CIMA        EQU     1d
DIR_BAIXO       EQU     2d 
DIR_ESQ         EQU     3d
DIR_DIR         EQU     4d
PARADO          EQU     0d
MOVIMENTO       EQU     1d
Base_ASCII      EQU     48d
CEM             EQU     100d
DEZ             EQU     10d

;configuracoes do timer  
CONFIG_TIMER    EQU     FFF6h
ACTIVATE_TIMER  EQU     FFF7h
LIGA_TIMER      EQU    1d
DESLIG_TIMER    EQU    0d
INTERV_TIMER    EQU    4d

;configuracoes fantasma
RND_MASK        EQU    8016h; 1000 0000 0001 0110b
LSB_MASK        EQU    0001h; Mascara para testar o bit menos significativo do Random_Var
DIR_FANT_DIR    EQU    0d
DIR_FANT_ESQ    EQU    1d
DIR_FANT_CIMA   EQU    2d 
DIR_FANT_BAIXO  EQU    3d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

                ORIG    8000h
RowIndex		WORD	1d
ColumnIndex		WORD	2d
posindex 		WORD 	0d
recebemem   	WORD    0d
ColunaInicio    WORD    2d
						;01234567890123456
;mapa 
linha0			STR     '########################################',FIM_TEXTO
linha1	 		STR    	'#.......*..........##.............*....#',FIM_TEXTO
linha2          STR    	'#....#####................#####........#',FIM_TEXTO
linha3          STR     '#............###.....##..............###',FIM_TEXTO
linha4          STR     '#......##....###.....##.....##.......###',FIM_TEXTO
linha5          STR     '#......##...................##.........#',FIM_TEXTO
linha6          STR     '#....................................###',FIM_TEXTO
linha7          STR     '#.................######..........*....#',FIM_TEXTO
linha8          STR     '#......##.........####......##.........#',FIM_TEXTO
linha9          STR     '#......##...................##....##...#',FIM_TEXTO
linha10         STR     '#....*................##..........##...#',FIM_TEXTO
linha11         STR     '########################################',FIM_TEXTO
linhaVidas      STR     '<3 <3 <3',FIM_TEXTO
						
ULTIMA_LINHA    STR     FIM_NIVEL
linha12         STR     'Points: ',FIM_TEXTO

TotalPontos     WORD    356d
BonusComida		WORD    10d; que eh o asterisco
linha13         STR     '!!!!WINNER!!!!',FIM_TEXTO
linhaLoser      STR     'GAME OVER :(',FIM_TEXTO

;variaveis pra vida
ColunaVida      WORD    10d 
LinhaVida       WORD    13d
Vidas_pac       WORD    3d

;variaveis do pacman
Pacman_dir      WORD    DIR_PARADO
Mov_pac         WORD    PARADO
Linha_pac       WORD    6d
Coluna_pac      WORD    23d
Confere_wall    WORD    0d
FindParede      WORD    0d
;Variaveis do placar/pontos
Conta_ptos      WORD    0d

;Variaveis para o fantasma:
;fantasma 1
Linha_fantasma1   	WORD   2d
Coluna_fantasma1  	WORD   5d
Fantasma_dir1    	WORD   DIR_PARADO

;fantasma 2
Linha_fantasma2    WORD    8d 
Coluna_fantasma2   WORD    35d
Fantasma_dir2      WORD    DIR_PARADO
;fantasma 3

Linha_fantasma3    WORD    11d   
Coluna_fantasma3   WORD    21d
Fantasma_dir3      WORD    DIR_PARADO

Random_Var       	WORD   A5A5h
Confere_wall_fant 	WORD   0d
;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    Atualiza_dir
INT1            WORD    Atualiza_esq
INT2            WORD    Atualiza_cima
INT3            WORD    Atualiza_baixo
   
				ORIG    FE0Fh

INT15           WORD    Timer


;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------ 
;SMP Q EU CHEGARR EM UM FIM_TEXTO EU CHEGUEI AO FIM DA linha
;BASTA ENTAO EU INCREMENTAR O ROW_INDEX da linha
;sempre q eu pular de linha minha coluna vai voltar p 2

;------------------------------------------------------------------------------
; Timer
; No timer ocorrerao muitas coisas importantes. A cada pulso de relogio eu irei 
; movimentar o pacman, os 3 fantasmas e eh onde o jogo acaba, seja por vitoria ou       
; derrota.       
;------------------------------------------------------------------------------


Timer:           PUSH R1
				 
				 

				 CALL Movimenta_Pac
				 CALL Movimenta_fantasma1
				 CALL Movimenta_fantasma2
				 CALL Movimenta_fantasma3

				 ;preciso comparar com a funcao total pontos para ver se o jogo acabou
				 ;quando como todos os pontos eu termino meu jogo


				 ;Essa comparacao eh pra quando come todas as comidas
				 CMP M[TotalPontos],R0
				 JMP.Z PararTimerVitoria

				 ;Essa funcao eh pra quando o fantasma mata o pacman
				 CMP M[Vidas_pac],R0
				 JMP.Z PararTimerDerrota

				 ;configuracao do timer

				 MOV R1, INTERV_TIMER
				 MOV M[CONFIG_TIMER], R1
				 MOV R1, LIGA_TIMER
				 MOV M[ACTIVATE_TIMER], R1





				 POP R1
				 RTI
				 
PararTimerVitoria:CALL PrintaVitoria
				  POP R1
			      RTI


PararTimerDerrota:CALL PrintaDerrota
				  POP R1
				  RTI


				 
;------------------------------------------------------------------------------
; Movimentacao PACMAN
; Nessas funcoes eu faco o movimento das 4 direcoes do pacman(direita,esquerda,cima,baixo)
;        
;        
;------------------------------------------------------------------------------

Movimenta_Direita: PUSH R4
			       PUSH R5
			       PUSH R6
			        
			       

			       MOV R4, M[Linha_pac]
			       MOV R5, M[Coluna_pac]
			       MOV R6,' '
			       SHL R4, 8
			       OR  R4,R5

			       CALL Acha_Parede

			       CMP M[Confere_wall], R0
			       JMP.NZ Fim_Movimento

			       CALL Verifica_se_pacman_morreu1
			       CALL Verifica_se_pacman_morreu2
			       CALL Verifica_se_pacman_morreu3


			       MOV M[CURSOR], R4
			       MOV M[IO_WRITE], R6

			       INC M[Coluna_pac]
			       MOV R4,M[Linha_pac]
			       MOV R5,M[Coluna_pac]
			       MOV R6, '?'
			       SHL R4,8
			       OR R4, R5 
			       MOV M[CURSOR],R4
			       MOV M[IO_WRITE],R6
			       JMP Fim_Movimento
			      



Movimenta_Cima:   PUSH R4
				  PUSH R5
				  PUSH R6

				  MOV R4, M[Linha_pac]
				  MOV R5, M[Coluna_pac]
				  MOV R6, ' '
				  SHL R4, 8 ;eu tenho q fazer um shift left na linha sempre pq sao sempre os 8 primeiros bits
				  OR  R4, R5 ; o or eh por causa desse shift left oq importa eh q vai ser sempre R4
				  
				  CALL Acha_Parede

			      CMP M[Confere_wall], R0
			      JMP.NZ Fim_Movimento

				  CALL Verifica_se_pacman_morreu1
				  CALL Verifica_se_pacman_morreu2
				  CALL Verifica_se_pacman_morreu3
				  

				  MOV M[CURSOR],R4
				  MOV M[IO_WRITE], R6
				  DEC M[Linha_pac]
				  MOV R4, M[Linha_pac]
				  MOV R5, M[Coluna_pac]
				  MOV R6,'?'
				  SHL R4, 8
				  OR R4, R5
				  MOV M[CURSOR],R4
				  MOV M[IO_WRITE],R6

				  POP R6
				  POP R5
				  POP R4


				  RET

Movimenta_Baixo: PUSH R4
				 PUSH R5
				 PUSH R6

				 MOV R4, M[Linha_pac]
				 MOV R5, M[Coluna_pac]
				 MOV R6,' '
				 SHL R4,8
				 OR R4, R5

				 CALL Acha_Parede

			     CMP M[Confere_wall], R0
			     JMP.NZ Fim_Movimento

			     ;Estou vendo se ocorreu uma colisao do pacman com os 3 fantasmas 
			     CALL Verifica_se_pacman_morreu1
			     CALL Verifica_se_pacman_morreu2
			     CALL Verifica_se_pacman_morreu3
			     

				 MOV M[CURSOR],R4
				 MOV M[IO_WRITE],R6
				 INC M[Linha_pac]
				 MOV R4, M[Linha_pac]
				 MOV R5, M[Coluna_pac]
				 MOV R6,'?'
				 SHL R4,8
				 OR R4,R5
				 MOV M[CURSOR], R4
				 MOV M[IO_WRITE],R6

				 POP R6
				 POP R5
				 POP R4

				 RET



Movimenta_Esquerda: PUSH    R4
					PUSH    R5
			 	 	PUSH    R6

				 	MOV 	R4, M[Linha_pac]
				 	MOV 	R5, M[Coluna_pac]
					MOV     R6, ' '

					SHL 	R4, 8 
					OR  	R4, R5

					CALL Acha_Parede

			        CMP M[Confere_wall], R0
			        JMP.NZ Fim_Movimento


			        CALL Verifica_se_pacman_morreu1
			        CALL Verifica_se_pacman_morreu2
			        CALL Verifica_se_pacman_morreu3
			     

					MOV 	M[CURSOR],R4
					MOV 	M[IO_WRITE],R6
					DEC     M[Coluna_pac]
					MOV 	R4, M[Linha_pac]
					MOV 	R5, M[Coluna_pac]; Decrementei e coloquei no R5, atualizei
					MOV     R6, '?'
					SHL     R4, 8
					OR      R4, R5
					MOV     M[CURSOR], R4
					MOV     M[IO_WRITE],R6

				    POP     R6
					POP     R5
					POP     R4
					

					RET


VER_SE_PARADO:MOV M[Pacman_dir],R0 ;verifico se o pacman ta parado

Fim_Movimento: POP R6
			   POP R5
			   POP R4

			   RET

;-----------------------------
;Calculo da direcao do pacman
;-----------------------------

Calc_dir:ADD R4,1d
		 JMP FIM_COMP


Calc_esq:DEC R1
		 JMP FIM_COMP

Calc_cima:SUB R1, MAX_COUNTER
		  JMP FIM_COMP

Calc_baixo:ADD R1,MAX_COUNTER
		   JMP FIM_COMP


;---------------------------------------
;Encontra parade pro pacman
;e com isso ele para.
;Eh como se fosse o limitador, se tem parede ele(o pacman) nao come
;----------------------------------------


Acha_Parede:PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5
			PUSH R6
			PUSH R7

			MOV R7,' '
			MOV M[Confere_wall],R0
			MOV R1, linha0; inicio do mapa 
			MOV R2,M[Linha_pac]
			MOV R3,MAX_COUNTER
			DEC R2
			MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
			
			MOV R4, M[Coluna_pac]

			MOV R6 ,M[Pacman_dir]
			CMP R6, DIR_DIR
			JMP.Z Calc_dir 

			CMP R6,DIR_ESQ
			JMP.Z Calc_esq

			CMP R6,DIR_CIMA
			JMP.Z Calc_cima

			CMP R6,DIR_BAIXO
			JMP.Z Calc_baixo



FIM_COMP:ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
		 ADD R1, R4 ;to verificando se a coluna esta certa
		 SUB R1,2d 
		 MOV R5,M[R1] ;guarda em R5 a posicao correta
		 MOV M[FindParede],R5
		 MOV R6,M[FindParede]
		 CMP R6,'.'
		 JMP.Z Conta_Comidas
		 CMP R6,'*'
		 JMP.Z Conta_Bonus
		 

		 CMP R6,'#'
		 JMP.NZ PULA2;DPS DAQUI PEGO O R6 E COMPARO COM .(COMIDA) AI SE FOR IGUAL VOU JMP P FUNCAO CONTA_comidas
		 

		 PULA1: INC M[Confere_wall]
		 		JMP PULA2

		 Conta_Comidas:INC M[Conta_ptos]
		 		       MOV M[R1],R7
		 		       DEC M[TotalPontos]
		 		       CALL Printa_Pontos
		 		       JMP PULA2

		Conta_Bonus:MOV R2,DEZ 
		 			MOV M[R1],R7  
		 			ADD M[Conta_ptos],R2
		 			SUB M[TotalPontos],R2
		 			
		 			CALL Printa_Pontos

		 		       
		 
		 

		PULA2:POP R7
		 	  POP R6
		   	  POP R5
			  POP R4
			  POP R3
			  POP R2
			  POP R1

					  
			  RET
Movimenta_Pac:  PUSH R1
				
				MOV R1, M[Pacman_dir]
				CMP R1, DIR_DIR
				CALL.Z Movimenta_Direita

				
				CMP R1, DIR_ESQ
				CALL.Z Movimenta_Esquerda

				
				CMP R1,DIR_CIMA
				CALL.Z Movimenta_Cima

				
				CMP R1, DIR_BAIXO
				CALL.Z Movimenta_Baixo

				POP R1


				
				RET


;------------------------------------------------------------------------------
; Preciso atualizar o estado do PACMAN ou seja se continuou naquela direcao
;------------------------------------------------------------------------------
 
Atualiza_dir:   PUSH R1 
				

				MOV R1, DIR_DIR
				MOV M[Pacman_dir], R1

				
				POP R1

				RTI

Atualiza_esq:   PUSH R1

				MOV R1, DIR_ESQ
				MOV M[Pacman_dir], R1

				POP R1

				RTI 

Atualiza_cima: PUSH R1

			   MOV R1,DIR_CIMA
			   MOV M[Pacman_dir],R1

			   POP R1
			   RTI 

Atualiza_baixo: PUSH R1

				MOV R1, DIR_BAIXO
				MOV M[Pacman_dir],R1 

				POP R1
				RTI 


;------------------------------------------------------------------------------
; Funcoes dos fantasmas. 
; Abaixo estao as funcoes para os 3 fantasmas. Pouca coisa muda entre elas,o principal
; eh a linha e a coluna do fantasma
; 
;------------------------------------------------------------------------------
;Fantasma 1

Random1: 		PUSH R1
				PUSH R2
			 	MOV R1, LSB_MASK
			 	AND R1,M[Random_Var]; R1 = bit menos significativo 
			 	BR.Z Rnd_rotate1
			 	MOV R1, RND_MASK
			 	XOR M[Random_Var],R1

Rnd_rotate1: 	ROR M[Random_Var],1
				CALL Calcula_Dir_fantasma1
				POP R2
				POP R1
	  			
	  			RET

;resultado fica em R2 e o Resto em R3

Calcula_Dir_fantasma1:PUSH R2
					  PUSH R3
					  PUSH R4

					  MOV R3,4d
					  MOV R2,M[Random_Var]
 					  DIV R2,R3
 					  MOV M[Fantasma_dir1],R3
 					  MOV R4, DIR_FANT_DIR
 					 
 					  CMP R3,R4
 					  CALL.Z MovFantasma1_Direita
 					  MOV R4, DIR_FANT_ESQ
 					  CMP R3, R4
 					  CALL.Z MovFantasma1_Esquerda
 					  MOV R4,DIR_FANT_CIMA
 					  CMP R3,R4
 					  CALL.Z MovFantasma1_Cima
 					  MOV R4, DIR_FANT_BAIXO
 					  CMP R3, R4
 					  CALL.Z MovFantasma1_Baixo

 					  POP R4
 					  POP R3
 					  POP R2
 					  RET



MovFantasma1_Direita:  PUSH R4
				       PUSH R5
				       PUSH R6
				        
				   

				       CALL Acha_Parede_Fantasma1


				       CMP M[Confere_wall_fant], R0
				       JMP.NZ Fim_Movimento_Fantasma1

				       CALL Nao_come_ponto1

				       CALL Verifica_se_pacman_morreu1

				       

				       INC M[Coluna_fantasma1]
				       MOV R4,M[Linha_fantasma1]
				       MOV R5,M[Coluna_fantasma1]
				       MOV R6, '$'
				       SHL R4,8
				       OR  R4, R5 
				       MOV M[CURSOR],R4
				       MOV M[IO_WRITE],R6
				       JMP Fim_Movimento
				     
MovFantasma1_Cima:    PUSH R4
					  PUSH R5
					  PUSH R6

	
					  CALL Acha_Parede_Fantasma1

				      CMP M[Confere_wall_fant], R0
				      JMP.NZ Fim_Movimento_Fantasma1

				      CALL Nao_come_ponto1
					  
					  CALL Verifica_se_pacman_morreu1

					  
					  DEC M[Linha_fantasma1]
					  MOV R4, M[Linha_fantasma1]
					  MOV R5, M[Coluna_fantasma1]
					  MOV R6,'$'
					  SHL R4, 8
					  OR R4, R5
					  MOV M[CURSOR],R4
					  MOV M[IO_WRITE],R6

					  POP R6
					  POP R5
					  POP R4


					  RET




MovFantasma1_Baixo:      PUSH R4
						 PUSH R5
						 PUSH R6

						 

						 ;Com essas linhas acima eu sei quantos tem ate o fantasminha
						
						 

						 CALL Acha_Parede_Fantasma1

					     CMP M[Confere_wall_fant], R0
					     JMP.NZ Fim_Movimento_Fantasma1

					     CALL Nao_come_ponto1

					     CALL Verifica_se_pacman_morreu1
						 
						 INC M[Linha_fantasma1]
						 MOV R4, M[Linha_fantasma1]
						 MOV R5, M[Coluna_fantasma1]

						 MOV R6,'$'
						 SHL R4,8
						 OR R4,R5
						 MOV M[CURSOR], R4
						 MOV M[IO_WRITE],R6



					
						 POP R6
						 POP R5
						 POP R4
						

						 RET
 


MovFantasma1_Esquerda:  PUSH    R4
						PUSH    R5
				 	 	PUSH    R6

											 	

						CALL Acha_Parede_Fantasma1

				        CMP M[Confere_wall_fant], R0
				        JMP.NZ Fim_Movimento_Fantasma1

				        CALL Nao_come_ponto1

				        CALL Verifica_se_pacman_morreu1

						DEC     M[Coluna_fantasma1]
						MOV 	R4, M[Linha_fantasma1]
						MOV 	R5, M[Coluna_fantasma1]; Decrementei e coloquei no R5, atualizei
						MOV     R6, '$'
						SHL     R4, 8
						OR      R4, R5
						MOV     M[CURSOR], R4
						MOV     M[IO_WRITE],R6

					    POP     R6
						POP     R5
						POP     R4
						

						RET

Fim_Movimento_Fantasma1: CALL Random1
						 POP R6
					     POP R5
					     POP R4

					     RET




Acha_Parede_Fantasma1:  PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						

						MOV M[Confere_wall_fant],R0
						MOV R1, linha0; inicio do mapa 
						MOV R2,M[Linha_fantasma1]
						MOV R3,MAX_COUNTER
						DEC R2
						MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
						
						MOV R4, M[Coluna_fantasma1]

						MOV R6 ,M[Fantasma_dir1]
						CMP R6, DIR_FANT_DIR
						JMP.Z Calc_dir_fantasma1

						CMP R6,DIR_FANT_ESQ
						JMP.Z Calc_esq_fantasma1

						CMP R6,DIR_FANT_CIMA
						JMP.Z Calc_cima_fantasma1

						CMP R6,DIR_FANT_BAIXO
						JMP.Z Calc_baixo_fantasma1



FIM_COMPARE_FANTASMA1:   ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
						 ADD R1, R4 ;to verificando se a coluna esta certa
						 SUB R1,2d 
						 MOV R5,M[R1] ;guarda em R5 a posicao correta
						 MOV M[FindParede],R5
						 MOV R6,M[FindParede]
						 
						 
						 CMP R6,'#'

						 JMP.NZ FazPopsFant1

						  
						 PULA_Caso_Fantasma:INC M[Confere_wall_fant]
						 					

FazPopsFant1:            POP R6
						 POP R5
						 POP R4
						 POP R3
						 POP R2
						 POP R1

											  
						 RET
;
;Essa funcao eh necessaria pq quando o fantasma passa por uma posicao ele come
; como se fosse o pacman

Nao_come_ponto1:        PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						

						MOV R1, linha0; inicio do mapa 
						MOV R2,M[Linha_fantasma1]
						MOV R3,MAX_COUNTER
						DEC R2
						MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
						
						MOV R4, M[Coluna_fantasma1]
						

						ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
						ADD R1, R4 ;to verificando se a coluna esta certa
						SUB R1,2d 
						MOV R5,M[R1] ;guarda em R5 a posicao correta


						MOV 	R4, M[Linha_fantasma1]
						MOV 	R6, M[Coluna_fantasma1]; Decrementei e coloquei no R5, atualizei
						SHL     R4, 8
						OR      R4, R6
						MOV     M[CURSOR], R4
						MOV     M[IO_WRITE],R5
						 
						 					
                        POP R6
						POP R5
						POP R4
						POP R3
						POP R2
						POP R1

											  
						RET





;--------------------------------
;Calculo a direcao do fantasma, assim como foi pro pacman 
;--------------------------------
Calc_dir_fantasma1:	   ADD R4,1d
		 		       JMP FIM_COMPARE_FANTASMA1


Calc_esq_fantasma1:	   DEC R1
				  	   JMP FIM_COMPARE_FANTASMA1

Calc_cima_fantasma1:    SUB R1, MAX_COUNTER
		  		       JMP FIM_COMPARE_FANTASMA1

Calc_baixo_fantasma1:   ADD R1,MAX_COUNTER
		   		       JMP FIM_COMPARE_FANTASMA1


Movimenta_fantasma1:   PUSH R1
					

				
					   MOV R1, M[Fantasma_dir1]
					   CMP R1, DIR_FANT_DIR
					   CALL.Z MovFantasma1_Direita

					
					   CMP R1, DIR_FANT_ESQ
					   CALL.Z MovFantasma1_Esquerda

					
					   CMP R1,DIR_FANT_CIMA
					   CALL.Z MovFantasma1_Cima

					
					   CMP R1, DIR_FANT_BAIXO
					   CALL.Z MovFantasma1_Baixo

					   POP R1
					   RET

;-------------------FANTASMA 2-----------------------

Random2: 		PUSH R1
				PUSH R2
			 	MOV R1, LSB_MASK
			 	AND R1,M[Random_Var]; R1 = bit menos significativo 
			 	BR.Z Rnd_rotate2
			 	MOV R1, RND_MASK
			 	XOR M[Random_Var],R1

Rnd_rotate2: 	ROR M[Random_Var],1
				CALL Calcula_Dir_fantasma2
				POP R2
				POP R1
	  			
	  			RET

;resultado fica em R2 e o Resto em R3

Calcula_Dir_fantasma2:PUSH R2
					  PUSH R3
					  PUSH R4

					  MOV R3,4d
					  MOV R2,M[Random_Var]
 					  DIV R2,R3
 					  MOV M[Fantasma_dir2],R3
 					  MOV R4, DIR_FANT_DIR
 					 
 					  CMP R3,R4
 					  CALL.Z MovFantasma2_Direita
 					  MOV R4, DIR_FANT_ESQ
 					  CMP R3, R4
 					  CALL.Z MovFantasma2_Esquerda
 					  MOV R4,DIR_FANT_CIMA
 					  CMP R3,R4
 					  CALL.Z MovFantasma2_Cima
 					  MOV R4, DIR_FANT_BAIXO
 					  CMP R3, R4
 					  CALL.Z MovFantasma2_Baixo

 					  POP R4
 					  POP R3
 					  POP R2
 					  RET



MovFantasma2_Direita:  PUSH R4
				       PUSH R5
				       PUSH R6
				        
				   

				       CALL Acha_Parede_Fantasma2


				       CMP M[Confere_wall_fant], R0
				       JMP.NZ Fim_Movimento_Fantasma2

				       CALL Nao_come_ponto2

				       CALL Verifica_se_pacman_morreu2

				       

				       INC M[Coluna_fantasma2]
				       MOV R4,M[Linha_fantasma2]
				       MOV R5,M[Coluna_fantasma2]
				       MOV R6, '$'
				       SHL R4,8
				       OR  R4, R5 
				       MOV M[CURSOR],R4
				       MOV M[IO_WRITE],R6
				       JMP Fim_Movimento
				     
MovFantasma2_Cima:     PUSH R4
					  PUSH R5
					  PUSH R6

	
					  CALL Acha_Parede_Fantasma2

				      CMP M[Confere_wall_fant], R0
				      JMP.NZ Fim_Movimento_Fantasma2

				      CALL Nao_come_ponto2
					  
					  CALL Verifica_se_pacman_morreu2

					  
					  DEC M[Linha_fantasma2]
					  MOV R4, M[Linha_fantasma2]
					  MOV R5, M[Coluna_fantasma2]
					  MOV R6,'$'
					  SHL R4, 8
					  OR R4, R5
					  MOV M[CURSOR],R4
					  MOV M[IO_WRITE],R6

					  POP R6
					  POP R5
					  POP R4


					  RET



MovFantasma2_Baixo:      PUSH R4
						 PUSH R5
						 PUSH R6

						 

						 ;Com essas linhas acima eu sei quantos tem ate o fantasminha
						
						 

						 CALL Acha_Parede_Fantasma2

					     CMP M[Confere_wall_fant], R0
					     JMP.NZ Fim_Movimento_Fantasma2

					     CALL Nao_come_ponto2

					     CALL Verifica_se_pacman_morreu2
						 
						 INC M[Linha_fantasma2]
						 MOV R4, M[Linha_fantasma2]
						 MOV R5, M[Coluna_fantasma2]

						 MOV R6,'$'
						 SHL R4,8
						 OR R4,R5
						 MOV M[CURSOR], R4
						 MOV M[IO_WRITE],R6



					
						 POP R6
						 POP R5
						 POP R4
						

						 RET
 


MovFantasma2_Esquerda:  PUSH    R4
						PUSH    R5
				 	 	PUSH    R6

											 	

						CALL Acha_Parede_Fantasma2

				        CMP M[Confere_wall_fant], R0
				        JMP.NZ Fim_Movimento_Fantasma2

				        CALL Nao_come_ponto2

				        CALL Verifica_se_pacman_morreu2

						DEC     M[Coluna_fantasma2]
						MOV 	R4, M[Linha_fantasma2]
						MOV 	R5, M[Coluna_fantasma2]; Decrementei e coloquei no R5, atualizei
						MOV     R6, '$'
						SHL     R4, 8
						OR      R4, R5
						MOV     M[CURSOR], R4
						MOV     M[IO_WRITE],R6

					    POP     R6
						POP     R5
						POP     R4
						

						RET

Fim_Movimento_Fantasma2: CALL Random2
						 POP R6
					     POP R5
					     POP R4

					     RET




Acha_Parede_Fantasma2:  PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						

						MOV M[Confere_wall_fant],R0
						MOV R1, linha0; inicio do mapa 
						MOV R2,M[Linha_fantasma2]
						MOV R3,MAX_COUNTER
						DEC R2
						MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
						
						MOV R4, M[Coluna_fantasma2]

						MOV R6 ,M[Fantasma_dir2]
						CMP R6, DIR_FANT_DIR
						JMP.Z Calc_dir_fantasma2

						CMP R6,DIR_FANT_ESQ
						JMP.Z Calc_esq_fantasma2

						CMP R6,DIR_FANT_CIMA
						JMP.Z Calc_cima_fantasma2

						CMP R6,DIR_FANT_BAIXO
						JMP.Z Calc_baixo_fantasma2



FIM_COMPARE_FANTASMA2:   ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
						 ADD R1, R4 ;to verificando se a coluna esta certa
						 SUB R1,2d 
						 MOV R5,M[R1] ;guarda em R5 a posicao correta
						 MOV M[FindParede],R5
						 MOV R6,M[FindParede]
						 
						 
						 CMP R6,'#'

						 JMP.NZ FazPopsFant2

						  
						 PULA_Caso_Fantasma2:INC M[Confere_wall_fant]
						 					

FazPopsFant2:            POP R6
						 POP R5
						 POP R4
						 POP R3
						 POP R2
						 POP R1

											  
						 RET
;
;Essa funcao eh necessaria pq quando o fantasma passa por uma posicao ele come
; como se fosse o pacman

Nao_come_ponto2:        PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						

						MOV R1, linha0; inicio do mapa 
						MOV R2,M[Linha_fantasma2]
						MOV R3,MAX_COUNTER
						DEC R2
						MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
						
						MOV R4, M[Coluna_fantasma2]
						

						ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
						ADD R1, R4 ;to verificando se a coluna esta certa
						SUB R1,2d 
						MOV R5,M[R1] ;guarda em R5 a posicao correta


						MOV 	R4, M[Linha_fantasma2]
						MOV 	R6, M[Coluna_fantasma2]; Decrementei e coloquei no R5, atualizei
						SHL     R4, 8
						OR      R4, R6
						MOV     M[CURSOR], R4
						MOV     M[IO_WRITE],R5
						 
						 					
                        POP R6
						POP R5
						POP R4
						POP R3
						POP R2
						POP R1

											  
						RET





Calc_dir_fantasma2:	   ADD R4,1d
		 		       JMP FIM_COMPARE_FANTASMA2


Calc_esq_fantasma2:	   DEC R1
				  	   JMP FIM_COMPARE_FANTASMA2

Calc_cima_fantasma2:    SUB R1, MAX_COUNTER
		  		       JMP FIM_COMPARE_FANTASMA2

Calc_baixo_fantasma2:   ADD R1,MAX_COUNTER
		   		       JMP FIM_COMPARE_FANTASMA2


Movimenta_fantasma2:   PUSH R1
					

				
					   MOV R1, M[Fantasma_dir2]
					   CMP R1, DIR_FANT_DIR
					   CALL.Z MovFantasma2_Direita

					
					   CMP R1, DIR_FANT_ESQ
					   CALL.Z MovFantasma2_Esquerda

					
					   CMP R1,DIR_FANT_CIMA
					   CALL.Z MovFantasma2_Cima

					
					   CMP R1, DIR_FANT_BAIXO
					   CALL.Z MovFantasma2_Baixo

					   POP R1
					   RET


;-------------------FANTASMA 3-----------------------

;Fantasma 3

Random3: 		PUSH R1
				PUSH R2
			 	MOV R1, LSB_MASK
			 	AND R1,M[Random_Var]; R1 = bit menos significativo 
			 	BR.Z Rnd_rotate3
			 	MOV R1, RND_MASK
			 	XOR M[Random_Var],R1

Rnd_rotate3: 	ROR M[Random_Var],1
				CALL Calcula_Dir_fantasma3
				POP R2
				POP R1
	  			
	  			RET

;resultado fica em R2 e o Resto em R3

Calcula_Dir_fantasma3:PUSH R2
					  PUSH R3
					  PUSH R4

					  MOV R3,4d
					  MOV R2,M[Random_Var]
 					  DIV R2,R3
 					  MOV M[Fantasma_dir3],R3
 					  MOV R4, DIR_FANT_DIR
 					 
 					  CMP R3,R4
 					  CALL.Z Movfantasma3_Direita
 					  MOV R4, DIR_FANT_ESQ
 					  CMP R3, R4
 					  CALL.Z Movfantasma3_Esquerda
 					  MOV R4,DIR_FANT_CIMA
 					  CMP R3,R4
 					  CALL.Z Movfantasma3_Cima
 					  MOV R4, DIR_FANT_BAIXO
 					  CMP R3, R4
 					  CALL.Z Movfantasma3_Baixo

 					  POP R4
 					  POP R3
 					  POP R2
 					  RET



Movfantasma3_Direita:  PUSH R4
				       PUSH R5
				       PUSH R6
				        
				   

				       CALL Acha_Parede_fantasma3


				       CMP M[Confere_wall_fant], R0
				       JMP.NZ Fim_Movimento_fantasma3

				       CALL Nao_come_ponto3

				       CALL Verifica_se_pacman_morreu3

				       

				       INC M[Coluna_fantasma3]
				       MOV R4,M[Linha_fantasma3]
				       MOV R5,M[Coluna_fantasma3]
				       MOV R6, '$'
				       SHL R4,8
				       OR  R4, R5 
				       MOV M[CURSOR],R4
				       MOV M[IO_WRITE],R6
				       JMP Fim_Movimento
				     
Movfantasma3_Cima:    PUSH R4
					  PUSH R5
					  PUSH R6

	
					  CALL Acha_Parede_fantasma3

				      CMP M[Confere_wall_fant], R0
				      JMP.NZ Fim_Movimento_fantasma3

				      CALL Nao_come_ponto3
					  
					  CALL Verifica_se_pacman_morreu3

					  
					  DEC M[Linha_fantasma3]
					  MOV R4, M[Linha_fantasma3]
					  MOV R5, M[Coluna_fantasma3]
					  MOV R6,'$'
					  SHL R4, 8
					  OR R4, R5
					  MOV M[CURSOR],R4
					  MOV M[IO_WRITE],R6

					  POP R6
					  POP R5
					  POP R4


					  RET




Movfantasma3_Baixo:      PUSH R4
						 PUSH R5
						 PUSH R6

						 

						 
						
						 

						 CALL Acha_Parede_fantasma3

					     CMP M[Confere_wall_fant], R0
					     JMP.NZ Fim_Movimento_fantasma3

					     CALL Nao_come_ponto3

					     CALL Verifica_se_pacman_morreu3
						 
						 INC M[Linha_fantasma3]
						 MOV R4, M[Linha_fantasma3]
						 MOV R5, M[Coluna_fantasma3]

						 MOV R6,'$'
						 SHL R4,8
						 OR R4,R5
						 MOV M[CURSOR], R4
						 MOV M[IO_WRITE],R6



					
						 POP R6
						 POP R5
						 POP R4
						

						 RET
 


Movfantasma3_Esquerda:  PUSH    R4
						PUSH    R5
				 	 	PUSH    R6

											 	

						CALL Acha_Parede_fantasma3

				        CMP M[Confere_wall_fant], R0
				        JMP.NZ Fim_Movimento_fantasma3

				        CALL Nao_come_ponto3

				        CALL Verifica_se_pacman_morreu3

						DEC     M[Coluna_fantasma3]
						MOV 	R4, M[Linha_fantasma3]
						MOV 	R5, M[Coluna_fantasma3]; Decrementei e coloquei no R5, atualizei
						MOV     R6, '$'
						SHL     R4, 8
						OR      R4, R5
						MOV     M[CURSOR], R4
						MOV     M[IO_WRITE],R6

					    POP     R6
						POP     R5
						POP     R4
						

						RET

Fim_Movimento_fantasma3: CALL Random3
						 POP R6
					     POP R5
					     POP R4

					     RET




Acha_Parede_fantasma3:  PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						

						MOV M[Confere_wall_fant],R0
						MOV R1, linha0; inicio do mapa 
						MOV R2,M[Linha_fantasma3]
						MOV R3,MAX_COUNTER
						DEC R2
						MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
						
						MOV R4, M[Coluna_fantasma3]

						MOV R6 ,M[Fantasma_dir3]
						CMP R6, DIR_FANT_DIR
						JMP.Z Calc_dir_fantasma3

						CMP R6,DIR_FANT_ESQ
						JMP.Z Calc_esq_fantasma3

						CMP R6,DIR_FANT_CIMA
						JMP.Z Calc_cima_fantasma3

						CMP R6,DIR_FANT_BAIXO
						JMP.Z Calc_baixo_fantasma3



FIM_COMPARE_fantasma3:   ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
						 ADD R1, R4 ;to verificando se a coluna esta certa
						 SUB R1,2d 
						 MOV R5,M[R1] ;guarda em R5 a posicao correta
						 MOV M[FindParede],R5
						 MOV R6,M[FindParede]
						 
						 
						 CMP R6,'#'

						 JMP.NZ FazPopsFant3

						  
						 PULA_Caso_Fantasma3:INC M[Confere_wall_fant]
						 					

FazPopsFant3:            POP R6
						 POP R5
						 POP R4
						 POP R3
						 POP R2
						 POP R1

											  
						 RET



Nao_come_ponto3:        PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5
						PUSH R6
						

						MOV R1, linha0; inicio do mapa 
						MOV R2,M[Linha_fantasma3]
						MOV R3,MAX_COUNTER
						DEC R2
						MUL R2,R3; ja tenho a qdade de colunas até a linha anterior a linha q o pacman esta
						
						MOV R4, M[Coluna_fantasma3]
						

						ADD R1,R3; to pegando desde o inicio e colocando no ultimo caracter da linha anterior
						ADD R1, R4 ;to verificando se a coluna esta certa
						SUB R1,2d 
						MOV R5,M[R1] ;guarda em R5 a posicao correta


						MOV 	R4, M[Linha_fantasma3]
						MOV 	R6, M[Coluna_fantasma3]; Decrementei e coloquei no R5, atualizei
						SHL     R4, 8
						OR      R4, R6
						MOV     M[CURSOR], R4
						MOV     M[IO_WRITE],R5
						 
						 					
                        POP R6
						POP R5
						POP R4
						POP R3
						POP R2
						POP R1

											  
						RET





;--------------------------------
;--------------------------------
Calc_dir_fantasma3:	   ADD R4,1d
		 		       JMP FIM_COMPARE_fantasma3


Calc_esq_fantasma3:	   DEC R1
				  	   JMP FIM_COMPARE_fantasma3

Calc_cima_fantasma3:    SUB R1, MAX_COUNTER
		  		       JMP FIM_COMPARE_fantasma3

Calc_baixo_fantasma3:   ADD R1,MAX_COUNTER
		   		       JMP FIM_COMPARE_fantasma3


Movimenta_fantasma3:   PUSH R1
					

				
					   MOV R1, M[Fantasma_dir3]
					   CMP R1, DIR_FANT_DIR
					   CALL.Z Movfantasma3_Direita

					
					   CMP R1, DIR_FANT_ESQ
					   CALL.Z Movfantasma3_Esquerda

					
					   CMP R1,DIR_FANT_CIMA
					   CALL.Z Movfantasma3_Cima

					
					   CMP R1, DIR_FANT_BAIXO
					   CALL.Z Movfantasma3_Baixo

					   POP R1
					   RET
Verifica_se_pacman_morreu3: PUSH R1
						    PUSH R2
						    PUSH R3
						    PUSH R4
						  

						    MOV R1,M[Linha_pac]
						    MOV R2,M[Coluna_pac]
						    MOV R3,M[Linha_fantasma3]
						    MOV R4,M[Coluna_fantasma3]

						    CMP R1,R3
						    JMP.NZ FazPOPS3
						    CMP R2,R4
						    JMP.NZ FazPOPS3
						    JMP Volta_pos_iniciais

FazPOPS3: 				    POP R4
						    POP R3
						    POP R2 
						    POP R1 
						    RET


;------------------------------------------------------------------------------
; Placar do jogo
;Essa funcao sereve pra escrever na tela o placar do jogo e suas atualizacoes com as
;comidas e o bonus(que eh o estrela *)
;        
;------------------------------------------------------------------------------





Printa_Pontos:          PUSH R1
						PUSH R2
						PUSH R3
						PUSH R4
						PUSH R5


						MOV R2, 2d
						MOV M[ColumnIndex],R2;reinicio o columnindex
						
			           ;agora precisamos posicionar o cursor pra pintar a pontuação:
			
						MOV     R1, linha12
						MOV     M[recebemem], R1



LoopPrintaPontos:       MOV		R2, M[ RowIndex ]
						SHL		R2, 8
						MOV		R3, M[ ColumnIndex ]
						OR		R2, R3
						MOV		M[ CURSOR ], R2
						 
				        MOV     R1, M[recebemem]
				        MOV     R1, M[R1]
	   			        CMP     R1, FIM_TEXTO
	   			        JMP.Z   Fim_Print_Pontos
	   			        MOV     M[IO_WRITE],R1
	   			        INC     M[recebemem];aqui to fazendo o incremento pra printar as letras da palavra pontuação
	   			        INC     M[ColumnIndex];como eu mudo a coluna q to printando tenho q incrementa-la tbm
	   			        JMP     LoopPrintaPontos


	   			         
	   			  

Fim_Print_Pontos:   MOV R1,CEM 
					MOV R2,M[Conta_ptos]


					;aqui eh a parte pra imprimir o primeiro digito

					DIV R2, R1; em r2 ficara o resultado e em r1 o resto
					;o Quociente eh oq quero printar
					;Vou somar o R2 com a constante Base_ASCII

					MOV R3,Base_ASCII
					ADD R2,R3
					;o valor 48 em decimanl eh equivalente ao caracter 0!!! PARTE IMPORTANTE
					;agora o valor tá em R2
					INC M[ColumnIndex]
					MOV		R4, M[ RowIndex ]
					SHL		R4, 8
					MOV		R5, M[ ColumnIndex ]
					OR		R4, R5
					MOV		M[ CURSOR ], R4
					MOV     M[IO_WRITE],R2
					;aqui termino de printar o primeiro digito

					;Aqui pra printar o segundo digito

					MOV R2,DEZ
					DIV R1,R2
					ADD R1, R3

					INC M[ColumnIndex]

					MOV		R4, M[ RowIndex ]
					SHL		R4, 8
					MOV		R5, M[ ColumnIndex ]
					OR		R4, R5
					MOV		M[ CURSOR ], R4
					MOV     M[IO_WRITE],R1


					;aqui pra printar o terceiro digito

					ADD R2, R3

					INC M[ColumnIndex]

					MOV		R4, M[ RowIndex ]
					SHL		R4, 8
					MOV		R5, M[ ColumnIndex ]
					OR		R4, R5
					MOV		M[ CURSOR ], R4
					MOV     M[IO_WRITE],R2


					POP R5
					POP R4
					POP R3
					POP R2
					POP R1
					RET

;------------------------------------------------------------------
;---------------Funcao para printar mapa----------------------------
;------------------------------------------------------------------



IncrementaLinha:INC 	M[RowIndex]
				MOV     R6,M[ColunaInicio]
				MOV 	M[ColumnIndex], R6
				MOV		R2, M[ RowIndex ]
				SHL		R2, 8
				MOV		R3, M[ ColumnIndex ]
				OR		R2, R3
				MOV		M[ CURSOR ], R2
				INC     M[recebemem]; esse incremento eu tenho q fazer pq o meu R1 == recebemem, e ele ocorre pq preciso ir pra proxima linha (da string) 
				MOV     R1, M[recebemem]
				MOV     R1, M[R1]
				CMP     R1, FIM_NIVEL
				JMP.Z   Fim_Print





PrintString:	MOV R1, M[recebemem]; R1 TEM O ENDERECO DO INICIO DA MINHA VARIAVEL
				MOV R1, M[R1] ; R1 TEM O CONTEUDO DA POS DE MEMORIA R1
				CMP R1, FIM_TEXTO ; se for igual ele vai pra Incrementalinha

				JMP.Z IncrementaLinha

				MOV		R2, M[ RowIndex ]
				SHL		R2, 8
				MOV		R3, M[ ColumnIndex ]
				OR		R2, R3
				MOV		M[ CURSOR ], R2
				MOV		M[IO_WRITE],R1 ; ESCREVE A STRING NA TELA
				INC     M[ColumnIndex] ; aqui eu preciso andar na coluna pra printar o caracter seguinte
				INC  	M[recebemem]
				JMP     PrintString

Fim_Print: 	   MOV R1,1d
			   MOV M[ColumnIndex],R1 
			   RET



;------------------------------------
;Funcao para fazer com que o fantasma 'coma' o pacman
;Tanto do fantasma 1 quanto do fantasma 2 e do 3
;
;
;------------------------------------

Verifica_se_pacman_morreu1: PUSH R1
						    PUSH R2
						    PUSH R3
						    PUSH R4
						  

						    MOV R1,M[Linha_pac]
						    MOV R2,M[Coluna_pac]
						    MOV R3,M[Linha_fantasma1]
						    MOV R4,M[Coluna_fantasma1]

						    CMP R1,R3
						    JMP.NZ FazPOPS1
						    CMP R2,R4
						    JMP.NZ FazPOPS1
						    JMP Volta_pos_iniciais



FazPOPS2:              		POP R4
							POP R3
							POP R2
							POP R1
							RET




Verifica_se_pacman_morreu2:PUSH R1
						   PUSH R2
						   PUSH R3
						   PUSH R4
						  

						   MOV R1,M[Linha_pac]
						   MOV R2,M[Coluna_pac]
						   MOV R3,M[Linha_fantasma2]
						   MOV R4,M[Coluna_fantasma2]

						   CMP R1,R3
						   JMP.NZ FazPOPS2
						   CMP R2,R4
						   JMP.NZ FazPOPS2


						   
;----------------------------------------
;Funcao que faz com que o pacman retorne a
;posicao inicial apos o fantasma come-lo
;
;----------------------------------------
						  ;pos pacman
Volta_pos_iniciais:       MOV R1, 6d
						  MOV R2, 23d
						  MOV M[Linha_pac],R1
						  MOV M[Coluna_pac],R2
						  DEC M[Vidas_pac]
						  CALL RetiraVidaTela 
						  
						  POP R4
						  POP R3
						  POP R2
						  POP R1
						  RET 

FazPOPS1: 				  POP R4
						  POP R3
						  POP R2 
						  POP R1 
						  RET

	

;--------------------------------------------------------------
;Preciso de uma funcao que retire uma vida da tela após a colisao do
;pacman com o fantasma.
;
;--------------------------------------------------------------


RetiraVidaTela:     PUSH  R1
					PUSH  R2
					PUSH  R4
					
				

					MOV R4,' '
					
					MOV  R1,M[LinhaVida]
					MOV  R2,M[ColunaVida]
					SHL R1,8
			       	OR R1, R2 
			       	MOV M[CURSOR],R1
			       	MOV M[IO_WRITE],R4

					DEC  M[ColunaVida]
					MOV  R1,M[LinhaVida]
					MOV  R2,M[ColunaVida]
					SHL R1,8
			       	OR R1, R2 
			       	MOV M[CURSOR],R1
			       	MOV M[IO_WRITE],R4
					
			       	DEC  M[ColunaVida]
					MOV  R1,M[LinhaVida]
					MOV  R2,M[ColunaVida]
					SHL R1,8
			       	OR R1, R2 
			       	MOV M[CURSOR],R1
			       	MOV M[IO_WRITE],R4

			       	DEC M[ColunaVida];estava tirando apenas o 3 da minha <3

					


			       	POP R4
			       	POP R2
			       	POP R1
			       	RET



PrintaDerrota:  	PUSH 	R1
					PUSH 	R2
					PUSH 	R3
					PUSH 	R4

					MOV R1,	linhaLoser
					MOV R4,	R1


PrintDefeated:		MOV R1, M[R4] 
					CMP R1, FIM_TEXTO


					JMP.Z 	FAZpopsDerrota

					MOV		R2, 15d; esse 15d eh a posicao que vai printar o derrota na tela
					SHL		R2, 8
					MOV		R3, M[ColumnIndex]
					OR		R2, R3
					MOV		M[ CURSOR ], R2
					MOV		M[IO_WRITE],R1 ; ESCREVE A STRING NA TELA
					INC     M[ColumnIndex] ; aqui eu preciso andar na coluna pra printar o caracter seguinte
					INC  	R4
					JMP     PrintDefeated


FAZpopsDerrota: 	POP 	R4
					POP 	R3
					POP 	R2
					POP 	R1
					RET
;--------------------------------------------------------------
;Funcao de Vitorias
;Serve pra printar quando o jogador comer todos as comidas e os bonus(*)
;
;--------------------------------------------------------------



PrintaVitoria: 		PUSH 	R1
					PUSH 	R2
					PUSH 	R3
					PUSH 	R4

					MOV R1,	linha13
					MOV R4,	R1


PrintVictory:		MOV R1, M[R4] 
					CMP R1, FIM_TEXTO


					JMP.Z 	FAZpops

					MOV		R2, 15d
					SHL		R2, 8
					MOV		R3, M[ColumnIndex]
					OR		R2, R3
					MOV		M[ CURSOR ], R2
					MOV		M[IO_WRITE],R1 ; ESCREVE A STRING NA TELA
					INC     M[ColumnIndex] ; aqui eu preciso andar na coluna pra printar o caracter seguinte
					INC  	R4
					JMP     PrintVictory


FAZpops:        	POP 	R4
					POP 	R3
					POP 	R2
					POP 	R1
					RET




			                
Main:				ENI

					MOV R1, linha0 ; pegando a string toda e jogando ela em R1
					MOV M[recebemem], R1 ; ESTOU PEGANDO A POS INICIAL DE MEMORIA DA STRING E COLOCANDO EM recebemem

					MOV		R1, INITIAL_SP
					MOV		SP, R1		 		; We need to initialize the stack
					MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
					MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
					MOV     R4, M[Linha_pac]
					CALL    PrintString
				
					CALL    Printa_Pontos
				
					;chamo o pacman na main pois se ele nao estivesse aqui nao conseguiria contar os pontos
					MOV R1, '?'
					MOV		R2, M[Linha_pac]
					SHL		R2, 8
					MOV		R3, M[Coluna_pac]
					OR		R2, R3
					MOV		M[ CURSOR ], R2
					MOV		M[IO_WRITE],R1
					;o mesmo para os 3 fantasmas

					MOV R1 , '$'
					MOV		R2, M[Linha_fantasma1]
					SHL		R2, 8
					MOV		R3, M[Coluna_fantasma1]
					OR		R2, R3
					MOV		M[ CURSOR ], R2
					MOV		M[IO_WRITE],R1


					MOV R1 , '$'
					MOV		R2, M[Linha_fantasma2]
					SHL		R2, 8
					MOV		R3, M[Coluna_fantasma2]
					OR		R2, R3
					MOV		M[ CURSOR ], R2
					MOV		M[IO_WRITE],R1

					MOV R1 , '$'
					MOV		R2, M[Linha_fantasma3]
					SHL		R2, 8
					MOV		R3, M[Coluna_fantasma3]
					OR		R2, R3
					MOV		M[ CURSOR ], R2
					MOV		M[IO_WRITE],R1
					


					CALL Random1 
					CALL Random2
					CALL Random3


					MOV 	R1 , INTERV_TIMER
					MOV     M[CONFIG_TIMER],R1
					MOV     R1, LIGA_TIMER
					MOV     M[ACTIVATE_TIMER],R1
					
				


Cycle: 				BR		Cycle	
Halt:          		BR		Halt


;no terminal
;./p3as-linux trab.as 
;java -jar p3sim.jar trab.exe 
