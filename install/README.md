# Installation of Eventdisplay and data files

Script to:

- download (from MPIK) and compile hessioxx with the correct production settings
- download and compile Eventdisplay with the correct production settings
- download Eventdisplay data and auxiliary files

Usage:

```
./prepareProductionBinaries.sh <data set> <Eventdisplay version>
```

This will install the required binaries and data files into
```
$CTA_USER_WORK_DIR/analysis/AnalysisData/<data set>
```

Note that the data set name must contain certain strings (e.g., prod5 for a prod5 set, or SCT for any production containing MST-SCs).

The current setup expects the credentials for the hessioxx download in ~/.wgetrc file.
