.data

ninesfilename: .asciiz "nines.txt"
ninesbufferstart: .word 0
ninesfiledescriptor: .word 1
sizeofninesfile: .word 0

wordsfilename: .asciiz "words.txt"
wordsbufferstart: .word 0
wordsfiledescriptor: .word 0
sizeofwordsfile: .word 0
keyword: .asciiz "XXXXXXXXX"

matchesFound: .word 0 #counts by 10
matches: .space 5000

.text

opennines: #Prepare to open the nines file.
li $v0, 13
la $a0 ninesfilename
li $a2 0 #read only
syscall #Open nines file
sw $v0 ninesfiledescriptor

openwords: #Prepare to open the words file.
li $v0, 13
la $a0 wordsfilename
li $a2 0 #read only
syscall #OpenWords File
sw $v0 wordsfiledescriptor


li $v0, 9
li $a0, 100000
syscall #Allocate buffer memory for nines file
sw $v0 ninesbufferstart

readNines: #loads the file contents into the buffer
li $v0 14
lw $a0, ninesfiledescriptor
lw $a1, ninesbufferstart
li $a2, 100000
syscall #load nines file into buffer
sw $v0 sizeofninesfile

#close the nines file
lw $a0, ninesfiledescriptor
li $v0, 16
syscall #close nines file


#Allocate buffer memory for words file
li $v0, 9
li $a0, 400000
syscall #Allocate buffer memory for words file
sw $v0 wordsbufferstart

readWords: #loads the file contents into the buffer
li $v0 14
lw $a0, wordsfiledescriptor
lw $a1, wordsbufferstart
li $a2, 400000
syscall #loads the words file contents into the buffer
sw $v0 sizeofwordsfile



##TODO: Random nine letter word
#Store the chosen nine letter word into keyword
selectKeyword:
li $t0, 0 ##TODO: SELECT A RANDOM NUMBER FOR t0, the line number
mul $t0, $t0, 10
lw $t1, ninesbufferstart
addu $t1, $t1, $t0
li $t7, 0 #loop counter
copyKeywordLoop:
addu $t2, $t1, $t7
lbu $s0, ($t2)
sb $s0, keyword($t7)
addi $t7, $t7, 1
bne $t7, 10, copyKeywordLoop


##############################################

#Open nines file

#open allwords file

#open words file?

#read a line from nines, save it (nine letter word)

#line: for each line in allwords{
#  char: for each character in that line{
#    match: for each character in keyword{
#       if(already used this letter) continue;
#       [else]
#         mark letter as used
#         continue char
#    out of keyletters? goto next line
#  out of chars? add to solutions
#out of lines? stop.

lw $s0, wordsbufferstart
li $s1, 0 # Word line counter (counts by ten)
li $s2, 0 # Word char counter
li $s3, 0 # Used Characters
li $s4, 1 # Current Key Mask
li $s5, 0 # Current Key Char Position
li $t7, 42 # Word Char (*)
li $t6, 35 # Key Char (#)



j line #Don't increment before first line

nextline:
addi $s1, $s1, 10 # increment word line couner
line:
li $s2, 0 # Word char counter
li $s3, 0 # Used Characters
lw $t9, sizeofwordsfile #load list size
bge $s1, $t9, outofwords #are we at the end of the list?

j char #Don't increment before first char

nextchar:
addi $s2, $s2, 1
char:
li $t9, 9
beq $s2, $t9, matchfound #If we're on EOL char , match found
li $t5, 0 #->Word Char Address
move $t5, $s0 #->Buffer start
add $t5, $t5, $s1 #->Line start
add $t5, $t5, $s2 #->Char Position
lbu $t7, ($t5) #Get Word Char
li $t9, 32 # Load space character
beq $t9, $t7, matchfound # If we reached a space, we have a match
li $s4, 1 # Set Key Position Mask Bit 
li $s5, 0 # Reset Key position
j key #Skip incrementing before first key char 

nextkey:
addi $s5, $s5, 1 #add 1 to key offset
sll $s4, $s4, 1 # shift used letter key mask

key:
li $t9, 9
beq $t9, $s5, nextline #Char not in key, word fails

and $t9, $s3, $s4 #has this char position been used?
bnez $t9 nextkey #if so, skip

lb $t6, keyword($s5)
bne $t6, $t7 nextkey #if char != keychar, try next keychar
nop #KEY CHAR MATCHES!
or $s3, $s3, $s4 #note which character matches
j nextchar

matchfound:
nop #  MATCH FOUND
#Copy the matched line into the matches buffer
li $t9, 0 # Loop Counter
copyloop:
move $t5, $s0 #->Buffer start
add $t5, $t5, $s1 #->Line start
add $t5, $t5, $t9 #->Char Position
lbu $t7, ($t5) #Get Word Char
la $t5, matches
lw $t6, matchesFound
add $t5, $t5, $t6
add $t5, $t5, $t9
sb $t7, ($t5)

addi $t9, $t9, 1
li $t8, 10
bne $t8, $t9, copyloop

lw $t9, matchesFound
addi $t9, $t9, 10#increment matchesfound
sw $t9, matchesFound
j nextline

outofwords:
nop #OUTOFWORDS