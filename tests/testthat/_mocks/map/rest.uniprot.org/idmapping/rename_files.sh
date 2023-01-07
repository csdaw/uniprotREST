#!/bin/bash

# First: replace long strings in files
# Script from https://stackoverflow.com/questions/11392478

grep -rli '1' * | xargs -i@ sed -i 's/1/1/g' @
grep -rli '2' * | xargs -i@ sed -i 's/2/2/g' @
grep -rli '3' * | xargs -i@ sed -i 's/3/3/g' @

# Second: replace long string in file names
# Script from https://unix.stackexchange.com/questions/416018

for file in `find . -type f -name '623f038*'`; do mv -v "$file" "${file/1/1}"; done
for file in `find . -type f -name '85561e4*'`; do mv -v "$file" "${file/2/2}"; done
for file in `find . -type f -name 'de23a03*'`; do mv -v "$file" "${file/3/3}"; done

# Now commit the files
