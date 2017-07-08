Thomas Sowders

**Lexathon: Report**

**CS 3340.001**

**         a) A description of the program**

The program is a MIPS written version of the game Lexathon. It is mostly written in a procedural style, the team did not use the typical approach where you would break the program up into separate pieces, and build up the functionality in a modular fashion. The team decided to build the program procedurally because of the speed of development that procedural-style programming presents itself with. The program is structured in 5 main parts: (1)Allocating the buffer and reading the file into the buffer (2) Selecting the keyword, (3) Picking middle character of keyword (4) create a list of valid matches (5) Getting User input and executing accordingly. All other code supports these 5 main functions.

**b) The challenges that you and your team had  and how did you or the team overcome them**

Communication and planning were major challenges, but fortunately everyone was very invested in creating a high-quality product. We used Slack and Github for planning and version control, making heavy use of the Github issue tracker. Team members posted descriptions of features that needed to be implemented, then could comment on upcoming features, claim tasks to work on, and track the project’s progress as a whole.

**c) What you have learned by doing the project**

Personally, I have used assembly before (for microcontrollers), but this is certainly the largest project I’ve undertaken in assembly. I learned a lot about how tightly-optimized key loops can be when using assembly. If we’d tried to make this program in Java or Python, it would probably have taken many orders of magnitude more resources to execute. 

I also learned that assembly is very slow to write, and very hard to debug. It gives me a new appreciation for the conveniences of high-level languages.

**d) a discussion about algorithms and techniques used in the program**

Techniques:

One technique we used was pre-computation. We used other software (namely, grep) to prepare a list of all the nine-letter english words, so that Lexathon would not need to re-compute this list every time it ran. This improved our load time significantly.

Another technique we used heavily is pointer arithmetic. The program must consider every word in the English language to display a list of valid solutions, and uses careful pointer arithmetic to traverse the large buffer of all English words. To ensure that the pointer arithmetic remained aligned with the list of words (despite the words having variable length), we used padding spaces to make each line the same length. The algorithm for this comparison is described below.

Algorithms: 

The key algorithm for compiling a list of solutions involves iterating over the list of English words to find which ones are valid anagrams. To do this, the program iterates over three nested for-loops. The outer loop counts the lines of the text file, the middle loop iterates over each character in the line, and the inner loop looks at the characters of the secret keyword.

The algorithm starts by comparing the first character of the first line to the letters of the keyword. If the letters match, we mark that character of the keyword as used and continue to the next character. If we ever reach the end of the list of keyletters without finding an available match, we skip to the next word. However, if we reach the end of the word we’re trying without encountering any failures, we add the word to the list of solutions.

A very similar variant of this structure is used again later to check if the user’s input matches a valid solution. 

**e) contributions of each team member**

         **Alec:** Implemented beginning instruction functionality, welcome messages, special command functionality (what happens when user wants to create a new puzzle or quit)

**Evan:** Generating 3x3 puzzle matrix, shuffling algorithm, primary code debugger/fixed undesired results, clearing buffers for new puzzle

**Salman:** Implemented key character functionality, alreadyMatched functionality to prevent the program from accepting already found words, additional debugging, word counter

**Thomas:** Initial program design, opening and reading of the files, buffer allocation and structure, user input, and matching algorithms.

**         f) any suggestions you may have**

Because this project was due at the end of the semester, we spend a lot of time working on assembly programming after it’s no longer the main focus of the course or its exams. Moving the due-date forward a few weeks would probably be beneficial to most groups. 

**2. A short video clip demonstrating the program in action. **

**	****[https://www.youtube.com/watch?v=oYtgH3-aja**Y](https://www.youtube.com/watch?v=oYtgH3-ajaY)

**	**

**3. All code that are needed to run your program.**

These are the required files, located in the zip file:

lexathon.asm

words.txt

Nines.txt

If the code generates an error, this is most likely due to being unable to find and open words.txt or nines.txt.  If so, attempt to place these two files in the working directory of your MARS simulator program (For example, if your MARS program is located inside /computer/thisfolder/MARS-4.5, try placing the files inside /computer/thisfolder/.

**4. A user manual on how to run and how to use the program.**

## User Manual

To run Lexathon, place the files lexathon.asm, words.txt, and nines.txt in a single directory, then run lexathon.asm using MARS.

Lexathon creates a puzzle by randomly choosing a secret nine-letter English word, then displaying its letters in a grid. The solution to the puzzle is to enter other English words that are anagrams of the secret keyword and must include the center character of the grid. Only words with four or more characters are valid solutions. Use the command line to type guesses. Guesses must be entered using only capital letters.

Lexathon recognizes three special commands:

**/S or /s - ** This command shuffles the letters in the grid. This may help to find more solutions.

**/N or /n -** This command ends the current puzzle and begins a new one. Your score and all possible solutions will be displayed.

**/Q or /q - **This command quits the game. Your score and all the solutions to your current puzzle will be displayed.  

