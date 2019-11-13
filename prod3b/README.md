# Analysis steps

The analysis works with 'data sets'. Examples are

- prod3b-LaPalma-20degu05b-LL
- prod3b-paranal20degu05b-LL

## Prerequisites

ROOT installed (v6.14 or newer)

## Environmental variables

- ROOTSYS
- CTA_USER_DATA_DIR - directory for all data

## Software installation

Install all necessary software using 

  prepareProductionBinaries.sh <DSET>

This script downloads

a.  Eventdisplay configuration and parameter files from github into $CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/Eventdisplay_AnalysisFiles_CTA/

b.  hessioxx (from MPIK into $CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/code/hessioxxx)
(set username and password using a ~/.wgetrc file)

c. sofa for astrometry (from webserver into $CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/code/sofa)

d. Eventdisplay software from github ($CTA_USER_DATA_DIR/analysis/AnalysisData/${DSET}/code)

## Analysis

Main analysis script is 

To start the analysis do:

1. set all PATHS correctly

  source ./setSoftwarePaths.sh prod3b-LaPalma-20degu05b-LL

2. start analysis
 
  ./


