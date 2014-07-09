#!/bin/bash
shopt -s expand_aliases
source ~/.bash_profile_nick

pwd
echo $1
num=1
while read line; do
  c=$line
  echo '#'$num
  echo $c
  time delphi -e -v $c -s $c 
  num=`expr $num + 1`
done < $1
