# DST generation

## Introduction

Generate DST files used for debugging for different subsets:

- LSTs (all energies; lowE < 50 GeV; highE > 5 TeV)
- MSTs (all energies; lowE < 100 GeV; highE > 5 TeV)
- SSTs (all energies; lowE < 1 TeV; highE > 10 TeV)
- fullarray (all energies; highE > 5 TeV)

## Scripts

Values hardwired at top of the scripts:

- possible Sites: *LaPalma* or *Paranal*
- possible Particle Types: *gamma_onSource* or "gamma_cone"

Execute:
```
./generateDSTFiles.sh
```

Output is written to:

```
$CTA_USER_DATA_DIR/DST_testDevelopment_prod5/
```
