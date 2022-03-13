#!/bin/bash

OUTPUT_PATH="../output-vagrant-vbx"
OVF_PATH=$(find ${OUTPUT_PATH} -type f -iname ${PHOTON_APPLIANCE_NAME}.ovf -exec dirname "{}" \;)


# Move ovf files in to a subdirectory of OUTPUT_PATH if not already
if [ "${OUTPUT_PATH}" = "${OVF_PATH}" ]; then
    mkdir ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
    mv ${OUTPUT_PATH}/*.* ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
    OVF_PATH=${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}
fi
OVF_DISK_SIZE=$(cat ${OUTPUT_PATH}/${PHOTON_APPLIANCE_NAME}.ovf|grep "ovf:capacity="|cut -d "=" -f2|cut -d " " -f1)
rm -f ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.mf

sed "s/{{VERSION}}/${PHOTON_VERSION}/g" ${PHOTON_OVF_TEMPLATE} > photon.xml
cp ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf.old
cp photon.ovf.template ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf

if [ "$(uname)" == "Darwin" ]; then
    sed -i -e "s~"ovf:capacity"~"ovf:capacity=$OVF_DISK_SIZE" ~g" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    #sed -i .bak2 "/    <\/vmw:BootOrderSection>/ r photon.xml" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
else
    sed -i -e "s~"ovf:capacity"~"ovf:capacity=$OVF_DISK_SIZE" ~g" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
    sed -i "/    <\/vmw:BootOrderSection>/ r photon.xml" ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf
fi
#export OVFPATH="/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/"
#$OVFPATH/ovftool ${OVF_PATH}/${PHOTON_APPLIANCE_NAME}.ovf ${OUTPUT_PATH}/${FINAL_PHOTON_APPLIANCE_NAME}.ova
#rm -rf ${OVF_PATH}
#rm -f photon.xml