#!/bin/bash
v3drawpath=$1;

lv3draw=( $(find $v3drawpath -iname '*.v3draw') );

mkdir -p $v3drawpath/sorted;

for  (( i=0; i<${#lv3draw[@]}; i++)); do cp ${lv3draw[i]} $v3drawpath/sorted/$i.v3draw; done