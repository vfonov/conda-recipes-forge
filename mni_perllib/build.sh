#!/bin/bash

set -o errexit -o pipefail

export DEFAULT_DATA_DIR=$PREFIX/share/mni-models

# Make sure this goes in site
### HACK .... stupid perl , asking interactive questions in the non-interactive script
echo ${DEFAULT_DATA_DIR} | perl Makefile.PL  INSTALLDIRS=site
make
make test
make install

# Add more build steps here, if they are necessary.

# See
# https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.
