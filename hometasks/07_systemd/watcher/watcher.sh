#!/bin/bash
if grep $KEYWORD $FILE &> /dev/null
then
    logger "======> V means Victoria <======"
else
    exit 0
fi

