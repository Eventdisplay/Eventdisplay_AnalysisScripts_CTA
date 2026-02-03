# IPR generation

Optimised next-neighbour cleaning ([Shayduk et al 2013](https://arxiv.org/abs/1307.4939)) requires charge spectra as input.
This directory contains scripts to produce charge spectra for different telescope types using sim_telarray.

To produce IPR graphs for all telescopes, run the scripts in the following order:

0. The recommended sim_telarray installation to use is the one on cvmfs. Edit the setupPackage.sh file to point to the installation you wish to use and run 'source setupPackage.sh'. Otherwise, modify the environmental variables at the top of producePedestals.sh to point to a sim_telarray installation

1. `producePedestals.sh` - This will run sim_telarray to produce the pedestal files. Notice to change environmental variable at the top to point to a scratch area where intermediate results will be saved. You will also need a dummy CORSIKA file "dummy1.corsika.gz" in your scratch area, which can be be set in the script as SCRATCH. This script requires adjustments at the top of the script.

2. `convertToDST.sh` - This will convert the simtel_array output to a `dst.root` file required as input to the next step.
In case of errors: ensure that the Eventdisplay installation uses the same pre-processor flags (e.g. PROD6) as the sim_telarray installation.

3. `produceIPRGraphs.sh` - Calculate the IPR graphs.
Convert the output from sim_telarray to DST files and calulate IPR graphs. This requires having EVENTDISPLAY installed.

4. mergeIPRGraphs.sh - Merge all graphs calculated into root file (save also all log files into this root file)
