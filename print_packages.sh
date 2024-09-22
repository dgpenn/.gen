#!/usr/bin/env bash
#
# Prints all the packages in packages.txt as one string
# This is untended to be used with pacstrap
# 

packages=$(cat packages.txt)
echo "$packages"
