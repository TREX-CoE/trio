#!/bin/bash

if [[ $(basename $PWD) != "src" ]] ; then
  echo "This script should run in the src directory"
  exit -1
fi

# We want the script to crash on the 1st error:
set -e

echo "create populated directories"
mkdir -p templates_front/populated
mkdir -p templates_text/populated
mkdir -p templates_hdf5/populated

# It is important to ad '--' to rm because it tells rm that what follows are
# not options. It is safer.

echo "remove existing templates"
rm -f -- templates_front/*.{c,h,f90}
rm -f -- templates_text/*.{c,h}
rm -f -- templates_hdf5/*.{c,h}

echo "clean populated directories"
rm -f -- templates_front/populated/*
rm -f -- templates_text/populated/*
rm -f -- templates_hdf5/populated/*

function tangle()
{
  local command="(org-babel-tangle-file \"$1\")"
  emacs --batch \
        --eval "(require 'org)" \
        --eval "(org-babel-do-load-languages 'org-babel-load-languages '((python . t)))" \
        --eval "(setq org-confirm-babel-evaluate nil)" \
        --eval "$command"
}

echo "tangle org files to generate templates"
cd templates_front
tangle templator_front.org
cd ..

cd templates_text
tangle templator_text.org
cd ..

cd templates_hdf5
tangle templator_hdf5.org
cd ..

echo "run generator script to populate templates"
python3 generator.py

sleep 2

echo "compile populated files in the lib source files "
cd templates_front
source build.sh
cp trexio* ../
cd ..

cd templates_text
source build.sh
cp trexio* ../
cd ..

cd templates_hdf5
source build.sh
cp trexio* ../
cd ..

