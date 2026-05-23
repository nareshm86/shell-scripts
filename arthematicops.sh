#!/bin/bash
NUM1=1
NUM2=2

SUM=$(($NUM1+$NUM2))

echo "Total value is $SUM"

MOVIES=("SRH" "RCH" "GT")
echo "Movies are ${MOVIES[@]}"
echo "Second Movie is ${MOVIES[1]}"
echo "Third movie is ${MOVIES[2]}"
echo "All movies are ${MOVIES[@]}"
