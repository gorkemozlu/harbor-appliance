# Unofficial Harbor Offline Appliance with Custom Certs.
```
# Modify disk_size in 'variables.pkr.hcl' to update the disk size.
# Modify files/cert/ca.crt and files/cert/ca.key files in order to add custom certificate.
export HARBOR_VERSION=2.4.1
curl -L "https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/harbor-offline-installer-v${HARBOR_VERSION}.tgz" -o files/harbor-offline-installer-v${HARBOR_VERSION}.tgz
curl -L "https://packages.vmware.com/photon/4.0/Rev2/iso/photon-4.0-c001795b8.iso" -o /tmp/photon-4.0-c001795b8.iso
make build-virtualbox-iso.vagrant-vbx
# use photon-vsphere.ovf or photon-virtualbox.ovf files to import to vsphere or virtualbox.
```