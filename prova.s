.section .text
    .globl postfix
    .type postfix, @function
postfix:
    
    movl 4(%esp), %esi      #primo puntatore frase in input; source index
    movl 8(%esp), %edi      #secondo puntatore frase in output; destination index

    cmpb $0, (%esi)         #devo comparare il byte, prima va l'immediato e poi l'indirizzamento a memoria
    jnz algo
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

    push %eax
cmpb $0, (%esi)
jz fine
jnz main_loop

    torno_negato:
    movl (%esi), %eax

    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio

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

    jnz erroe


negativo:
    inc %esi
    cmpb $48, (%esi)
    jge controllo_negato       
    jl segno


spazio:
    imul 10, %eax
    inc %esi
    cmpb $32, (%esi)        #spazio
    jnz spazio
    jz main_loop

errore:

fine:

