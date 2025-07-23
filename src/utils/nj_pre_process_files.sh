#! /usr/bin/env bash

usage="
This script pre-processes NJ data files in order to make them importable by Postgres. Specifically:
  - unzips all .zip files in the data/nj directory
  - converts encoding of the resulting .txt files from win1252/cp1252 to utf8
  - converts formatting from dos to unix
  - escapes backslashes characters
  - replaces carriage returns (\r) with spaces

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

  # Also replace any stray carriage returns with a space, as otherwise they add a break mid-line,
  # breaking spec.
  sed -i 's;\r; ;g' "${file}"
done

