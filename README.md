# Eventdisplay Analysis Scripts for CTA

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

Set links for hyper array analysis:

```
cd utiltities
./prepareHyperProduction.sh prod5-LaPalma-20deg-v01-LL prod5-LaPalma-20deg-h01-LL ../prod5/subArray.prod5.North-noHyper.list
```



## Licence

License: BSD-3 (see LICENCE file)

## Contact

Gernot Maier
