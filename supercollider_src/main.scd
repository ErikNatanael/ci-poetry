(
~wordList = [];
~masterPoemLocked = false; // is set to true while a poet is committing a change to the master poem
)

// Receive serial data
(
var port = SerialPort.devices[0], // get the first serial device, assuming our device is the only one connected
// open a connection to the port specified above
p = SerialPort(
	port,
	baudrate: 115200,
	crtscts: true);

// this loop continuously reads the serial port above and parses its content
~readLoop = fork {
	var byte, str, res, values, sensors;
	loop{|i|

		// Arduino sends Windows style line breaks i.e. CR LF or as ascii numbers 13 10
		// Therefore, after ascii character 10 we know a new line is about to start so we record it
		if(p.read==10, {
			str = ""; // store all the characters in here
			// loop until we hit the CR i.e. ascii number 13
			while({byte = p.read; byte !=13 }, {
				str= str++byte.asAscii;
			});

			values = str.split($ ); // split the string into a list of values
			sensors = values.collect{ |val| val.asInteger; }; // convert from strings to integer numbers

			// update the state of all the sensors
		});
	};
};
)


(
~touchThreshold = 2000;
~delayUntilCommit = 3.0; // number of seconds of no touching until a change is committed to the master poem

// a pseudo-object factory to store poet info
~createPoet = { |index, wordList|
	( // create an Event similar to a javascript object
		// ----------------- variables
		index: index,
		wordList: wordList,
		poem: "", // the local version of the poem as edited by this poet
		active: false, // if the sensor is currently used for an active sequence i.e. has changes that have not been committed to master
		touched: false, // if the sensor is in the touched state
		touchStart: 0, // timestamp for when it last touched
		noTouchStart: 0, // timestamp for when it stopped being touched

		// ----------------- methods
		// this method is called whenever a new sensor value is received
		updateState: { | self, touchValue |
			if(touchValue >= ~touchThreshold, {
				// the sensor is being touched
				if(self.touched != true) {
					self.touched = true;
					self.touchStart = ~now.();
				};
			}, {
				// the sensor is not being touched
				if(self.touched != false) {
					var now = ~now.();
					// edit the poem based on how long the sensor was pressed
					self.editPoem(now - self.touchStart);
					self.touched = false;
					self.noTouchStart = ~now.();
				};
			});
		},
		// called at a set time interval
		update: { | self |
			if(self.active) {
				if(self.touched != true) {
					var now = ~now.();
					// if enough time has passed, commit the change to the master poem
					if( (now - self.noTouchStart) > ~delayUntilCommit) {
						// commit all changes to the master poem
						~commitChange.(self);
						// set to inactive
						self.active = false;
					};
				};
			};
		},
		startSequence: { | self |
			// copy file from master poem into its own copy of the file
			// read that copy into memory

			// set to active
			self.active = true;
		},
		editPoem: { | self, timeTouched |
			// apply a change to the poem

			// write the updated version to file
		},
	)
};

// helper functions

// returns the current time
// as separate function to allow us to use a different method later
~now = { SystemClock.seconds; };

~commitChange = { | poet |
	// lock the master file for changes (to avoid a race condition where two poets could try to commit a change simultaneously)
	~masterPoemLocked = true;
	// check for conflicts between local sensor version and master
	// If another poet has already edited a line which this poet edits, the commit fails. Otherwise it passes.

	// if the commit passes:
	// merge with master by transferring the changes this poet has made to those lines in the master poem

	// save master poem to disk

	// if the commit fails:
	// play a "commit failed" sound

	// unlock the master poem lock
	~masterPoemLocked = false;

	// trigger a new sonification if the commit passed
};
)

