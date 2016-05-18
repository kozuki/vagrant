cd /d %~dp0
VBoxManage clonehd box-disk1.vmdk cloned-box-disk1.vdi --format vdi
VBoxManage modifyhd cloned-box-disk1.vdi --resize 32768
VBoxManage clonehd cloned-box-disk1.vdi box-disk2.vmdk --format vmdk
del cloned-box-disk1.vdi
