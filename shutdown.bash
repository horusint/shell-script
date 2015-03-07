#!/bin/bash

for i in $@ ; do

    if ping -c1 $@ > /dev/null ; then
        ssh root@$@ "shutdown -h now"
    else
        echo "Host $@ already down"
    fi

done

