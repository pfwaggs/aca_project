### Readme

a brief, one-line listing of contents.

- bin
	- ND2015_Digital_Cons.jsn : a json version of the cons from the website for testing
	- acapasswd.pl : test code to generate password to get current magazine
	- local_base.pl : a starting point for perl scripts
	- mk_jsn.pl : used to convert a downloaded puzzle file into a json structure
	- playkey.pl : some code to play with manipulating keys 
	- solve.pl : basic routine to solve puzzles 
	- temp_sols.jsn : an abbeviated message list from the cons file 

- etc
	- name_map.jsn : assigns first level keys (family name) from the cons.jsn file to give easier to read values (e.g. A => Aristocrat)

- lib
	- Ciphers.pm : routines for solving a given family
	- Menu.pm : generic routine to select an item from a list
	- Stats.pm : some very basic stat routines
	- Utilities.pm : some routines to manipulate strings, keys, matrices

- test
	- tcode.pl : some code to play with Test::More module
	- temp_sols.jsn : used by tcode to test with


A couple (?) years ago we had talked about making some software to assist in solving some messages in the bi-monthly magazine.  I finally decided to start working on some code for this project.  The first message family to tackle is the Aristocrats.  It should form the basis (in both code and experience) to work with many other family types.  Along with this, we should be able to leverage this code to assist with doing the Headline puzzles.

The current json structure is subject to improvement.  For now I read the local cons file (downloaded from the site)
and generate entries in the hash table based on message number (typically something like L+(-L+)*-N+ with L being a
letter and N being a number) with the message itself being a list structure.  The family is derived from the letter
portitions of the message number and the message key being the numerical part.  This is very simplistic and can be
modified for more utility.

One other thing included is a state key which starts off pointing to an undef.  When you start working on a message
this gets converted to an anonymous hash.  We store key/val pairs corresponding to guesses.  This way you can change
the value of a guess easily.  I am not tracking history, just state.  History could be tracked with a list.  But I think
that history is of little use at this point.  When you save the state this hash is preserved so on subsequent runs you can
restore the solution state automatically.

solve.pl is the main interface to accessing the family and message to work on.  I am intending to use Ciphers.pm to hold
the routines to manipulate data.  You can select a family (for testing the temp_sols.jsn file only has one message from
the Aristocrat family) then select a message to work on.  solve.pl then calles the routine based on the family choice
and passes the hash structure for that message to the routine.

From that point it is a series of commands and/or letter pairs to get to a solution.  Once finished the state (of all
messages for now) is saved in the original file (will change that later).

I guess you want to know what commands are available?

- stats : toggles stats on/off
- number : shows stats ordered by decreasing numerical value
- alpha : shows stats in alphabetical ordering
- quit : well, quits.

My testing is with the commands first then letter pairs.  Multiple letter pairs can be given but need to be separated by
':'.  I only have tested with just one string of letter pairs.  An example?  "stats ab:cd:ef" would toggle stats (starts
in on state) and make the substitions a->b, c->d and e->f.  You can clear a guess by just giving the key (i.e. a single
'a' would clear the substition value for 'a').  You could also do "number ab:cd:ef" and that would change the stats from
being alphabetical in order to numerical.  This lets you see the distribution in a decreasing order (with ties being
broken by the alphabet in decreasing order).  using the command 'alpha' restores the original view.  Yes, when this
starts it is in alphabetical order.  Easy to change that since it is just a string value to change.

Right now solve.pl is a single pass.  You can only work on one message then it exits.  I need to add some loop control to
the program to allow you to do more work.  Will probably add the ability to save the current state or revert to the last
version for that message.  Could do that for the message bundle as well.

There are no command line switches or options other than the message file (json).

For the Headline puzzles I would like to view the state of all the headlines (along with substitions) and allow you to
flip between each message when entering guesses.  That would be a characteristic in the Ciphers.pm file for Headline family.

