# Author: Bogovyk Oleksandr <obogovyk@gmail.com>
# ssh_host_check.sh
# -----------------

#!/bin/bash

username="{username}"
hosts=(
host1.example.com
host2.example.com
host3.example.com
...
host100.example.com
)

for i in ${hosts[*]}; do
    ping -c 1 $i 2>&1 /dev/null
    if [ $? -eq 0 ]; then
        livehosts+=($i)
        echo "$i: Ping success."
        x=$((x+1))
    else
        diedhosts+=($i)
    fi
done

echo ""
echo "Found: $x live hosts."

for i in ${livehosts[*]}; do 
    z=$(ssh $username@$i 'hostname -f')

    if [ "$i" == "$z" ]; then
        echo -e "\033[1mHost $i equal hostname $z!\033[0m"
    else
        echo "Host $i not equal hostname $z!" > /opt/hosts.notequal
        echo "Host $i not equal hostname $z!"
    fi
done

for i in ${diedhosts[*]}; do 
    echo "$i: died (no ping)." > /opt/hosts.noping
done
