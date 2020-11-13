# Eventdisplay Analysis Scripts for CTA

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4d356e6133ee4548ba8e4650c25c3a03)](https://app.codacy.com/gh/Eventdisplay/Eventdisplay_AnalysisScripts_CTA?utm_source=github.com&utm_medium=referral&utm_content=Eventdisplay/Eventdisplay_AnalysisScripts_CTA&utm_campaign=Badge_Grade)

Run scripts for CTA. Allows to efficiently run all analysis steps starting from the raw MC files to sensitivities using Eventdisplay.

## Installation

### Directories

All scripts expect the following setup for directories. Any deviation from this will break the scripts.

Main directory for all software and analysis products:
```
${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}
```

$DSET is the name of the data set to be analysed, e.g. *prod3b-paranal20deg_SCT-sq08-LL*

The following subdirectories are expected:

1. *Eventdisplay_AnalysisScripts_CTA* - the directory with this repository
2. *FileList_prod3b* - directory with the lists for the simulation files (see below)
3. *{DSET}* - the directory with all software and analysis products (several subdirectories will be prepared from the analysis scripts

### Installation of scripts and Eventdisplay

Requires root to be installed and *$ROOTSYS* to be set (use ROOT versions >=6.20)

Install *Eventdisplay_AnalysisScripts_CTA* from github and select the corresponding branch to work with (e.g., prod5-v08):

```
git clone https://github.com/Eventdisplay/Eventdisplay_AnalysisScripts_CTA.git
cd Eventdisplay_AnalysisScripts_CTA
git checkout -b prod5-v08
```

Install and compile eventdisplay:

```
cd install
./prepareProductionBinaries.sh <data set>
```

This installs the following packages:
- hessioxx
- sofa
- Eventdisplay analysis files
- Eventdisplay code

Note that only the data set name needs to be given here (e.g., *prod3b-paranal20deg_SCT-sq08-LL*)

### Path setting

Before running any scripts, the correct paths for all executables and libraries needs to be set.

```
cd ${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}
source ./setSoftwarePaths.sh ${DSET}
```

## List of MC files for the evndisp stage

For the first stage of the analysis, a list with file names (full paths) for all MC input files needs to be filled.

Expected directory structure:

1. prod3b: *${CTA_USER_DATA_DIR}/analysis/AnalysisData/FileList_prod3b/*






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
