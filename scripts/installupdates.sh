#!/bin/bash

echo "-----------------------------------------------------"
echo "Start update"
echo "-----------------------------------------------------"
echo ""

paru -Syu

notify-send "Update complete"
