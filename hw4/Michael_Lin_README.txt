- Michael Lin (QL38)
- 30 hours
- Didn't work with anyone
- Asked for help during recitation
- processor is NOT in "main" but in "processor"
- input: the keyboard is in the subcircuit "input" labeled "key" in the processor.
	To input an ASCII character, right click on the "key" subcircuit, click "View input",
	then poke the keyboard to enter the character. Double click on the "processor" circuit to
	return to the circuit. Do all of this before starting the clock on the processor.
- clock and reset: located half way down on the left side. To reset, poke the reset input twice (1, 0)
- No bugs to my knowledge, only thing is when program hits the instruction "halt", PC persists at the most
	recent number (e.g. 001a for "simple.s") and does not become 0000, as "simple.sim" suggests.