# Ambicycles
Ambicycles makes it easy to use Tidal Cycles with an ambisonics setup. With ambicycles you can place the sounds of your live coding session in a three dimensional sound field. The direction the sound is coming from is determined by two angles. These two angles (azimut and elevation) can be accessed as effect parameters directly from Tidal Cycles. You can make patterns of different angles similar to other effect paramteres in Tidal Cycles to create changing placements of the sounds. This version works with headphones only, but exchanging the decoder it should easily be adjustable for any ambisonics setup.

# Setup
1. Setup Tidal Cycles as described here: http://tidalcycles.org/docs/
2. Replace the Supercollider startup-file with the file "ambicycles_startup.scd"
3. Restart Supercollider
4. Declare Variables azim and elev in your Tidal file (You can use the file "ambicycles_example.tidal" if you like):

      let azim = pF "azim"

      let elev = pF "elev"

5. Now, you should be able to access azimut and elevation as effectparameters in Tidal like this:

      d1 $ sound "bd sd bd clap" # azim  "<0 1> [-1 0.4 -0.6]/3 <2 -1>" # elev "<1 -1.7> -0.25 0.5"
      
6. Similar to the values of pan in Tidal (-1=left, 0=middle 1=right), azim and elev values of 1 correspond to an angle of pi/2 in rad. Resulting in:

      azim: -1=left, 0=front 1=right, -2/2=back

      elev: -1=bottom, 0=middle, 1=top
      
      
# Conceptual structure
Ambicycles consists of a customized supercollider startup file based on the default one that comes with Tidal. It starts a multichannel instance of Tidals dirt-syntheziser. The number of channels is dependant on the ambisonic order you choose (the default is 2nd order). Choose the ambisonics order as well as the number of Tidal orbits regarding your needs and hardware resources.

After starting dirt. Ambicycles adds an effect module called "ambipan", which inherits the encoding stage. The effect uses the variables "azim" and "elev" in Tidal as parameters. Afterwards an Ndef "AmbiOut" is created and all OutBuses of the orbits are connected to it. At last the decoder is added to the tail of the server, getting it's input from "AmbiOut".

Ambicycles uses SC-HOA for de-/encoding. Any other ambisonics encoding should work as well. 

# ERROR: Message 'addModule' not understood.
Dirt has to be running before ambicycles tries to add the effect module "ambipan". If this error occurs Supercollider was probably trying to add the module while dirt was not yet running. There is a line in the codes that says "10.wait,". You can increase the number to make Supercollider wait longer before trying to add the module.
