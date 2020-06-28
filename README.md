# just-play

play just friends with midi

## requirements

- [norns](https://monome.org/docs/norns/)
- [crow](https://monome.org/docs/crow/)
- [just friends](https://www.whimsicalraps.com/products/just-friends?variant=5586981781533)

## documentation

- crow output 1 is a 10V trigger pulse (5ms) on each note
- crow output 2 is v/oct CV of the most recent note (0-10V or +/-5V)
- crow output 3 is the velocity of the most recent note (0-10V or +/-5V)
- crow output 4 is a MIDI CC value (0-10V or +/-5V, defaults to CC1)
- voltage range, midi CC and pitch bend range are configurable in the params menu
