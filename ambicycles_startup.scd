({
	(
		// Ambisonic settings
		// set the order of ambisonic encoding here
		~ambi_order  = 2;
		~ambi_nHOA  = (pow(~ambi_order+1,2)).asInteger;

		// customized booting of dirt for ambisonics encoding of superdirt orbits
		s.reboot { // server options are only updated on reboot
			// configure the sound server: here you could add hardware specific options
			// see http://doc.sccode.org/Classes/ServerOptions.html
			s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
			s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
			s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
			s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
			s.options.numOutputBusChannels = ~ambi_nHOA; // set this to your hardware output channel size, if necessary
			s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
			// boot the server and start SuperDirt
			s.waitForBoot {
				//changeDefaultPanningFucntion
				// signals is an array of arbitrary size
				DirtPan.defaultPanningFunction = #{ | signals, numChannels, pan, mul, azim, elev |
					var channels, inNumChannels;
					// NOTE: later on, we should move these special cases to one single UGen
					switch(numChannels,
						1, {
							signals.sum * mul
						},
						2, {
							DirtPanBalance2.ar(signals, \span.ir(1), pan, mul)
						},
						{
							// default panning function for more than 2 channels
							/*DirtSplayAz.ar(
							numChannels,
							signals,
							\span.ir(1),
							pan,
							mul,
							\splay.ir(1),
							\panwidth.ir(2),
							\orientation.ir(0)
							)*/

							// summing channels to mono signal to be able to encode it
							var signal = Mix.ar(signals);
							signal
						}
					)
				};

				~dirt = SuperDirt(~ambi_nHOA, s); // two output channels, increase if you want to pan across more channels
				~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
				// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");

				//load user sound librarys
				~dirt.loadSoundFiles("C:/Users/Dell/Documents/Tidal Cycles/Samples/samples-extra/*");

				// s.sync; // optionally: wait for samples to be read
				~dirt.start(57120, 0 !4);   // start listening on port 57120, create two busses each sending audio to channel 0

				// optional, needed for convenient access from sclang:
				(
					~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
					~d4 = ~dirt.orbits[3];
				);
			};

			s.latency = 0.3; // increase this if you get "late" messages
		};
	);

	// waiting time before Supercollider tries to add effect module "ambipan"
	// increase the number if you get the ERROR: 'addModule' not understood.
	10.wait;
	"loading ambicycles".postln;

	// add effect module for encoding the orbits
	(
		~dirt.addModule('ambipan', { |dirtEvent|
			dirtEvent.sendSynth('ambipan' ++ ~dirt.numChannels,
				// OPTIONAL
				// passing this array of parameters could be left out,
				// but it makes it clear what happens
				[
					azim: ~azim,
					elev: ~elev,
					out: ~out
				]
			)
		},
		);
	);

	// make SynthDef for encoding the orbit
	(
		SynthDef("ambipan" ++ ~dirt.numChannels, { |out, azim=0, elev=0|

			// make azim and elev values of 1 correspond to an angle of pi/2 in rad
			var azimut = azim * 0.5pi;
			var elevation = elev * 0.5pi;
			var signal;

			signal = In.ar(out,~dirt.numChannels);
			signal = signal.sum;
			signal =HOAEncoder.ar(~ambi_order,signal,azimut,elevation);
			ReplaceOut.ar(out, signal);
		}).add;
	);

	(
		// routing of the decoding
		// create Ndef
		Ndef(\AmbiOut).ar(~dirt.numChannels);
		// route each orbit to Ndef
		~dirt.orbits.do { |each| each.outBus = Ndef(\AmbiOut).bus };

		// create SynthDef for decoding
		// decoder can be changed regarding the use case
		HOABinaural.loadbinauralIRs(s);
		SynthDef(\decoder,
			{
				|inbus=0|

				Out.ar(0, HOABinaural.ar(~ambi_order, In.ar(Ndef(\AmbiOut).bus, ~ambi_nHOA)));
			}
		).send
	);

	1.wait;

	// add decoder to the tail of the server
	~decoder = Synth(\decoder, [\inbus, Ndef(\AmbiOut).bus], s, addAction: 'addToTail');
	"ambicycles is ready now".postln;
}.fork;)

