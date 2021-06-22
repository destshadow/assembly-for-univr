.section .text
    .globl postfix
    .type postfix, @function
postfix:
    
    movl 4(%esp), %esi      #primo puntatore frase in input; source index
    movl 8(%esp), %edi      #secondo puntatore frase in output; destination index
    #%esi = indirizzo
    #(%esi) = carattere

    cmpb $0, (%esi)         #devo comparare il byte, prima va l'immediato e poi l'indirizzamento a memoria
    jnz algo
    jz errore

algo:

    conta:
    #fare la pop di un numero prima di riceverne un altro senno nello stack si hanno 3 numeri 
        #se all'inzio abbiamo solo numeri è utile controllare anche addizione, moltiplicazione e divisione?
        #controllo addizione
        cmpb $43, (%esi)        #+
        jz addizione

        #controllo sottrazione
        cmpb $45, (%esi)        #- 
        jz negativo
        
        #fare qaulcosa dopo la compare oppure trasferirte il tutto in ustampan atra label
        
        #controllo moltiplicazione
        cmpb $42, (%esi)        #*
        jz moltiplicazione

        #controllo divisione
        cmpb $47, (%esi)        #/
        #
        jz divisione


        #controllo se è un numero
controllo_numerico:
        cmpb $48, (%esi)
        jge controllo       #giusto
        jl errore

torna:  #ciclo per prendere tutto il numero
        movl (%esi), %eax

        #algo da completare

torna2:
        
        cmpb $32, (%esi)        #spazio
        jnz conta2
        #se è uno spazio incremento esi e vado al carattere successivo(?)

conta2:
        mul 10
        add (%esi), %eax

        inc %esi
        cmpb $32, (%esi)
        jnz conta2
        #qui devo controllare se la nuova cifra è ancora un numero valido senno è errore

inc %esi
cmpb $0, (%esi)
jnz exit

controllo:
    cmpb $57, (%esi)
    jle torna
    jg errore

addizione:
    #da fare la pop prima
    addl %ebx, %eax
    jmp torna

sottrazione:
    subl %ebx, %eax
    jmp torna

moltiplicazione:

    jmp torna
divisione:

    jmp torna


negativo:
    inc %esi
    cmpb $32, (%esi)        #spazio
    jz sottrazione
    jnz controllo_numerico


errore:
#uso questo metodo per inserire nell'output
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

exit:#da sistemare
    movl %eax, (%edi)   #scrivo il risultato sul file di output !!!ma come stringa !! da sistemare
    inc %edi
    movl $0, (%edi)         #scrivo 0 in edi che è anche il carattere di terminazione

    ret
