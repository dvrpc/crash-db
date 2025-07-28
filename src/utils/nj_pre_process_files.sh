#! /usr/bin/env bash

usage="
This script pre-processes NJ data files in order to make them importable by Postgres. Specifically:
  - unzips all .zip files in the data/nj directory
  - converts encoding of the resulting .txt files from win1252/cp1252 to utf8
  - converts formatting from dos to unix
  - escapes backslashes characters
  - replaces carriage returns (\r) with spaces
  - removes misplaced line feeds (\n) in middle of lines, even if there is more than one

Usage:
$(basename $0)
"

if [[ "${1}" = '-u' || "${1}" = 'u' ]]; then
  echo "${usage}"
  exit 0
fi

# Unzip all the downloaded files, overwriting any existing .txt files.
unzip -o data/nj/\*.zip -d data/nj/

# Convert encoding from win1252/cp1252 to UTF8 and write to new file.
# (Postgres's `COPY`, even using the `encoding 'WIN1252'` option, was not able to decipher the
# encoding from the original files correctly and would add odd symbols, replacing one character
# with multiple characters, and thus break the specification that NJ uses.)
for file in $(ls data/nj/*.txt); do
  # iconv doesn't do in-place conversion, so first output to a new file name and then replace it
  iconv -f WINDOWS-1252 -t UTF-8 -o "${file}.new" "${file}" && mv -f "${file}.new" "${file}"
done

# Convert from dos to unix formatting (CRLF -> LF).
for file in $(ls data/nj/*.txt); do
  dos2unix "${file}"
done


# Escape or replace characters that cause issues with either Postgres's COPY or that break NJ's
# specification.
echo 'Escape/replace problematic characters.'
for file in $(ls data/nj/*.txt); do
  # With the file format the NJ provides (fields determined by start/end byte, not a CSV), it must
  # be treated as the TXT format to be used with Postgres's COPY. Almost everything can be handled
  # in Postgres after that (adding quotes around space-separated fields, for example), except for an
  # issue with backslashes:
  #
  # "Backslash characters (\) can be used in the COPY data to quote data characters that might
  # otherwise be taken as row or column delimiters. In particular, the following characters must be
  # preceded by a backslash if they appear as part of a column value: backslash itself, newline,
  # carriage return, and the current delimiter character."
  # (<https://www.postgresql.org/docs/current/sql-copy.html#FILE-FORMATS>)
  #
  # If a backslash is included in a file and not escaped, it appears to be excluded altogether. This
  # is a problem because the line then becomes one character shorter, thus distorting where
  # fields are supposed to be.
  sed -i 's;\\;\\\\;g' "${file}"

  # Replace any stray carriage returns with a space, as otherwise they add a break mid-line,
  # breaking spec.
  sed -i 's;\r; ;g' "${file}"
done

# Remove new lines that have been mistakenly entered into the middle of the line.
# 
# Here are the locations of some that had been previously found and manually removed prior to using
# the sed command below to clean them automatically, if for some reason we need this information in
# the future:
#  - 2020 Burlington Drivers table, line 59-60
#  - 2020 Camden Drivers table, line 4019-20, line 17425-6,
#  - 2019 Burlington Accidents table, lines (after fixing) 8333, 8337, 9896, 10714
#  - 2019 Camden Accidents table, line 6165
#  - 2019 Camden Drivers table, line 14349
#  - 2019 Mercer Drivers table, line 7177
# 
# What the sed command does is:
#  - `/.\351\}/!`: match lines that don't (`!`) have 351 characters (or whatever they should have)
#  - `{ ... }'` these mark the beginning and end of a list of commands 
#  - `N;`: read the next line into the pattern space
#  - `s/\n/ /;`: replaces the new line/line feed/"\n" character with a space
#  - `:1 and b1`: first set a label, and then at the end go to it to test the line again (this
#     addresses the case when there are multiple incorrect line breaks within the same line)
echo 'Remove extra/misplaced new lines'
for file in $(ls data/nj/*.txt); do
  # The characters per line vary by both file and year, so need to check filename.
	case "${file}" in 
	  *2017* | *2018* | *2019* | *2020* | *2021* | *2022*)
	  	case "${file}" in
	  		*Accidents*)
	  		  sed -i ':1 /.\{469\}/!{ N; s/\n/ / ;b1}' "${file}"
			    ;;
	  		*Drivers*)
	  		  sed -i ':1 /.\{350\}/!{ N; s/\n/ / ;b1}' "${file}"
		    	;;
	  		*Occupants*)
	  		  sed -i ':1 /.\{75\}/!{ N; s/\n/ / ;b1}' "${file}"
		    	;;
	  		*Pedestrians*)
	  		  sed -i ':1 /.\{390\}/!{ N; s/\n/ / ;b1}' "${file}"
		    	;;
	  		*Vehicles*)
	  		  sed -i ':1 /.\{272\}/!{ N; s/\n/ / ;b1}' "${file}"
		    	;;
		  esac
	esac
done    
