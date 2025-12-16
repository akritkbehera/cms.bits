package: crab
version: "1.0"
requires:
 - crab-prod
 - crab-pre
 - crab-dev
sources:
 - https://github.com/cms-sw/cmsdist/blob/IB/CMSSW_16_0_X/g14/crab/crab.sh.file
 - https://github.com/cms-sw/cmsdist/blob/IB/CMSSW_16_0_X/g14/crab/crab-proxy-package.file
 - https://github.com/cms-sw/cmsdist/blob/IB/CMSSW_16_0_X/g14/crab/crab-setup.csh.file
 - https://github.com/cms-sw/cmsdist/blob/IB/CMSSW_16_0_X/g14/crab/crab-setup.sh.file
 - https://github.com/cms-sw/cmsdist/blob/IB/CMSSW_16_0_X/g14/crab/crab-env.csh.file
 - https://github.com/cms-sw/cmsdist/blob/IB/CMSSW_16_0_X/g14/crab/crab-env.sh.file
---
cp $SOURCEDIR/$SOURCE0 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE1 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE2 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE3 $INSTALLROOT/
cp $SOURCEDIR/$SOURCE4 $INSTALLROOT/
chmod +x $INSTALLROOT/crab.sh

sed -i -e "s|@CMS_PATH@|$BITS_WORK_DIR|g" "$INSTALLROOT"/crab*
sed -i -e "s|@CRAB_COMMON_VERSION@|$PKG_VERSION|g" "$INSTALLROOT"/crab*
