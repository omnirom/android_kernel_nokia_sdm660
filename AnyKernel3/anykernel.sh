# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=FireKernel by theimpulson @ xda-developers
do.devicecheck=0
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=PL2
device.name2=PL2_sprout
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## begin vendor changes
mount -o rw,remount -t auto /vendor >/dev/null;

# Make a backup of vendor build.prop
restore_file /vendor/build.prop;
backup_file /vendor/build.prop;

# Add performance tweaks
append_file /vendor/build.prop "FKProps" build.prop

## AnyKernel install
dump_boot;

# If the kernel image and dtbs are separated in the zip
decompressed_image=/tmp/anykernel/Image
compressed_image=$decompressed_image.gz
if [ -f $compressed_image ]; then
  # Hexpatch the kernel if Magisk is installed ('skip_initramfs' -> 'want_initramfs')
  if [ -d $ramdisk/.backup ]; then
    ui_print " "; ui_print "Magisk detected! Patching kernel so reflashing Magisk is not necessary...";
    $bin/magiskboot --decompress $compressed_image $decompressed_image;
    $bin/magiskboot --hexpatch $decompressed_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
    $bin/magiskboot --compress=gzip $decompressed_image $compressed_image;
  fi;

  # Concatenate all of the dtbs to the kernel
  cat $compressed_image /tmp/anykernel/*.dtb > /tmp/anykernel/Image.gz-dtb;
fi;

write_boot;
## end install

