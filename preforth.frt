\ The next few words are used to manipulate arguments.
\ They may not work depending on your forth inplementation
\ Give the number of arguments, including the name of the program
: argc ( -- n ) ARGS @ @ ;
\ Give the address to the array where the arguments are
: argv ( -- addr ) ARGS @ 1 CELLS + @ ;
\ Give the address of the nth argument
: (arg) ( n -- addr ) 1+ CELLS ARGS @ + @ ;
\ Give the length of the C string whose adress have been given
: strlen ( addr -- u ) DUP BEGIN DUP 1+ SWAP C@ 0= UNTIL 1- SWAP - ;
\ Give the address and the length of the nth argument
: arg ( n -- addr u ) (arg) DUP strlen ;

\ The next few words are used to let you read or write
\ a single char on a file.
VARIABLE IOCHAR_BUFF
: READ-CHAR ( fileid -- c ior ) IOCHAR_BUFF SWAP 1 SWAP READ-FILE SWAP 0= OR IOCHAR_BUFF C@ SWAP ;
: WRITE-CHAR ( c fileid -- ior ) SWAP IOCHAR_BUFF C! IOCHAR_BUFF SWAP 1 SWAP WRITE-FILE ;
\ The next definitions might vary according to your forth implementation
0 CONSTANT R/O
8 BASE ! 664 CONSTANT W/O DECIMAL

\ error-exit display a message to stderr and then quit the program
\ with theexit status -1
2 CONSTANT stderr
: error-exit ( addr u -- ) stderr WRITE-FILE 0 EXIT-CODE ! CR BYE ;

\ Interface words
\ Open the two input files given as arguments and check if everything is OK
: init-files ( -- fileid1 fileid2 ) 1 arg R/O OPEN-FILE 2 arg W/O CREATE-FILE ROT OR IF S" Error : argument files can't be read." error-exit THEN ;
\ Print an help message and exit
: help ( -- ) ." You did an oopsie." CR BYE ; 
\ Check that the correct number of arguments is given
: testArgs ( -- ) argc 1 = IF help THEN argc 3 = INVERT IF S" Error : invalid argument number." error-exit THEN init-files ;

: MAIN testArgs ;

