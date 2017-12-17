#!/bin/bash

### Determine the process name with the highest number of instances.

ps | gawk '{count[$NF]++}END{for(j in count) print ""count[j]":",j}'|sort -rn|head -n20
