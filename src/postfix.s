.section .text
    .globl postfix
    .type postfix, @function

postfix:

    movl 4(%esp), %esi      #primo puntatore frase in input; source index
    movl 8(%esp), %edi      #secondo puntatore frase in output; destination index
    
    cmpb $0, (%esi)         #devo comparare il byte, prima va l'immediato e poi l'indirizzamento a memoria
    jnz main_loop
    jz errore

main_loop:

    xor %ecx, %ecx

    cmpb $48, (%esi)        #qui funziona il controllo sul numero in esi 
    jge controllo       
    jl segno

    torno:
    xor %eax, %eax          #non salviamo il valore nello stack 
    xor %edx, %edx
    
    movb (%esi), %dl
    movl %edx, %eax
    subl $48, %eax          #sottraend 48 trovo il numero che ci serve

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio              
    
    push %eax
    addl $49, %ecx

jmp main_loop

    torno_negato:

    cmpb $48 , (%esi)
    jl errore
    
    cmpb $57 , (%esi)
    jg errore

    xor %eax, %eax
    xor %edx, %edx

    movb (%esi), %dl
    movl %edx, %eax
    subl $48, %eax

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio_negato

    neg %eax
    push %eax

    addl $49, %ecx

jmp main_loop

    
controllo_fine_stringa:
    cmpb $10, (%esi)
    jz next
    cmpb $0, (%esi)
    jz fine
    jnz main_loop
    #fine main loop

controllo:
    cmpb $57, (%esi)
    jle torno
    jg errore

segno:
    cmpb $43, (%esi)        #+
    jz addizione

    cmpb $45, (%esi)        #- 
    jz negativo

    cmpb $42, (%esi)        #*
    jz moltiplicazione

    cmpb $47, (%esi)        #/
    jz divisione

    cmpb $32, (%esi)        #spazio
    jz next

    cmpb $0, (%esi)         #carattere di fine stringa
    jz fine

    cmpb $10, (%esi)        #carattere di \n
    jz next

    jmp errore              #se non è nessuno dei precedenti vado in errore

next:
    inc %esi
    jmp main_loop

addizione:
    popl %eax 
    popl %ebx
    addl %ebx, %eax
    pushl %eax
    inc %esi

    subl $49, %ecx

    jmp controllo_fine_stringa

sottrazione:
    popl %eax
    popl %ebx
    subl %eax, %ebx
    pushl %ebx              

    subl $49, %ecx

    jmp controllo_fine_stringa

moltiplicazione:
    movl $0 , %edx
    popl %eax
    popl %ebx
    imul %ebx               #eax moltiplicato con il regitro datogli
    pushl %eax

    subl $49, %ecx

    inc %esi
    jmp controllo_fine_stringa

divisione:

    xor %edx , %edx
    movl $0 , %edx
    popl %ebx 
    popl %eax

    dec %ecx
    dec %ecx

    cmpl $0 , %eax
    jl errore

    idiv %ebx 
    pushl %eax

    inc %ecx

    inc %esi
    jmp controllo_fine_stringa

negativo:
    inc %esi
    cmpb $32, (%esi)            #spazio
    jle sottrazione             #salta anche se è \0
    jmp torno_negato
   

spazio:
    
    cmpb $48 , (%esi)       #controlla anche se è uno spazio piu o meno
    jl errore

    cmpb $57 ,(%esi)
    jg errore

    xor %edx, %edx          #pulisco edx

    imul $10, %eax          #10

    movb (%esi), %dl        #spostiamo il numero in al
    addl %edx, %eax

    subl $48, %eax          #sottraiamo 48
    
    inc %esi

    cmpb $32, (%esi)
    
    jnz spazio
    
    pushl %eax
    addl $49, %ecx
    
    jmp main_loop

spazio_negato:
    cmpb $48 , (%esi)       #controlla anche se è uno spazio piu o meno
    jl errore

    cmpb $57 ,(%esi)
    jg errore

    xor %edx, %edx

    imul $10, %eax          #$10
    movb (%esi), %dl        #spostiamo il numero in al
    addl %edx, %eax          #sottraiamo 48
    subl $48, %eax
    inc %esi
    
    cmpb $32, (%esi)
    jnz spazio_negato
    
    neg %eax
    pushl %eax
    addl $49, %ecx
    
    jmp main_loop


errore:
    
    cmpl $0, %ecx
    jge elimina

    movl $73, (%edi)        #scrivo I in edi
    inc %edi                #incremento di 1 edi
    movl $110, (%edi)        #scrivo n in edi
    inc %edi                #incremento di 1 edi
    movl $118, (%edi)        #scrivo v in edi
    inc %edi                #incremento di 1 edi
    movl $97, (%edi)        #scriva a in edi
    inc %edi
    movl $108, (%edi)        #scrivo l in edi
    inc %edi
    movl $105, (%edi)        #scrivo i in edi
    inc %edi
    movl $100, (%edi)        #scrivo d in edi

    inc %edi
    movl $0, (%edi)         #scrivo 0 in edi che è anche il carattere di terminazione
    jmp return

elimina:
    pop %eax
    dec %ecx
    jmp errore

fine:

                            #salvataggio variabili su edi
    xor %eax , %eax
    popl %eax               
    xor %ecx , %ecx
    xor %edx , %edx
    xor %ebx , %ebx    

init:

    movl $10 , %ebx
    cmp   $10, %eax		    # confronta 10 con il contenuto di %eax
    jge dividi		        # salta all'etichetta dividi se %eax e'
	cmp $0 , %eax	        # maggiore o uguale a 10
    jl num_neg
    pushl %eax		        # salva nello stack il contenuto di %eax
    inc   %ecx	
    jmp stampa
  
dividi:
    div %ebx                #divido eax per 10 (ebx)
    pushl %edx              #pusho il resto
    xor %edx, %edx        
    inc %ecx                #incremento di 1 ecx
    jmp init

dividi_2:

    div %ebx                #divido eax per 10 (ebx)
    pushl %edx              #pusho il resto
    xor %edx, %edx        
    inc %ecx                #incremento di 1 ecx
    jmp aggiungi_meno 

stampa: 
   popl %eax
   addl $48 , %eax          #converto in carattere
   movb %al,(%edi)
   dec %ecx                 #decremento ecx
   inc %edi                 
   cmpl $0 , %ecx           #non ho piu cifre da aggiungere
   jg stampa 
   jmp tappo


tappo:
    movl $0, (%edi)         #scrivo 0 in edi che è anche il carattere di terminazione

return:
    ret                     #fine del programma

num_neg:

    neg %eax

    cmp   $10, %eax		# confronta 10 con il contenuto di %eax
    jge dividi_2

aggiungi_meno:
     
    cmp   $10, %eax		# confronta 10 con il contenuto di %eax
    jge dividi_2

    pushl %eax
    inc %ecx

    movl $45 , %eax
  
    movl %eax , (%edi)
    inc %edi

    jmp stampa
    