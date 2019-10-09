(
~initSonification = {
	"festival --server".unixCmd;
};
~sonifySuccess = {};
~sonifyFailed = {};
~sonifyTouch = {};

~poemTTSPath = "sonified/poem.wav".resolveRelative;
~ttsBuffer =
~sonifyPoem = {
	var cmd, outputPath = ~poemTTSPath;
	fork {
		// TTS generation of .wav file
		// this requires the festival server to be started by running 'festival --server' in a terminal
		cmd = "festival_client " ++ ~masterPoemPath ++ " --ttw --output "++ outputPath;
		cmd.systemCmd; // synchronous

		// read the TTS poem
		~ttsBuffer = Buffer.read(s, ~poemTTSPath, 0, -1);
		s.sync();
		~ttsBuffer.play;
	}
};

)
~initSonification.();
~sonifyPoem.()

( // SynthDefs
SynthDef(\sineperc, { var freq = \freq.kr(100), sig, env;
	env = EnvGen.kr(Env.perc(\atk.kr(0.1), \rel.kr(2), 1.0, [\c0.kr(2), \c1.kr(-2)]));
	freq = XLine.kr(freq * 2, freq, 0.05);
	sig = SinOsc.ar(freq) * 0.5 * \amp.kr(1);
	sig = sig * env;
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(0, sig);
}).add;
)
Synth(\sineperc, [\freq, 500, \atk, 0.05]);
Env.perc(1, 1, 1, [4, -2]).test.plot;