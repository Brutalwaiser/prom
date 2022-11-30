#!/bin/bash

timestamp=$(date "+%Y.%m.%d-%H:%M:%S")

bash -c 'ping nw-gpm-col5 -c 4 -q' && echo stable connection with col5 || echo $timestamp connection to col5 was lost >> /u01/gpmeso/scripts/ping_err.log
