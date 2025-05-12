# Production test scripts

Scripts to test completeness of productions (e.g., for missing files)

Some scripts require to set some parameters at the top

## Testing dispBDT training

This script:

- tests for existence of disp BDT XML files

e.g.,
```
./test-CTA.DISPTRAINING.sh prod5b-LaPalma-20deg-sq08-LL subArray.prod5b.North-test2.list
```

## Testing TMVA stage

This script:

- tests for existence of BDT root files
- tests for missing BDT XML files

e.g.,
```
./test-CTA.TMVA.sh prod5b-LaPalma-20deg-sq08-LL subArray.prod5b.North-test2.list 0
```

## Testing effective area stage

This script:

- counts number of linked mscw_energy files used as input to effective area stage (observe the numbers)
- test for existence of effective area output files

e.g.,
```
./test-CTA.EFFAREA.sh prod5b-LaPalma-20deg-sq08-LL subArray.prod5b.North-test2.list 0
```
