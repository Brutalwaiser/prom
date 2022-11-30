#!/bin/bash

timestamp=$(date "+%Y.%m.%d-%H:%M:%S")
timeout 1 bash -c '</dev/tcp/nw-gpm-rcol4/9092' && echo $timestamp Port 9092 from `hostname` to nw-gpm-rcol4 open || echo $timestamp Port 9092 from `hostname` to nw-gpm-rcol4 closed >> /u01/gpmeso/scripts/socket_err.log
