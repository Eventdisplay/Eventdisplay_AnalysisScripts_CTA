# Eventdisplay Analysis Scripts for CTA

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4d356e6133ee4548ba8e4650c25c3a03)](https://app.codacy.com/gh/Eventdisplay/Eventdisplay_AnalysisScripts_CTA?utm_source=github.com&utm_medium=referral&utm_content=Eventdisplay/Eventdisplay_AnalysisScripts_CTA&utm_campaign=Badge_Grade)

Run scripts for CTA

Expects the following directory for all software and analysis products:

```
${CTA_USER_DATA_DIR}/analysis/AnalysisData/${DSET}
```

$DSET is the name of the data set to be analysed

## Installation

Requires *$ROOTSYS* to be set

```
cd install
./prepareProductionBinaries.sh

```

This installs the following packages:
- hessioxx
- sofa
- Eventdisplay analysis files
- Eventdisplay code

## Path setting

To set all paths, do:

 ```
source ./setSoftwarePaths.sh prod5-LaPalma-20deg-v01-LL
```

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
