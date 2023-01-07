library(httptest2)

## To avoid httptest2 overly long file names
## Run the following bash script

# #!/bin/bash
#
# # First: replace long strings in files
# # Script from https://stackoverflow.com/questions/11392478
#
# grep -rli '623f038354e6e5883c8be8a2d97284cdd41ed36f' * | xargs -i@ sed -i 's/623f038354e6e5883c8be8a2d97284cdd41ed36f/job1/g' @
# grep -rli '85561e44e3fed7d27e204f4d4106e1da9f99dd56' * | xargs -i@ sed -i 's/85561e44e3fed7d27e204f4d4106e1da9f99dd56/job2/g' @
# grep -rli 'de23a0319d53da61bfa0e594bb15fefbb754af7c' * | xargs -i@ sed -i 's/de23a0319d53da61bfa0e594bb15fefbb754af7c/job3/g' @
#
# # Second: replace long string in file names
# # Script from https://unix.stackexchange.com/questions/416018
#
# for file in `find . -type f -name '623f038*'`; do mv -v "$file" "${file/623f038354e6e5883c8be8a2d97284cdd41ed36f/job1}"; done
# for file in `find . -type f -name '85561e4*'`; do mv -v "$file" "${file/85561e44e3fed7d27e204f4d4106e1da9f99dd56/job2}"; done
# for file in `find . -type f -name 'de23a03*'`; do mv -v "$file" "${file/de23a0319d53da61bfa0e594bb15fefbb754af7c/job3}"; done
#
# # Now commit the files
