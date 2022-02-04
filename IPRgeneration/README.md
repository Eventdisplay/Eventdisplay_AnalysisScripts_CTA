# IPR generation

Optimised next-neighbour cleaning (Shayduk et al 2013) requires charge spectra as input.
This directory contains scripts to produce charge spectra for different telescope types
using sim_telarray.

To produce IPR graphs for all telescopes, run the scripts in the following order:

0. The recommended sim_telarray installation to use is the one on cvmfs. Edit the setupPackage.sh file to point to the installation you wish to use and run 'source setupPackage.sh'. Otherwise, modify the environmental variables at the top of producePedestals.sh to point to a sim_telarray installation

1. producePedestals.sh - This will run sim_telarray to produce the pedestal files. Notice to change environmental variable at the top to point to a scratch area where intermediate results will be saved. You will also need a dummy CORSIKA file "dummy1.corsika.gz" in your scratch area, which can be be set in the script as SCRATCH

2. produceDST.sh - This will convert the output from sim_telarray to DST files. This requires having EVENTDISPLAY installed. In addition, you will need a 1 telescope geometry file in your scratch area, which can be found in this directory as geometry-1-telescope.lis

3. produceGraphFromDST.sh - Calculate the graphs from the DST file produced in the previous step. The results will be saved in the current directory as "pedestals-TEL-dst.root".

4. mergeIPRGraphs.C - Merge all graphs calculated into root file

5. saveLogFiles.sh - Save all log files into the prod5-IPR.root file.
