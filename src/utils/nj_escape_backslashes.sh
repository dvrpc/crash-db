#! /usr/bin/env bash
#
# With the file format the NJ provides (fields determined by start/end byte, not a CSV), it must
# be treated as the TXT format to be used with Postgres's COPY. Almost everything can be handled in
# Postgres after that (adding quotes around space-separated fields, for example), except for an
# issue with backslashes:

# "Backslash characters (\) can be used in the COPY data to quote data characters that might
# otherwise be taken as row or column delimiters. In particular, the following characters must be
# preceded by a backslash if they appear as part of a column value: backslash itself, newline,
# carriage return, and the current delimiter character."
# (<https://www.postgresql.org/docs/current/sql-copy.html#FILE-FORMATS>)
#
# If a backslash is included in a file and not escaped, it appears to be excluded altogether. This
# is a problem because the line the nbecomes one character shorter, thus distorting where
# fields are supposed to be.
#
# So, this program pre-processes every file, after it has been converted to UTF-8 (see the encoding
# utility script) to escape backslashes.


for file in $(ls data/nj/*-utf8.txt); do
  sed 's;\\;\\\\;g' "${file}" > "${file%.*}-escaped.txt"
done
