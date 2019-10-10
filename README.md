# Generative poetry based on CI

## Sensors
Using Raspberry Pi 4: [Adafruit_MPR121](https://circuitpython.readthedocs.io/projects/mpr121/en/latest/index.html)

(old) Tests using Arduino: Requires libraries [Adafruit_MPR121](https://github.com/adafruit/Adafruit_MPR121) and [CapacitiveSensor](https://playground.arduino.cc/Main/CapacitiveSensor/)

## Visualization
Uses Processing, requires library [oscP5](http://www.sojamo.de/libraries/oscP5/)


## Notes for its creation

- Making the rails into capacitive sensors -> play sounds. Our own mini CI system. Touching different rails adds different predefined "commits" sort of like an L-system rule. The result is sonified. Sometimes it randomly fails? Speaker in the center of the hole. Ambiance sounds.
- Make it actually use Travis in a GitHub repo!
- A small program failes the build if the .txt file is in a certain state.
- LED strip (around the bottom of the hole?) to indicate the state of the CI process.
- Explain the metaphor.

"Text file":
- Should be sonifiable ->
- Text that makes sense, that creates like a poem.
- Follow some kind of syntax? So that it can fail?
- It should be able to fail.
- Different lists of words depending on rail?

6 rails add and 6 rails delete words.

Keep a history of all the changes etc.