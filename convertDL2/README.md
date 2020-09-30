# Convert ROOT out to DL2

## Introduction

Convert Eventdisplay eventlists to FITS and add gamma/hadron separator.

Requires to run last effective area calculation step (*CUTS*) with the following parameter enabled:

```
echo "* WRITEEVENTDATATREE 1" >> $MSCF
```
see analysis/CTA.EFFAREA.qsub_analyse_list.sh

## Convert files

```
conda activate EDconvert
./convert_to_DL2.sh <directory with effective area files> <cut level> <paranal/lapalma>
```

- converts files for all three cut types
- outputfile name is same as input file name + cut level + fits.gz
