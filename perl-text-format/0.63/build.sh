#!/bin/bash

set -o errexit -o pipefail

perl Makefile.PL  INSTALLDIRS=site
make
make test
make install

# Add more build steps here, if they are necessary.

# See
# https://docs.conda.io/projects/conda-build
# for a list of environment variables that are set during the build process.
