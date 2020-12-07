#!/usr/bin/env bash

set -e

root_dir="/data"
flist=$(find $root_dir -maxdepth 1 -type d|tail -n +2)
size_file="/tmp/compare_f.size"
count_file="/tmp/compare_f.count"
report_file="/data/compare_f.report"

[[ -f $report_file ]] && cat /dev/null > $report_file

for i in ${flist[@]}; do
    if [ "${i}" = "$root_dir/lost+found" ]; then
        echo "Skip '$i' dir."
    else
        du -sh $i >> $size_file
        find $i/ -type f|wc -l >> $count_file
    fi
done

paste $size_file $count_file -d " " > $report_file
rm -rf /tmp/compare_f.*
