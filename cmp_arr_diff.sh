#!/bin/bash

nums1=( 3 5 8 4 9 2 )
nums2=( 3 1 7 8 9 10 )

neteq=()
for x in ${nums1[@]}; do
    skip=
    for y in ${nums2[@]}; do
        if [ $x -eq $y ]; then
            skip=1
            break
        fi
    done
    [[ -n $skip ]] || noteq+=("$x")
done

for i in ${noteq[*]}; do 
    echo $i
done
