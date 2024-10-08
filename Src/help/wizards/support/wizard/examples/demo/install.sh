#!/bin/sh

mkdir tmp
ecb -config wizard.ecf -target wizard -finalize -c_compile -project_path tmp
mkdir -p spec/$ISE_PLATFORM
mv tmp/EIFGENs/wizard/F_code/wizard spec/$ISE_PLATFORM/wizard
rm -rf tmp

WIZ_TARGET=$ISE_EIFFEL/studio/wizards/new_projects/demo
rm -rf $WIZ_TARGET
mkdir $WIZ_TARGET
cp -r resources $WIZ_TARGET/resources
cp -r spec $WIZ_TARGET/spec
cp demo.dsc $WIZ_TARGET/../demo.dsc
rm -rf spec
