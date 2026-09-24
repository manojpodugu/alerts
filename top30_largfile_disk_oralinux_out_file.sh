#!/bin/bash

TOP_FILES=30
OUTPUT_FILE="$HOME/top30_largest_files_output.txt"

# Start a fresh output file
> "$OUTPUT_FILE"

# Send output to both terminal and output file
exec > >(tee "$OUTPUT_FILE") 2>&1

echo "============================================================"
echo "       TOP 30 LARGEST FILES - ORACLE LINUX"
echo "============================================================"
echo
echo "Server     : $(hostname)"
echo "OS         : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Generated  : $(date)"
echo

# Find only filesystems backed by /dev
findmnt -rn -o SOURCE,TARGET,FSTYPE |
grep '^/dev/' |
while read -r SOURCE MOUNTPOINT FSTYPE
do

    echo "============================================================"
    echo "Filesystem : $MOUNTPOINT"
    echo "Device     : $SOURCE"
    echo "Type       : $FSTYPE"
    echo "============================================================"
    echo

    printf "%-6s %-10s %s\n" "Rank" "Size" "File"
    echo "------------------------------------------------------------"

    find "$MOUNTPOINT" -xdev -type f -printf '%s %p\n' 2>/dev/null |
    sort -nr |
    head -"$TOP_FILES" |
    numfmt --field=1 --to=iec |
    awk '
    {
        printf "%-6d %-10s %s\n", NR, $1, $2
    }'

    echo
done

echo "============================================================"
echo "                    SCAN COMPLETED"
echo "============================================================"
echo
echo "Output saved to: $OUTPUT_FILE"
