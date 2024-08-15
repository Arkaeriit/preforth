\ The next few words are used to let you read or write
\ a single char on a file.
VARIABLE IOCHAR_BUFF
: READ-CHAR ( fileid -- c ior ) IOCHAR_BUFF SWAP 1 SWAP READ-FILE SWAP 0= OR IOCHAR_BUFF C@ SWAP ;
: WRITE-CHAR ( c fileid -- ior ) SWAP IOCHAR_BUFF C! IOCHAR_BUFF SWAP 1 SWAP WRITE-FILE ;

\ error-exit display a message to stderr and then quit the program
\ with the exit status -1
: error-exit ( addr u -- ) stderr WRITE-FILE CR -1 (bye) ;

\ Debuguing words
\ Print th top of the stack
: .? DUP . ;
\ Print the top of the stack as a char
: .c? DUP EMIT SPACE ;
\ Print the two first element of the stack
: .?? 2DUP . . ;
\ Print the 3 first element on the stack
: .??? .? >R .? >R .? R> R> ;

\ Helping words
\ Copy the content of fileid1 into fileid2
: copy-file ( fileid1 fileid2 -- ) BEGIN 2DUP SWAP READ-CHAR DUP >R 0= IF SWAP WRITE-CHAR DROP ELSE THEN R> UNTIL 2DROP 2DROP ;
\ Some bad implementation of READ-LINE
\ ior is alway 0 and flag is 1 if we reached the end of the file
\ or 0 if we reached the end of a line first
: _READ-LINE ( addr1 u1 fileid -- u2 flag ior ) 
0 ROT 0 DO  ( The stack is addr1 fileid u2 )
    SWAP DUP READ-CHAR IF DROP SWAP NIP NIP -1 0 UNLOOP EXIT THEN DUP 10 = IF DROP SWAP LEAVE THEN >R  ( The stack is now addr1 u2 fileID )
    SWAP 1+ ROT DUP R> SWAP C! 1+ ( the stack is fileid u2 addr1 and everything is up to date )
    ROT ROT 
LOOP SWAP DROP SWAP DROP 0 0 ;
\ compare two string, return 0 if there are equals. return 1 otherwize
: _COMPARE ( addr1 u1 addr2 u2 -- n ) ROT 2DUP = IF 
    DROP 0 SWAP 0 DO
        DROP 2DUP C@ SWAP C@ = 0= IF 1 LEAVE THEN 1+ SWAP 1+ 0 LOOP
    SWAP DROP SWAP DROP
    ELSE 1 THEN ;

\ Interface words
\ Open the two input files given as arguments and check if everything is OK
: init-files ( -- fileid1 fileid2 ) 1 arg R/O OPEN-FILE 2 arg W/O CREATE-FILE ROT OR IF S" Error : argument files can't be read." error-exit THEN ;
\ Print an help message and exit
: help ( -- ) ." A Forth preprocessor." CR CR
." Usage : preforth <input file> <output file>" CR
." This program parse the input file, searching for some tags. If no tags are found at the beginning of a line the line is copied on the output file." CR
." List of tags:" CR
."    \ #IN filename : include non-recursively. Dump the content of filename in the output file." CR
."    \ #IR filename : include recursively. Process filename and put the result in the output file. Similar to #include in C preprocessors." CR
."    \ #SI : stop the inclusion. Stop the preprocessing of the file. Useful when used alongside #IR." CR BYE ; 
\ Check that the correct number of arguments is given
: testArgs ( -- ) argc @ 1 = IF help THEN argc @ 3 = 0= IF S" Error : invalid argument number." error-exit THEN ;

\ Input processing words
VARIABLE line_buffer 4095 CELLS ALLOT
\ Read a line and return the number of char read or -1 in case of an error
: read-line+ ( filed -- n ) line_buffer SWAP 4096 CELLS SWAP _READ-LINE DROP OVER 0= AND IF DROP -1 THEN ;
\ Check if we can read some tags in the begining of buffer.
\ If there is one the number of the tag is returned, otherwize 0 is returned
\ List of tags:
\ 1 : \ #IR : include a file recurcively
\ 2 : \ #IN : include a file non recurcively
\ 3 : \ #SI : stop the preprocessing of the curent file
: check-tag ( len -- tag ) 
4 > IF 
    line_buffer 6 S" \ #IR " _COMPARE 0= IF 1 ELSE
    line_buffer 6 S" \ #IN " _COMPARE 0= IF 2 ELSE
    line_buffer 5 S" \ #SI"  _COMPARE 0= IF 3 ELSE
    0 THEN THEN THEN
ELSE 0 THEN ;
VARIABLE buffer2 4095 CELLS ALLOT
\ Read everything after a tag and put it in buffer2 and return it's length
: readPostTag ( len1 -- len2 ) 6 - DUP line_buffer 6 + SWAP buffer2 SWAP CMOVE ;

\ Tag processing words
\ Dump the content of the file whose name is in buffer2 and length 
\ given as an argument into the file whose descriptor is given as an argument
: #IN ( fileid len -- ) buffer2 SWAP R/O OPEN-FILE 0= IF SWAP copy-file ELSE 2DROP THEN ;
\ Same as #IN but instead of using copy-file we use process
VARIABLE processXT \ Cette variable sert à stoquer l'execution token de process pour faire une récurtion
: #IR ( fileid len -- ) buffer2 SWAP R/O OPEN-FILE 0= IF SWAP processXT @ EXECUTE ELSE 2DROP THEN ;

\ Main functions
\ Process a line of fileid1 and put the reslt in fileid2
\ return 0 if everything if fine, 1 in case of an error or 2 if we ran into the #SI tag
: process-line ( fileid1 fileid2 -- n ) SWAP read-line+ DUP -1 = IF 2DROP 1 EXIT THEN DUP check-tag IF
    DUP check-tag DUP 
        2 = IF DROP readPostTag #IN ELSE DUP
        1 = IF DROP readPostTag #IR ELSE DUP
        3 = IF DROP 2DROP 2 EXIT 
        THEN THEN THEN
    ELSE SWAP DUP >R SWAP line_buffer SWAP ROT WRITE-FILE DROP 10 R> WRITE-CHAR DROP THEN 0 ;
\ Process fileid1 and put its content into fileid1
: process ( fileid1 fileid2 -- ) BEGIN 2DUP process-line UNTIL 2DROP ;
' process processXT !

: MAIN testArgs init-files process ;
main shift-args shift-args bye

