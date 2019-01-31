#!/usr/bin/env bash

usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

while getopts ":s:p:" arg; do
    case "${arg}" in
    s)
        s=${OPTARG}
        ((s == 45 || s == 90)) || usage
        ;;
    p)
        p=${OPTARG}
        ;;
    *)
        usage
        ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${p}" ]; then
    usage
fi

# Check ARGs
echo "s = ${s}"
echo "p = ${p}"
