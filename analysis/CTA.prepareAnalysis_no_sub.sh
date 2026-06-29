#!/bin/bash
#
# Prepare disjoint training and analysis data sets using symbolic links.
# This is a local operation; no batch job is submitted.

set -e
shopt -s nullglob

usage()
{
    cat <<'EOF'
CTA.prepareAnalysis_no_sub.sh <subarray list> <data set> <analysis parameter file> [source analysis directory]

  <subarray list>             text file with one subarray ID per line
  <data set>                  e.g. prod6-LaPalma-20deg-dark-sq51-LL
  <analysis parameter file>   MSCWSUBDIRECTORY defines the target analysis date
  [source analysis directory] directory containing the original mscw files;
                              defaults to MSCWSUBDIRECTORY

For every subarray, this creates:
  <target>.TRAIN.MCAZ_0deg and <target>.TRAIN.MCAZ_180deg
  <target>.EFFAREA.MCAZ_0deg and <target>.EFFAREA.MCAZ_180deg
  <target>.TRAIN.MCAZ and <target>.EFFAREA.MCAZ (both directions combined)

gamma_cone and proton files are split 1/2 training and 1/2 analysis.
gamma_onSource and electron files are analysis-only. Splitting is performed
independently for each direction.

Example for reusing an older reconstruction with a new analysis date:
  CTA.prepareAnalysis_no_sub.sh arrays.list DATASET new.runparameter \
      Analysis-ID0-g20260325
EOF
}

if [ "$#" -lt 3 ]; then
    usage
    exit 1
fi

SUBARRAY_LIST=$1
DSET=$2
ANAPAR=$3

if [ ! -r "$SUBARRAY_LIST" ]; then
    echo "Error: subarray list not readable: $SUBARRAY_LIST" >&2
    exit 1
fi
if [ ! -r "$ANAPAR" ]; then
    echo "Error: analysis parameter file not readable: $ANAPAR" >&2
    exit 1
fi
if [ -z "${CTA_USER_DATA_DIR:-}" ]; then
    echo "Error: CTA_USER_DATA_DIR is not set" >&2
    exit 1
fi

TARGET_ANALYSIS=$(awk '$1 == "MSCWSUBDIRECTORY" { print $2; exit }' "$ANAPAR")
if [ -z "$TARGET_ANALYSIS" ]; then
    echo "Error: MSCWSUBDIRECTORY is missing from $ANAPAR" >&2
    exit 1
fi
SOURCE_ANALYSIS=${4:-$TARGET_ANALYSIS}
case "$TARGET_ANALYSIS:$SOURCE_ANALYSIS" in
    *"/"*)
        echo "Error: analysis directory arguments must be directory names, not paths" >&2
        exit 1
        ;;
esac

DATASET_DIR="${CTA_USER_DATA_DIR%/}/analysis/AnalysisData/$DSET"
DIRECTIONS=( "_0deg" "_180deg" )

link_file()
{
    local source_file=$1
    local target_dir=$2
    local target_file
    target_file="$target_dir/$(basename "$source_file")"

    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        echo "Error: duplicate target name: $target_file" >&2
        exit 1
    fi
    ln -s "$source_file" "$target_file"
}

link_partition()
{
    local source_dir=$1
    local particle=$2
    local direction=$3
    local divisor=$4
    local train_dir=$5
    local analysis_dir=$6
    local file
    local index=0
    local count=0
    local files=( "${source_dir}/${particle}.${ARRAY}_ID${RECID}${direction}"*.mscw.root )

    if [ "${#files[@]}" -eq 0 ]; then
        echo "Error: no $particle files for $ARRAY $direction in $source_dir" >&2
        exit 1
    fi

    for file in "${files[@]}"; do
        index=$((index + 1))
        count=$((count + 1))
        if [ $((index % divisor)) -eq 0 ]; then
            link_file "$file" "$analysis_dir"
        else
            link_file "$file" "$train_dir"
        fi
    done
    echo "  $particle $direction: $((count - count / divisor)) train, $((count / divisor)) analysis"
}

link_analysis_only()
{
    local source_dir=$1
    local particle=$2
    local direction=$3
    local analysis_dir=$4
    local file
    local count=0
    local files=( "${source_dir}/${particle}.${ARRAY}_ID${RECID}${direction}"*.mscw.root )

    if [ "${#files[@]}" -eq 0 ]; then
        echo "Error: no $particle files for $ARRAY $direction in $source_dir" >&2
        exit 1
    fi
    for file in "${files[@]}"; do
        link_file "$file" "$analysis_dir"
        count=$((count + 1))
    done
    echo "  $particle $direction: $count analysis-only"
}

combine_directions()
{
    local kind=$1
    local combined="$ARRAY_DIR/$TARGET_ANALYSIS.$kind.MCAZ"
    local direction
    local file

    rm -rf "$combined"
    mkdir -p "$combined"
    for direction in "${DIRECTIONS[@]}"; do
        for file in "$ARRAY_DIR/$TARGET_ANALYSIS.$kind.MCAZ$direction"/*.root; do
            [ -L "$file" ] || continue
            link_file "$(readlink "$file")" "$combined"
        done
    done
}

check_source_files()
{
    local source_dir=$1
    local direction
    local particle
    local files

    for direction in "${DIRECTIONS[@]}"; do
        for particle in gamma_cone proton gamma_onSource electron; do
            files=( "${source_dir}/${particle}.${ARRAY}_ID${RECID}${direction}"*.mscw.root )
            if [ "${#files[@]}" -eq 0 ]; then
                echo "Error: no $particle files for $ARRAY $direction in $source_dir" >&2
                exit 1
            fi
        done
    done
}

RECID=$(awk '$1 == "RECID" { print $2; exit }' "$ANAPAR")
if [ -z "$RECID" ]; then
    echo "Error: RECID is missing from $ANAPAR" >&2
    exit 1
fi

while IFS= read -r ARRAY || [ -n "$ARRAY" ]; do
    # Permit empty lines and comments in subarray lists.
    ARRAY=${ARRAY%%#*}
    ARRAY=${ARRAY//[[:space:]]/}
    [ -n "$ARRAY" ] || continue

    ARRAY_DIR="$DATASET_DIR/$ARRAY"
    SOURCE_DIR="$ARRAY_DIR/$SOURCE_ANALYSIS"
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Error: source analysis directory not found: $SOURCE_DIR" >&2
        exit 1
    fi
    # Check the complete source set before replacing any existing split.
    check_source_files "$SOURCE_DIR"

    echo "Preparing $DSET/$ARRAY from $SOURCE_ANALYSIS into $TARGET_ANALYSIS"
    for direction in "${DIRECTIONS[@]}"; do
        TRAIN_DIR="$ARRAY_DIR/$TARGET_ANALYSIS.TRAIN.MCAZ$direction"
        ANALYSIS_DIR="$ARRAY_DIR/$TARGET_ANALYSIS.EFFAREA.MCAZ$direction"

        rm -rf "$TRAIN_DIR" "$ANALYSIS_DIR"
        mkdir -p "$TRAIN_DIR" "$ANALYSIS_DIR"

        link_partition "$SOURCE_DIR" gamma_cone "$direction" 2 "$TRAIN_DIR" "$ANALYSIS_DIR"
        link_partition "$SOURCE_DIR" proton "$direction" 2 "$TRAIN_DIR" "$ANALYSIS_DIR"
        link_analysis_only "$SOURCE_DIR" gamma_onSource "$direction" "$ANALYSIS_DIR"
        link_analysis_only "$SOURCE_DIR" electron "$direction" "$ANALYSIS_DIR"
    done

    combine_directions TRAIN
    combine_directions EFFAREA
done < "$SUBARRAY_LIST"
