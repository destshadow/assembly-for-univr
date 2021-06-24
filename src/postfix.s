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

    movl (%esi), %eax

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    jz main_loop

    push %eax
    
cmpb $0, (%esi)
jz fine
jnz main_loop

    torno_negato:
    movl (%esi), %eax

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    jz main_loop

    neg %eax
    push %eax

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

    jmp errore #no senno da errori orrendi

addizione:
    popl %ebx 
    popl %eax
    addl %ebx, %eax
    pushl %eax
    jmp main_loop

sottrazione:
    popl %ebx
    popl %eax
    subl %ebx, %eax
    pushl %eax
    jmp main_loop

moltiplicazione:
    movl $0 , %edx
    popl %ebx
    popl %eax
    imul %ebx               #eax moltiplicato con il regitro datogli
    pushl %eax
    jmp main_loop

divisione:
    movl $0 , %edx
    popl %ebx 
    popl %eax
    idiv %ebx 
    pushl %eax
    jmp main_loop

negativo:
    inc %esi
    cmpb $32, (%esi)
    je sottrazione       
    jmp torno_negato


spazio:
    imul $10, %eax       #$10?? me sa che va con $
    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    jz main_loop

errore:
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

    cmp $10, %eax
    jge dividi

    movl %eax, (%edi)
    inc %edi
    jmp tappo

dividi:
    movl $0, %edx
    movl $10, %ebx

    divl %ebx               #divido per ebx (10) il numero ottenuto
    movl %edx, (%edi)       #salvo il resto della divisione
    inc %edi
    jmp fine

tappo:
    movl $0, (%edi)         #scrivo 0 in edi che è anche il carattere di terminazione

return:
ret #fine del programma

