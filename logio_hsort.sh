#!/usr/bin/env bash

prj_list=("prj1-error" "prj1-out" \
"prj2-error" "prj2-out" \
"prj3-error" "prj3-out" \
"prj4-error" "prj4-out" \
"prj5-error" "prj5-out"  )

new_files=()
old_files=()

for i in ${prj_list[@]}; do
    new_files+=($(ls -t ${i}-*|head -n 2))
done

for i in ${prj_list[@]}; do
    old_files+=($(grep ${i} /home/app/.log.io/harvester.conf | cut -d/ -f 6 | tr -d "\"',\""))
done

for ((i=0;i<${#new_files[@]};++i)); do
    sed -i "s/${old_files[i]}/${new_files[i]}/" /home/app/.log.io/harvester.conf
done
