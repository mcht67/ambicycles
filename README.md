# Ambicycles
Ambicycles makes it easy to use Tidal Cycles with an ambisonics setup. With ambicycles you can place the sounds of your live coding session in a three dimensional sound field. The direction the sound is coming from is determined by two angles. These two angles (azimut and elevation) can be accessed as effect parameters directly from Tidal Cycles. You can make patterns of different angles similar to other effect paramteres in Tidal Cycles to create changing placements of the sounds. This version works with headphones only, but exchanging the decoder it should easily be ajustable for any ambisonics setup.

# Setup
1. Setup Tidal Cycles as described here: http://tidalcycles.org/docs/
2. Replace the Supercollider startup-file with the file "ambicycles_startup.scd"
3. Restart Supercollider
4. Declare Variables azim and elev in your Tidal file (You can use the file "ambicycles_example.tidal"):

      let azim = pF "azim"

      let elev = pF "elev"

5. Now, you should be able to access azimut and elevation as effectparameters in Tidal like this:

      d1 $ sound "bd sd bd clap" # azim  "<0 1> [-1 0.4 -0.6]/3 <2 -1>" # elev "<1 -1.7> -0.25 0.5"
