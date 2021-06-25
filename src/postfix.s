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

    cmpb $48, (%esi)
    jge controllo       
    jl segno

    torno:
    xor %eax, %eax              #non salviamo il valore nello stack 

    xor %ecx, %ecx
    movl $48, %ecx
    
    movl (%esi), %eax

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    
    push %eax
    
    addl $49, %ecx
    jz main_loop

    
    
cmpb $0, (%esi)
jz fine
jnz main_loop

    torno_negato:

    xor %eax, %eax
    
    xor %ecx, %ecx
    movl $48, %ecx

    movl (%esi), %eax

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    neg %eax
    push %eax

    addl $49, %ecx

    jz main_loop

    
controllo_fine_stringa:
cmpb $0, (%esi)
jz fine
jnz main_loop
#fine main loop

controllo:
    cmpb $57, (%esi)
    jle torno
    jg errore


controllo_negato:
    cmpb $57, (%esi)
    jle torno_negato
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

    #fare un controllo in piu per vedere se è uno spazio così ci togliamo tutti i dubbi così controllo anche se ci sono caratteri strani
    cmpb $32, (%esi)        #spazio
    jz next

    jmp errore 

next:
    inc %esi
    jmp main_loop

addizione:
    popl %ebx 
    popl %eax
    addl %ebx, %eax
    pushl %eax
    inc %esi

    subl $49, %ecx

    jmp controllo_fine_stringa

sottrazione:
    popl %ebx
    popl %eax
    subl %ebx, %eax
    pushl %eax

    subl $49, %ecx

    jmp controllo_fine_stringa

moltiplicazione:
    movl $0 , %edx
    popl %ebx
    popl %eax
    imul %ebx               #eax moltiplicato con il regitro datogli
    pushl %eax

    subl $49, %ecx

    inc %esi
    jmp controllo_fine_stringa

divisione:
    #da controllare se il numeratore è negativo
    movl $0 , %edx
    popl %ebx 
    popl %eax
    idiv %ebx 
    pushl %eax

    subl $49, %ecx

    inc %esi
    jmp controllo_fine_stringa

negativo:
    inc %esi
    cmpb $32, (%esi)           #spazio
    jme sottrazione             #salta anche se è \0
    jmp torno_negato
    cmpb $53, (%esi)
    jg errore

spazio:
    cmpb $48 , (%esi)
    jl errore
    cmpb $57 ,(%esi)
    jg errore
    imul $10, %eax       #$10?? me sa che va con $
    addl (%esi), %eax
    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    pushl %eax

    addl $49, %ecx
    
    jz main_loop

errore:
    #prima di andare qui lo stack è pulito o va sempre in errore?
    #contiamo tutte le push su ecx e poi facciamo tot pop decrementando ogni volta, gg problema risolveggiuto
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
    
fine:

    #salvataggio variabili su edi

    #cmp $10, %eax
    #jge dividi

    #movl %eax, (%edi)
    popl %eax   #un vecchio saggio disse: dopo una push ci vuole una pop 

    cmpl $0, %eax
    jl aggiungi_meno 
    
fine2:

    cmp $10, %eax
    jge dividi

    movl %eax, (%edi)

    jmp tappo

dividi:# da finire
    movl $0 , %edx
    idiv $10
    movl %edx , (%edi)
    cmpl $0 , %eax #da errore
    jz tappo 
    imul 


tappo:
    inc %edi
    movl $0, (%edi)         #scrivo 0 in edi che è anche il carattere di terminazione

return:
ret #fine del programma

aggiungi_meno:
    movl $45, (%edi)
    jmp fine2