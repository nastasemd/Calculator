.model small
.stack 100h
.data
	expr db 6 dup('$')
	adn db '+'
	scd db '-'
	inm db '*'
	imp db '/'
	res db '%'
	ero db 13,10,'Operatie nedefinita.Introduceti expresia din nou.',13,10,'$'
	mii db ?
	sute db ?
	zeci db ?
	unitati db ?
	aux1 db ?
	aux2 db ?
	newln db 13,10,'$'
	rez db '=    $'
.code
	mov ax,@data
	mov ds,ax
citire:
	mov bx,0 ; Citire expresie.Doar numere pozitive mai mici decat 100.
	mov cx,5 ; Cele mai mici decat zece se citesc sub forma 01,02,03,....,09.
	mov ah,3fh
	mov dx,offset expr
	int 21h
	mov bh,expr+2 ; Verific semnul expresie
	cmp bh,adn  ; Daca este +
	je adun
	cmp bh,scd ; Daca este -
	je scad
	cmp bh,inm ; Daca este *
	je inmul
	cmp bh,imp ; Daca este /
	je inmpar
	cmp bh,res ; Daca este %
	je modul
	mov bh,expr
	cmp bh,'s' ; Daca primul caracter este 's' se termina programul
	je sfarsit
	jmp eroare ; Operatie nedefinita
adun:
	call binar ; Formez cele 2 numere in format binar
	call adunare ; Adun cele 2 numere
	jmp afisare ; Afisez rezultatul
scad:
	call binar ; Formez cele 2 numere in format binar
	call scadere ; Scad cele 2 numere
	jmp afisare ; Afisez rezultatul
inmul:
	call bcd ; Formez cele 2 numere in format BCD
	call inmultire ; Inmultesc cele 2 numere
	jmp afisare ; Afisez rezultatul
inmpar:
	call binar ; Formez cele 2 numere in format binar
	call impartire ; Impart cele 2 numere
	jmp afisare ; Afisez rezultatul
modul:
	call binar ; Formez cele 2 numere in format binar
	call modulo ; Restul impartirii celor 2 numere
	jmp afisare ; Afisez rezultatul
eroare:
	mov ah,9h ; Afisare mesaj eroare si intoarcere la citire
	mov dx,offset ero
	int 21h
	jmp citire ; Citesc alta expresie
afisare:
	mov ah,9h ; Afisare rezultat din variabila rez
	mov dx,offset rez
	int 21h
	mov ah,9h ; Afisare linie noua
	mov dx,offset newln
	int 21h
	mov rez,'=' ; Resetare rezultat
	mov rez+1,' '
	mov rez+2,' '
	mov rez+3,' '
	mov rez+4,' '
	mov rez+5,'$'
	jmp citire ; Citesc alta expresie
sfarsit:
	mov ah,4ch ;Stop program
	int 21h
; Functii
binar: ; Transformare numere din expresie in format Binar
	mov ch,expr ; Formare primul numar in format binar
	and ch,0fh
	mov cl,ch
	shl ch,3
	shl cl,1
	add ch,cl
	mov cl,expr+1
	and cl,0fh
	add ch,cl ; Primul numar in format binar este salvat in ch
	mov cl,expr+3 ; Formare al doilea numar in format binar
	and cl,0fh
	mov dh,cl
	shl cl,3
	shl dh,1
	add cl,dh
	mov dh,expr+4
	and dh,0fh
	add cl,dh ; Al doilea numar in format binar este salvat in cl
	ret
bcd: ; Transformare numere din expresie in format Binar
	mov ch,expr ; Formare primul numar in format BCD
	and ch,0fh
	shl ch,4
	mov cl,expr+1
	and cl,0fh
	or ch,cl ; Primul numar in format BCD este salvat in ch
	mov cl,expr+3 ; Formare al doilea numar in format BCD
	and cl,0fh
	shl cl,4
	mov dh,expr+4
	and dh,0fh
	or cl,dh ; Al doilea numar in format BCD este salvat in cl
	ret
scadere: ; Scadere
	cmp ch,cl ; Verific care numar este mai mare.Pentru a nu lucra cu semn(bit cel mai semnificativ)
	jge scad1 ; Daca primul numar este mai mare sau egal decat al doilea
	jmp scad2 ; Daca primul numar este mai mic decat al doilea
scad1:
	mov al,ch ; Pun in al primul numar in format binar
	sub al,cl ; Scad din acesta al doilea numar in format binar
	xor ah,ah ; Facem 0 in ah
	xor bh,bh  ;Facem 0 in bh
	mov bl,10 ; Trecere in baza 10
	div bl
	add al,30h ; Formez cifra zecilor in format ASCII
	add ah,30h ; Formez cifra unitatilor in format ASCII
	mov rez+1,al ; Cifra zecilor
	mov rez+2,ah ; Cifra unitatilor
	ret
scad2:
	mov al,cl ; Pun in al al doilea numar in format binar
	sub al,ch ; Scad din acesta primul numar in format binar
	xor ah,ah ; Facem 0 in ah
	xor bh,bh ; Facem 0 in bh
	mov bl,10 ; Trecere in baza 10
	div bl
	add al,30h ; Formez cifra zecilor in format ASCII
	add ah,30h ; Formez cifra unitatilor in format ASCII
	mov dh,scd ; Semnul '-' in fata cifrelor de mai sus
	mov rez+1,dh ; Semnul '-'
	mov rez+2,al ; Cifra zecilor
	mov rez+3,ah ; Cifra unitatilor
	ret
adunare: ; Adunare
	mov al,ch ; Pun in al primul numar in format binar
	add al,cl ; Adaug al doilea numar in format binar
	xor ah,ah
	cmp ax,99 ; Verific daca este mai mare decat 99(3 cifre)
	jg adn1 ; Daca da
	jmp adn2 ; Daca nu
adn1:
	xor bh,bh ; Facem 0 in bh
	mov bl,10 ; Formez numarul in baza 10
	div bl
	sub al,10 ; Din cat scad 10, pentru a avea doar cifra zecilor
	add al,30h ; Formez cifra zecilor in format ASCII
	add ah,30h ; Formez cifra unitatlor in format ASCII
	mov rez+1,31h ; Punem 1 pe pozitia sutelor.
	mov rez+2,al ; Cifra zecilor
	mov rez+3,ah ; Cifra unitatilor
	ret
adn2:
	xor bh,bh ; Facem 0 in bh
	mov bl,10 ; Formez numarul in baza 10
	div bl
	add al,30h ; Formez cifra zecilor in format ASCII
	add ah,30h ; Formez cifra unitatilor in format ASCII
	mov rez+1,al ; Cifra zecilor
	mov rez+2,ah ; Cifra unitatilor
	ret
inmultire: ; Inmultire
	mov al,ch
	and al,0fh ; A doua cifra din primul numar
	mov bl,cl
	and bl,0fh ; A doua cifra din al doilea numar
	mul bl ; Le inmultesc
	mov bl,10 ; Trecere in baza 10
	div bl
	mov dh,ah 
	add dh,30h
	mov unitati,dh ; Cifra unitatilor este salvata in format ASCII
	mov dh,al ; Daca rezultatul inmultirii este mai mare decat 10 se salveaza prima cifra
			  ; Pentru a fi folosita mai departe la adunare
	mov al,ch
	shr al,4 ; Prima cifra din primul numar
	mov bl,cl
	and bl,0fh ; A doua cifra din al doilea numar
	mul bl ; Le inmultesc
	add al,dh ; Adaug "numarul care se tine minte" rezultat din inmultirea de mai sus
	mov bl,10 ; Trecere in baza 10
	div bl
	mov aux1,ah ; Cifra zecilor rezultata din inmultirea de mai sus este salvata pentru adunare
	mov aux2,al ; Cifra sutelor rezultata din inmultirea de mai sus este salvata pentru adunare
	mov al,ch
	and al,0fh ; A doua cifra din primul numar
	mov bl,cl
	shr bl,4 ; Prima cifra din al doilea numar
	mul bl ; Le inmultesc
	add al,aux1 ; Adaug cifra zecilor de la prima inmultire
	mov bl,10 ; Trecere in baza 10
	div bl
	mov dh,ah
	add dh,30h
	mov zeci,dh ; Cifra zecilor este salvata in format ASCII
	mov aux1,al ; Salvez cifra zecilor de la a doua inmultire
	mov al,ch
	shr al,4 ; A doua cifra din primul numar
	mov bl,cl
	shr bl,4 ; A doua cifra din al doilea numar
	mul bl ; Le inmultesc
	add al,aux2 ; Adaug cifra sutelor de la prima inmultire
	add al,aux1 ; Adaug cifra zecilor de la a doua inmultire
	mov bl,10 ; Trecere in baza 10
	div bl
	mov dh,ah
	add dh,30h
	mov sute,dh  ;Cifra sutelor este salvata in format ASCII
	add al,30h
	mov mii,al ; Cifra miilor este salvata in format ASCII
	and al,0fh
	cmp al,0 ; Verific daca cifra miilor este egala cu 0
	je afisinm1 ; Daca da, nu afisez cifra miilor
	jmp afisinm2 ; Daca nu, afisez cifra miilor
afisinm1:
	and dh,0fh
	cmp dh,0  ; Verific daca cifra sutelor este egala cu 0
	je afisinm3 ; Daca da, nu afisez cifra sutelor
	mov dh,sute ; Cifra sutelor
	mov rez+1,dh
	mov dh,zeci ; Cifra zecilor
	mov rez+2,dh
	mov dh,unitati; Cifra unitatilor
	mov rez+3,dh
	ret
afisinm3:
	mov dh,zeci ; Cifra zecilor
	mov rez+1,dh
	mov dh,unitati ; Cifra unitatilor
	mov rez+2,dh
	ret
afisinm2:
	mov dh,mii ; Cifra miilor
	mov rez+1,dh
	mov dh,sute ; Cifra sutelor
	mov rez+2,dh
	mov dh,zeci ; Cifra zecilor
	mov rez+3,dh
	mov dh,unitati ; Cifra unitatilor
	mov rez+4,dh
	ret
impartire: ; Impartire
	cmp cl,0 ; Verific daca al doilea numar este 0
	je erorimp
	jmp impart
erorimp:
	mov rez+1,'I' ; In rezultat pun mesajul Imposibil
	mov rez+2,'m'
	mov rez+3,'p'
	mov rez+4,'o'
	mov rez+5,'s'
	mov rez+6,'i'
	mov rez+7,'b'
	mov rez+8,'i'
	mov rez+9,'l'
	mov rez+10,'$'
	ret
impart:
	mov al,ch ; Pun in al primul numar
	xor ah,ah ; Fac 0 in ah
	xor bh,bh ; Fac 0 in bh
	mov bl,cl ; Pun in bl al doilea numar
	div bl ; Le impart
	mov dh,ah ; Salvez restul
	xor ah,ah ; Fac 0 in ah
	mov bl,10 ; Trecere in baza 10 a catului
	div bl
	add al,30h ; Prima cifra a catului
	add ah,30h ; A doua cifra a catului
	mov rez+1,al
	mov rez+2,ah
	mov rez+3,' '
	mov rez+4,'r'
	mov rez+5,'e'
	mov rez+6,'s'
	mov rez+7,'t'
	mov rez+8,' '
	mov al,dh ; Pun in al restul primei impartirii
	xor ah,ah ; Fac 0 in ah
	div bl ; Trecere in baza 10 a restului
	add al,30h ; Prima cifra a restului
	add ah,30h ; A doua cifra a restului
	mov rez+9,al
	mov rez+10,ah
	mov rez+11,'$'
	ret
modulo:; Modulo
	cmp cl,0 ; Verific daca al doilea numar este 0
	je eror
	cmp ch,cl ; Verific daca primul numar este mai mic decat al doilea
	jl zero
	jmp nzero
eror: ; Daca al doilea numar este 0 afisez imposibil
	mov rez+1,'I'
	mov rez+2,'m'
	mov rez+3,'p'
	mov rez+4,'o'
	mov rez+5,'s'
	mov rez+6,'i'
	mov rez+7,'b'
	mov rez+8,'i'
	mov rez+9,'l'
	mov rez+10,'$'
	ret
zero:
	mov al,ch ; Daca al doilea numar este mai mare decat primul se afiseaza primul numar
	xor ah,ah
	xor bh,bh
	mov bl,10 ; Trecere in baza 10
	div bl 
	add al,30h ; Cifra zecilor in format ASCII
	add ah,30h ; Cifra unitatilor in format ASCII
	mov rez+1,al ; Cifra zecilor
	mov rez+2,ah ; Cifra unitatilor
	ret
nzero:
	mov al,ch ; Punem in al primul numar
	xor ah,ah ; Facem 0 in ah
	xor bh,bh ; Facem 0 in bh
	mov bl,cl ; Punem in bl al doilea numar
	div bl ; Le impartim
	mov al,ah ; Restul impartirii il punem in al
	xor ah,ah ; Facem 0 in ah
	mov bl,10 ; Facem transformare in baza 10
	div bl
	add al,30h ; Cifra zecilor in format ASCII
	add ah,30h ; Cifra unitatilor in format ASCII
	mov rez+1,al ; Cifra zecilor
	mov rez+2,ah ; Cifra unitatilor
	ret
end