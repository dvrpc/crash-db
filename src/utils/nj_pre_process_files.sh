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

# Function to remove misplaced newlines.
remove_newlines() {
    local expected_length="$1"
    local file="$2"
    local temp_file="${file}.tmp"
    
    awk -v len="$expected_length" '
    {
        # If line is shorter than expected, keep reading and joining lines
        while (length($0) < len && (getline next_line) > 0) {
            $0 = $0 " " next_line
        }
        print $0
    }' "$file" > "$temp_file" && mv "$temp_file" "$file"
}

# Unzip all the downloaded files, overwriting any existing .txt files.
unzip -o data/nj/\*.zip -d data/nj/

# Convert encoding from win1252/cp1252 to UTF8 and write to new file.
# (Postgres's `COPY`, even using the `encoding 'WIN1252'` option, was not able to decipher the
# encoding from the original files correctly and would add odd symbols, replacing one character
# with multiple characters, and thus break the specification that NJ uses.)
for file in $(ls data/nj/*.txt); do
  # iconv doesn't do in-place conversion, so first output to a new file name and then replace it
  iconv -f WINDOWS-1252 -t UTF-8 "${file}" > "${file}.new" && mv -f "${file}.new" "${file}"
done

# Convert from dos to unix formatting (CRLF -> LF).
for file in $(ls data/nj/*.txt); do
  # Try GNU sed first, fallback to BSD
  if ! sed -i 's/\r$//' "${file}" 2>/dev/null; then
    sed -i '' 's/\r$//' "${file}"
  fi
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
  if ! sed -i 's;\\;\\\\;g' "${file}" 2>/dev/null; then
    sed -i '' 's;\\;\\\\;g' "${file}"
  fi

  # Replace any stray carriage returns with a space, as otherwise they add a break mid-line,
  # breaking spec.
  if ! sed -i 's;\r; ;g' "${file}" 2>/dev/null; then
    sed -i '' 's;\r; ;g' "${file}"
  fi
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
echo 'Remove extra/misplaced new lines'
for file in $(ls data/nj/*.txt); do
  # The characters per line vary by both file and year, so need to check filename.
	case "${file}" in 
	  *2017* | *2018* | *2019* | *2020* | *2021* | *2022*)
	  	case "${file}" in
	  		*Accidents*)
	  		  remove_newlines 469 "${file}"
			    ;;
	  		*Drivers*)
	  		  remove_newlines 350 "${file}"
		    	;;
	  		*Occupants*)
	  		  remove_newlines 75 "${file}"
		    	;;
	  		*Pedestrians*)
	  		  remove_newlines 390 "${file}"
		    	;;
	  		*Vehicles*)
	  		  remove_newlines 272 "${file}"
		    	;;
		  esac
			;;
	  *2006* | *2007* | *2008* | *2009* | *2010* | *2011* | *2012* | *2013* | *2014* | *2015* | *2016*)
	  	case "${file}" in
	  		*Accidents*)
	  		  remove_newlines 458 "${file}"
			    ;;
	  		*Drivers*)
	  		  remove_newlines 161 "${file}"
		    	;;
	  		*Occupants*)
	  		  remove_newlines 74 "${file}"
		    	;;
	  		*Pedestrians*)
	  		  remove_newlines 200 "${file}"
		    	;;
	  		*Vehicles*)
	  		  remove_newlines 240 "${file}"
		    	;;
		  esac
			;;
	esac
done
