#!/bin/bash

execute="/opt/couchbase/bin/couchbase-cli bucket-$1 -u Administrator -p ***** -c $2:8091"

case $1 in
	list) $execute | grep -v "^ "
	;;
	create)
		for buck in $(cat buckets); do
			$execute --bucket=$buck --bucket-type=memcached --bucket-password=$buck --bucket-replica=0 --enable-flush=1 --bucket-ramsize=$((104857600/1024/1024))
		done
	;;
	delete)
		for buck in $($0 list $2 | grep -v "^ "); do
			$execute --bucket=$buck
		done
	;;
	flush)
		for buck in $($0 list $2 | grep -v "^ "); do
			$execute --bucket=$buck --force
		done
	;;
	copy)
        execute=$(echo $execute | sed 's/copy/create/')
		for buck in $($0 list $3 | grep -v "^ "); do
			$execute --bucket=$buck --bucket-type=memcached --bucket-password=$buck --bucket-replica=0 --bucket-ramsize=$((104857600/1024/1024))
		done
	;;
	remove)
		execute=$(echo $execute | sed 's/remove/delete/')
		for buck in $(cat buckets); do
			$execute --bucket=$buck
		done
	;;
	recreate)
		$0 list $2 > $(dirname $0)/buckets
		$0 delete $2
		$0 create $2
	;;
	edit)
		for buck in $($0 list $2 | grep -v "^ "); do
			$execute --bucket=$buck --bucket-password=$buck --enable-flush=1
			echo "$execute --bucket=$buck --enable-flush=1"
		done
esac
