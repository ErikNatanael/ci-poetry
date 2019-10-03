(
~wordList = ["computer", "night", "git", "far", "away", "get", "got", "gat", "stream", "fall"];
~masterPoemLocked = false; // is set to true while a poet is committing a change to the master poem
~masterPoemPath = "master/poem.txt".resolveRelative;
)

// Receive serial data
(
var port = SerialPort.devices[0], // get the first serial device, assuming our device is the only one connected
p;
SerialPort.closeAll(); // make sure all ports are closed before trying to open a new one
// open a connection to the port specified above
// throws an error if the port cannot be opened: ERROR: Primitive '_SerialPort_Open' failed.
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
			sensors.postln;

			// update the state of all the sensors
		});
	};
};
)


(
~touchThreshold = 2000;
~delayUntilCommit = 3.0; // number of seconds of no touching until a change is committed to the master poem

// ----------------------------------------------------------- EDIT ACTIONS

~addWord = { | poem, lineNumber, wordList |
	var lines, words, addPosition, lineString = "";
	// split poem into lines
	lines = poem.split($\n);
	("lines: " + lines).postln;
	words = lines[lineNumber].split($ );
	("words: " + words).postln;
	addPosition = rrand(0, words.size).floor(); // get random position where the word will be inserted
	words = words.insert(addPosition, wordList.choose()); // insert word into list
	// turn everything back into a flat string
	words.do{|word| lineString = lineString ++ word ++ " "; };
	("lineString: " + lineString).postln;
	lines[lineNumber] = lineString;
	poem = "";
	lines.do{|line| poem = poem ++ line ++"\n"; };
	poem
};


// ----------------------------------------------------------- POET FACTORY

// a pseudo-object factory to store poet info
~createPoet = { |index, wordList|
	var folder = ("poet" ++ index.asString ++ "/").resolveRelative;
	File.mkdir(folder); // creates the folder if it doesn't exist
	( // create an Event similar to a javascript object
		// ----------------- variables
		index: index,
		wordList: wordList,
		editActions: [~addWord], // a list of functions that
		poem: "", // the local version of the poem as edited by this poet
		localMaster: "", // the master version of the poem when this iteration of edits began
		folder: folder,
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
					if(self.active != true) {
						self.active = true;
						self.startSequence();
					};
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
		updatePoet: { | self |
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
		startSequence: { | self | var masterPoem, localMasterFile;
			// copy file from master poem into its own copy of the file
			masterPoem = File.readAllString(~masterPoemPath);
			localMasterFile = File.open(self.folder + "mastercopy.txt", "w"); // open a file and erase whatever might be in it
			localMasterFile.write(masterPoem);
			localMasterFile.close();
			self.localMaster = masterPoem; // save for later to avoid having to read it from file again
			self.poem = masterPoem; // initialise to the master poem
			self.savePoemToFile(); // bring the file up to date

			// set to active
			self.active = true;
		},
		editPoem: { | self, timeTouched |
			var editAction;
			// apply a change to the poem
			editAction = self.editActions.choose;
			// perform the edit and store the result back into self.poem
			self.poem = editAction.value(self.poem, self.index, self.wordList);
			// write the updated version to file
			self.savePoemToFile();
		},
		savePoemToFile: { | self | var file;
			// save this poet's version of the poem
			File.use(self.folder + "poem.txt", "w", { |f| f.write(self.poem) });
		},
	)
};

// helper functions

// returns the current time
// as separate function to allow us to use a different method later
~now = { SystemClock.seconds; };

~commitChange = { | poet | var diff;
	// lock the master file for changes (to avoid a race condition where two poets could try to commit a change simultaneously)
	~masterPoemLocked = true;
	// check for conflicts between local sensor version and master
	// If another poet has already edited a line which this poet edits, the commit fails. Otherwise it passes.

	diff = ("diff " ++ ~masterPoemPath + poet.folder ++ "poem.txt").unixCmdGetStdOut;
	("diff: " ++ diff).postln;

	// if the commit passes:
	// merge with master by transferring the changes this poet has made to those lines in the master poem

	// save master poem to disk

	// if the commit fails:
	// play a "commit failed" sound

	// unlock the master poem lock
	~masterPoemLocked = false;

	// trigger a new sonification if the commit passed
};

// ----------------------------------------------------------- INITIALISE

// create all the poets
~poets = 12.collect{ | i | ~createPoet.(i, ~wordList) };

// run poet update loop
{
	loop {
		~poets.do( { |poet| poet.updatePoet(); } );
		0.1.wait;
	}
}.fork;
)

// =========================================================== PLAYGROUND / TESTING
(
~simulateTouch = { |index, delayTime|
	{
		~poets[index].updateState(~touchThreshold);
		delayTime.wait;
		~poets[index].updateState(0);
	}.fork
};
)
(
~simulateTouch.(0, 0.5);
)
~poets[0].active