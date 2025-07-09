#! /usr/bin/env bash

# Unzip all the downloaded files, overwriting any existing .txt files.
unzip -o data/nj/\*.zip -d data/nj/

# Convert encoding and write to new file.
for file in $(ls data/nj/*.txt); do
  iconv -f WINDOWS-1252 -t UTF-8 ${file} > "${file%.*}-utf8.txt"
done
