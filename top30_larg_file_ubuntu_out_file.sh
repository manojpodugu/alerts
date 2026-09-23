#!/bin/bash

TOP_FILES=30
OUTPUT_FILE="/root/top30_largest_files_output.txt"

# Start a fresh output file
> "$OUTPUT_FILE"

# Send all output to both terminal and file
exec > >(tee "$OUTPUT_FILE") 2>&1

echo "============================================================"
echo "       TOP 30 LARGEST FILES - UBUNTU SERVER"
echo "============================================================"
echo

# Get mounted filesystems
findmnt -rn -o TARGET,FSTYPE |
while read -r MOUNTPOINT FSTYPE
do

    # Skip virtual/pseudo filesystems
    case "$FSTYPE" in
        tmpfs|devtmpfs|proc|sysfs|securityfs|devpts|cgroup|cgroup2|\
        pstore|efivarfs|bpf|hugetlbfs|mqueue|debugfs|tracefs|\
        fusectl|configfs|autofs|binfmt_misc|squashfs)
            continue
            ;;
    esac

    echo "============================================================"
    echo "Filesystem : $MOUNTPOINT"
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
