# Eventdisplay Analysis Scripts for CTA

[![DOI](https://zenodo.org/badge/221257176.svg)](https://zenodo.org/badge/latestdoi/221257176)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4d356e6133ee4548ba8e4650c25c3a03)](https://app.codacy.com/gh/Eventdisplay/Eventdisplay_AnalysisScripts_CTA?utm_source=github.com&utm_medium=referral&utm_content=Eventdisplay/Eventdisplay_AnalysisScripts_CTA&utm_campaign=Badge_Grade)

Run scripts for CTA. Allows to efficiently run all analysis steps starting from the raw MC files to sensitivities using Eventdisplay.

## Installation

### Directories

All scripts expect the following setup for directories. Any deviation from this will break the scripts.

Main directory for all analysis products:
```
${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}
```
Main directory for all software and auxilaury files plus all log files from the analysis:
```
${CTA_USER_WORK_DIR}/analysis/AnalysisData/${DSET}
```

$DSET is the name of the data set to be analysed, e.g. *prod3b-paranal20deg_SCT-sq08-LL*. 

The following subdirectories are expected:

1. *${CTA_USER_WORK_DIR}/analysis/AnalysisData/Eventdisplay_AnalysisScripts_CTA* - the directory with this repository
2. *${CTA_USER_DATA_DIR}/analysis/AnalysisData/FileList_prod3b* - directory with the lists for the simulation files (see below)
3. *${CTA_USER_DATA_DIR}/analysis/AnalysisData/{DSET}* - the directory with all analysis products (several subdirectories will be prepared from the analysis scripts)
4. *${CTA_USER_WORK_DIR}/analysis/AnalysisData/{DSET}* -  the directory with all and auxiliary files

### Installation of scripts and Eventdisplay

Requires root to be installed and *$ROOTSYS* to be set (use ROOT versions >=6.20)

Install *Eventdisplay_AnalysisScripts_CTA* from github and select the corresponding branch to work with (e.g., prod5-v08):

```
git clone https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA.git
cd Eventdisplay_AnalysisScripts_CTA
git checkout prod5-v08
```

Install and compile eventdisplay (expect all Eventdisplay repositories with same branch names):

```
cd install
./prepareProductionBinaries.sh <data set> prod5-v08
```

This installs the following packages:
- hessioxx
- sofa
- Eventdisplay analysis files
- Eventdisplay code

Note that only the data set name needs to be given here (e.g., *prod3b-paranal20deg_SCT-sq08-LL*), and not a full path name.

### Path setting

Before running any scripts, the correct paths for all executables and libraries needs to be set.

```
cd ${CTA_USER_DATA_DIR}/analysis/AnalysisData/Eventdisplay_AnalysisScripts_CTA
source ./setSoftwarePaths.sh ${DSET}
```

## List of MC files for the evndisp stage

For the first stage of the analysis, a list with file names (full paths) for all MC input files needs to be filled.

Expected directory structure (first level):

1. prod3b: *${CTA_USER_DATA_DIR}/analysis/AnalysisData/FileList_prod3b/*
2. prod5: *${CTA_USER_DATA_DIR}/analysis/AnalysisData/FileList_prod5/*

Second level directory structure expects a substring of ${DSET} (without the analysis version number). E.g. for the example of *prod3b-paranal20deg_SCT-sq08-LL*, it should be only *prod3b-paranal20deg_SCT*.

In this directory, the list of files for the different particle types are:

- *gamma_cone.list*
- *gamma_onSource.list*
- *electron.list*
- *proton.list*

e.g., 
```
/lustre/fs24/group/cta/prod3b/CTA-ProdX-Download-DESY/Prod3b_Paranal_20deg_HB9//electron/electron_20deg_0deg_run945___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
/lustre/fs24/group/cta/prod3b/CTA-ProdX-Download-DESY/Prod3b_Paranal_20deg_HB9//electron/electron_20deg_0deg_run2962___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
/lustre/fs24/group/cta/prod3b/CTA-ProdX-Download-DESY/Prod3b_Paranal_20deg_HB9//electron/electron_20deg_180deg_run2634___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
/lustre/fs24/group/cta/prod3b/CTA-ProdX-Download-DESY/Prod3b_Paranal_20deg_HB9//electron/electron_20deg_180deg_run4722___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
/lustre/fs24/group/cta/prod3b/CTA-ProdX-Download-DESY/Prod3b_Paranal_20deg_HB9//electron/electron_20deg_0deg_run2762___cta-prod3-sct_desert-2150m-Paranal-SCT.simtel.gz
```

## Running the analysis

Central execution script is [CTA.runAnalysis.sh](CTA.runAnalysis.sh). In the best case, no changes are required to this script.

e.g., to run the first step of the analysis with evndisp, do
```
./CTA.runAnalysis.sh prod3b-S20deg-SCT EVNDISP 0 2 2 2 2
```
(or set any other data set, as outlined in ./CTA.runAnalysis.sh)

The script does the following:

- read a list of arrays from a subdirectory specificed for your data set in ./CTA.runAnalysis.sh (e.g., prod3b/subArray.prod3b.South-SCT.list)
- execute scripts to submit jobs from the ./analysis directory
- all output products are written to *${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}*

On the list of arrays:
- arrays are defined by the telescope numbering as defined during the simulations.
- array layout definition files can be found in *$$CTA_EVNDISP_AUX_DIR}/DetectorGeometry*

For a complete analysis, one needs to cycle through all reconstruction steps in the following sequence:

1. EVNDISP - calibration and image analysis
2. MAKETABLES and DISPBDT - lookup table filling and disp BDT training (can be done in parallel)
3. ANATABLES - stereo analysis using lookup tables and disp BDTs
4. TRAIN - train BDTs for gamma/hadron separation
5. ANGRES - determine angular resolution for 40% signal efficiency
6. QC - determine data rates after quality cuts (used for cut optimisation)
7. CUTS - optimise gamma/hadron cuts and calculate instrument response functions
8. PHYS - fill instrument response functions

## Testing

Running the analysis is complex and involves the reading and creating of many files (possibly >100k files).
Testing the results for consistent is important; please look into the testProduction directory for testing scripts.

## Utilities

Set links to EVNDISP production directory:

```
cd utitilities
./linkEvndispProduction.sh prod5-LaPalma-20deg-EVNDISP prod5-LaPalma-20deg-v02-LL ../prod5/subArray.prod5.North-noHyper-N.list
```

Set links for hyper array analysis:

```
cd utiltities
./prepareHyperProduction.sh prod5-LaPalma-20deg-v01-LL prod5-LaPalma-20deg-h01-LL ../prod5/subArray.prod5.North-noHyper.list
```

Count number of files in production directories:

```
cd utilities
./countFilesinProduction.sh prod5-LaPalma-20deg-EVNDISP ../prod5/subArray.prod5.North-noHyper.list EVNDISP
```
e.g., cross checks that number of EVNDISP files is correct


## Licence

License: BSD-3 (see LICENCE file)

## Contact

Gernot Maier
