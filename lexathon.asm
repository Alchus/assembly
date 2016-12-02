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
keystring: .asciiz "X X X\nX X X\nX X X\n"

matchesFound: .word 0 #counts by 10
matches: .space 20000
alreadyMatched: .space 200
wordsLeft: .word 0



#####################################################################################
# INTRO SECTION (so user can see a welcome message while waiting for game to load!) #
#####################################################################################
intro: .asciiz "\nSalman Ahmad, Evan Remmele, Alec Salas, and Thomas Sowders present: \n\n\t\t\tL E X A T H O N ! ! !\n\n"
.text

#### You guys can delete this if you want, I added some intro sound ###
li $v0, 33 #MIDI out, synchronous
li $a0, 60  #pitch
li $a1, 333 #duration
li $a2, 17  #instrument
li $a3, 100 #volume
syscall

li $v0, 31  
li $a0, 48
li $a1, 1666
syscall
li $v0, 32 #sleep
li $a0, 333
syscall

li $v0, 31
li $a0, 60
li $a1, 333
syscall
li $v0, 32
li $a0, 333
syscall

li $v0, 31
li $a0, 67
li $a1, 1000
syscall
### Deletable section ###

li $t0, -1  # initial index of char (before incrementing)
introLoop:
li $v0, 32  # syscall for sleep
li $a0, 75 # wait 75 ms
syscall
li $v0, 11  # syscall for print char
addi $t0, $t0, 1 # increase index of char
lb $a0, intro($t0) # load char from string
syscall # print char
bne $t0, 96, introLoop # keep looping until string is exhausted

#reset registers... seemed not to work without this
li $v0, 0
li $a0, 0
li $a1, 0									#
li $a2, 0									#
li $a3, 0									#
#################################################################################

#####
#
#   BEGIN LOADING FILES
#
#####
opennines: #Prepare to open the nines file. (The file that contains the nine-letter words)
li $v0, 13
la $a0, ninesfilename
li $a2, 0 #read only
syscall #Open nines file
sw $v0, ninesfiledescriptor

openwords: #Prepare to open the words file. (All english words)
li $v0, 13
la $a0, wordsfilename
li $a2, 0 #read only
syscall #OpenWords File
sw $v0, wordsfiledescriptor

li $v0, 9
li $a0, 100000
syscall #Allocate buffer memory for nines file
sw $v0, ninesbufferstart

readNines: #loads the file contents into the buffer
li $v0, 14
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
li $v0, 14
lw $a0, wordsfiledescriptor
lw $a1, wordsbufferstart
li $a2, 400000
syscall #loads the words file contents into the buffer
sw $v0 sizeofwordsfile

###
# SELECT A RANDOM KEYWORD
###
#Store the chosen nine letter word into keyword
selectKeyword:
 ##TODO: SELECT A RANDOM NUMBER FOR $t0, the line number. 
li $v0, 42
li $a0, 0
lw $a1, sizeofninesfile
divu $a1, $a1, 10
syscall # Will throw an error if sizeofninesfile = -1 (caused if nines.txt is not read properly or not in folder)
addu $t0, $a0, $zero #selects A RANDOM NUMBER FOR t0, the line number
#The random value should be less than the number of nine-letter words in the file.
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

#select random char and swap into middle of keyword
li $v0, 42
li $a0, 0
li $a1, 8
syscall
lbu $t0, keyword($a0)
lbu $t1, keyword+4
sb $t0, keyword+4
sb $t1, keyword($a0)
 

#####
#
#   CREATE MATCHES LIST
#
#####

#the following section scans the list of English words to determine which of them can
# be made as anagrams of the chosen keyword (the nine-letter word).

#The algorithm is approximately equivalent to this pseudocode:

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
#do not add words that do not contain the key character
li $t0, 0
lbu $t1, keyword+4
matchloop:
move $t2, $s0
add $t2, $t2, $s1
add $t2, $t2, $t0
lbu $t2, ($t2)
xor $t3, $t1, $t2
beq $t3, 0, validWord
addi $t0, $t0, 1
bne $t0, 9, matchloop
j nextline

validWord:
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
addi $t9, $t9, 10 #increment matchesfound
sw $t9, matchesFound
lw $t9, wordsLeft
addi $t9, $t9, 1
sw $t9, wordsLeft
j nextline

outofwords:
lw $t0, welcomeDisplayed
bnez $t0, resetScore #if welcome message has already been displayed once this run, skip it
j listchecker

#################################################################################
#LIST CHECKER
#################################################################################
.data
filename: .asciiz "words.txt"
inpt: .asciiz "\nYour word: "
successmessage: .asciiz "\tWord is in puzzle!\n"
failmessage: .asciiz "\tWord is not in puzzle.\n"
alreadyfoundmessage: .asciiz "\tWord already found!\n"

inputbufferstart: .word 0

#Some lines for the welcome message, and indications of displayed data - Alec
welcome:  .asciiz "Welcome to Lexathon, coded in MIPS Assembly Language!\n"
welcome2: .asciiz "The instructions are simple, you will have 9 letters presented to you, and must make as many words as possible using the center letter.\n"
welcome3: .asciiz "The following escape sequences will perform certain functions you might find useful:\n"
welcome4: .asciiz "/s will shuffle the puzzle, leaving the center letter the same.\n"
welcome5: .asciiz "/q will quit the game and print out the solutions to the puzzle.\n"
welcome6: .asciiz "/n will generate a new puzzle without quitting the program, listing the previous puzzles solutions and printing the score.\n"
welcome7: .asciiz "Have fun! :)\n"

scoreIs:  .asciiz "Your score is: " 
scoreIs2: .asciiz "\tScore: "
score: .word 0
words:    .asciiz "Words left: "
quitting: .asciiz "Puzzle ended, we hope you had fun! Solutions displayed above (* Words not found).\n"

newPuzzle:     .asciiz "\nNow starting a new puzzle...\n\n"
congratulate1: .asciiz "CONGRATULATIONS!!! You have found all of the words!\n"
congratulate2: .asciiz "\n\tWould you like to play again? "
playagain: .space 10
welcomeDisplayed: .word 0



.text
listchecker:

Message:
#Output the welcome message
li $v0, 4
la $a0, welcome
syscall
la $a0, welcome2
syscall
la $a0, welcome3
syscall
la $a0, welcome4
syscall
la $a0, welcome5
syscall
la $a0, welcome6
syscall
la $a0, welcome7
syscall

#Reset the score
resetScore:
sw $zero, score

createPuzzle:
#create formatted string "keystring" for displaying puzzle
li $t0, 0
li $t1, 0
keystringLoop:
lb $t3, keyword($t0)
sb $t3, keystring($t1)
addi $t0, $t0, 1
addi $t1, $t1, 2
bne $t0, 9, keystringLoop
j shuffle

displayPuzzle:
#Print the characters of the puzzle in a 3-by-3 grid.
li $v0, 11
li $a0, '\n'
syscall
la $a0, keystring
li $v0, 4
syscall
jr $ra

getinput:
#Allocate buffer memory for user input
li $v0, 9
li $a0, 10
syscall
sw $v0 inputbufferstart

#print # words left and score
li $v0, 4
la $a0, words
syscall
lw $a0, wordsLeft
li $v0, 1
syscall
li $v0, 4
la $a0, scoreIs2
syscall
li $v0, 1
lw $a0, score
syscall
#ask for input
li $v0, 4
la $a0, inpt
syscall
#get input, write it to buffer
li $v0 8
lw $a0 inputbufferstart
li $a1 10
syscall

jal displayPuzzle

#pseudocode for checkMatch:
#for (t0= 10, t0 < size of file; t0+= 10){
#  for (t1 = 0; t1 < 10, t1 ++){
#    if (input[t1] = 0x10 && file[t0 + t1] = {0x10 or 0x20}) j inlist;
#    if (input[t1] != file[t0+t1] break;
#  } 
#}

li $t0 -10 #line counter. counts by 10. Starts at -10 so it will be incremented to 0.
#each line is 10 chars: The solution, padding spaces, and an 0x10 (LINEFEED) character.
next_line: 
addi $t0, $t0, 10 #increment line counter
lw $t2 matchesFound
slt $t3, $t0, $t2 # Are we past the end of the found matches buffer?
beqz $t3 notInList #if so, our search failed
li $t1 0 #char index counter
j _char
#Skip incrementing before the first char of each line
next_char: addi $t1, $t1, 1 #increment character index
_char: #check one char at a time

slti $t3, $t1, 10 #are we at the end of line?
beqz $t3 next_line #if so, continue outer loop (move to the next line)

move $s0, $0
lw $t6, inputbufferstart
add $t6, $t6, $t1 #address of input char
lbu $s0, ($t6) #input char is now in s0

checkEscape:
#Check if we have an excape character sequence.
bne $s0, 47, continueMatching
lbu $s0, 1($t6)
beq $s0, 83, shuffle
beq $s0, 115, shuffle
beq $s0, 81, quit
beq $s0, 113, quit
beq $s0, 'n', newGame
beq $s0, 'N', newGame
beq $s0, 'd', displayPuzzle
beq $s0, 'D', displayPuzzle

continueMatching:
move $s1, $0
la $t6, matches
add $t6, $t6, $t0 #ref line offset
add $t6, $t6, $t1 #ref char offset
lbu $s1, ($t6) #reference char (from matches) is now in s1

#declare a match if we are on the last char (which is a newline)
li $t9, 9
beq $t9, $t1, inList

#handle matching for strings under nine chars
li $t2 0x20 #space character
bne $t2, $s1 check_match
li $t2 10 #end of line character
bne $t2, $s0 check_match
j inList

#check for matching character
check_match:
beq $s0, $s1 next_char
bne $s0, $s1 next_line
#####################################################

inList:
# Checks and records if a word has already been found or not. 
# If it has already been found, prints according message.
#jal displayPuzzle
# load current word from match list
divu $t0, $t0, 10
lb $t2, alreadyMatched($t0) #current word matched
li $t1, 1
bnez $t2, alreadyFound
sb $t1, alreadyMatched($t0)
# check if all words have been found
lw $t2, wordsLeft
beqz $t2, congrats
addi $t2, $t2, -1
sw $t2, wordsLeft

success:
li $v0 4
la $a0, successmessage
syscall #print the success message.
lw $t0, score
addi $t0, $t0, 10 # add 10 points only when we get an accepted word
sw $t0, score
j getinput # return to ask for input again

#added "already used word" message - Salman
alreadyFound:
li $v0,4
la $a0,alreadyfoundmessage
syscall
j getinput

notInList:
li $v0 4
la $a0, failmessage
syscall
j getinput

# if user found all words, print summary congratulation message and ask if they would like to play again
congrats:
li $v0, 4
la $a0, congratulate1
syscall
la $a0, scoreIs
syscall
li $v0, 1
lw $a0, score #Move the score into a0, which is where the system expects the integer to be printed to be
syscall
li $v0, 4
la $a0, congratulate2
syscall
li $v0, 12
syscall
beq $v0, 'y', newGame2
beq $v0, 'Y', newGame2
j quit


#Called when /n is entered to ask for a new puzzle - Alec
newGame:
#We want a new game, so print the solutions of the old game and then start a new one
jal printSolutions
li $v0, 4
la $a0, quitting
syscall
la $a0, scoreIs
syscall
li $v0, 1
lw $a0, score #Move the score into $a0, which is where the system expects the integer to be printed to be
syscall
li $v0, 4
la $a0, newPuzzle
syscall
newGame2:
# skip welcome message next time 
addi $t0, $zero, 1
sw $t0, welcomeDisplayed
#j selectKeyword # In essence, restart game

# clear matches buffer out
lw $t0, matchesFound
mulu $t0, $t0, 10
clearingLoop:
addi $t0, $t0, -1
sb $zero, matches($t0)
bnez $t0, clearingLoop
sw $zero, matchesFound
sw $zero, wordsLeft
j selectKeyword #Select a different keyword for the generation of the new puzzle

shuffle:
# Appropriately shuffles all characters except middle character.
# Randomly swaps characters in the keystring, x times. 
li $t4, 0 # swap counter
li $a0, 0
li $a1, 8
li $v0, 42
notFour1:
syscall
beq $a0, 4, notFour1
sll $t0, $a0, 1
notFour2:
syscall
beq $a0, 4, notFour2
sll $t1, $a0, 1
lb $t2, keystring($t0)
lb $t3, keystring($t1)
sb $t2, keystring($t1)
sb $t3, keystring($t0)
addi $t4, $t4, 1
bne $t4, 10, notFour1 # adjust this line to adjust # of swaps (currently 10)
j getinput

quit:
#Handle a user's request to quit.
jal printSolutions
li $v0, 4
la $a0, quitting
syscall
la $a0, scoreIs
syscall
li $v0, 1
lw $a0, score #Move the score into a0, which is where the system expects the integer to be printed to be
syscall
li $v0 17
li $a0 0
syscall #Exit with code 0.


printSolutions: 
#li $v0 4
#la $a0, matches
#syscall
#jr $ra

#Prints the list of words in the puzzle, with asterisks next to unfound words
li $t0, 0
lw $t1, matchesFound
divu $t1, $t1, 10
matchingLoop:
lb $t2, alreadyMatched($t0)
bnez $t2, printSpace
li $v0, 11
li $a0, 42
syscall
printSpace:
li $v0, 11
li $a0, ' '
syscall
printWord:
li $v0, 11
li $a0, ' '
syscall
mul $t3, $t0, 10
addi $t2, $t3, 10
printWordLoop:
lb $a0, matches($t3)
syscall
addi $t3, $t3, 1
bne $t3, $t2, printWordLoop
addi $t0, $t0, 1
bne $t0, $t1, matchingLoop
jr $ra


#######################################################################
