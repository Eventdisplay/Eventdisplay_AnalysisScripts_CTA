# IPR generation

Optimised next-neighbour cleaning (Shayduk et al 2013) requires charge spectra as input.
This directory contains scripts to produce charge spectra for different telescope types
using sim_telarray.

To produce IPR graphs for all telescopes, run the scripts in the following order:

1. producePedestals.sh - This will run sim_telarray to produce the pedestal files. Notice to change environmental variables at the top to point to a sim_telarray installation and to a scratch area where intermediate results will be saved. You will also need a dummy CORSIKA file "dummy1.corsika.gz" in your scratch area, which can be be set in the script as SCRATCH

2. produceDST.sh - This will convert the output from sim_telarray to DST files. This requires having EVENTDISPLAY installed. In addition, you will need a 1 telescope geometry file in your scratch area, which can be found in this directory as geometry-1-telescope.lis

3. produceGraphFromDST.sh - Calculate the graphs from the DST file produced in the previous step. The results will be saved in the current directory as "pedestals-TEL-dst.root".

3. mergeIPRGraphs.C - Merge all graphs calculated into root file
