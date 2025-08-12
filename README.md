# Buildroot LTS 2025.02.4
Keep up with the latest long term support Buildroot 2025.02.4 release for Nuvoton SoC.

# Build with Raspberry Pi 5 on Ubuntu 25.04
DO NOT WASTE YOUR Raspberry Pi 5. 

The following boards are verified using Raspberry Pi 5 as the build machine.
1. NuMaker-SOM-MA35D16A910 V2.2
2. NuMaker-HMI-MA35H04F70 V1.0
3. NuMaker-IoT-MA35D16F70 V2.2
4. NuMaker-SOM-MA35D16A81 V2.1

# Configure Weston in Buildroot

```
1. Git clone this repository
   $ git clone https://github.com/symfund/buildroot-2025.02.x.git
2. Change directory to the root of Buildroot
   $ cd buildroot-2025.02.x
3. List all default board configuration files for MA35 SoC
   $ make list-defconfigs | grep ma35
4. Load a specific buildroot configuration file for target board
   $ make numaker_som_ma35d16a910_defconfig
5. Configure buildroot
   $ make menuconfig
   --> System configuration --> /dev management
           (X) Dynamic using devtmpfs + eudev

   --> Target packages --> Fonts, cursors, icons and themes
           [*] Liberation (Free fonts)
           [*]     mono fonts
      
   --> Target packages --> Graphic libraries and applications
           [*] weston
           [*] mesa3d
           [*]     Gallium swrast driver
           [*]     OpenGL ES
           [*]     OpenGL EGL 
6. Build firmware
   $ make
7. Make the bootable SD card
   Before making bootable SD, execute fdisk to check the real device path of your SD card.
   $ sudo fdisk -l
   $ sudo dd if=output/images/core-image-buildroot-ma35d1-som-256m.rootfs.sdcard of=/dev/sdb conv=fsync
8. Configure boot jumper pins to boot from SD card 
   _____________________________________________________________
   boot device | PG0 | PG1 | PG2 | PG3 | PG4 | PG5 | PG6 | PG7 |
   -------------------------------------------------------------
```

# Change boot device
By default, the boot device is SD0, if you want to build system image booting from another device (SPI-NAND).
- Configure buildroot again,
```
$ make menuconfig
-->Bootloaders --> Board defconfig
       ma35d1_spinand
```
- Rebuild system without (dist)clean
```
$ make uboot-dirclean uboot-rebuild; for pkg in $(make uboot-show-recursive-rdepends); do make $pkg-rebuild; done; make
```

# Change board configuration
When complete building system image for one board, if you want to build for another board,

- Load another board configuration (configs/*_defconfig)
```
$ make list-defconfigs | grep ma35
$ make numaker_iot_ma35d16f90_defconfig
```
- First clean, then build
```
$ rm -rf output/images; mkdir -p output/images
$ make arm-trusted-firmware-dirclean uboot-dirclean optee-os-dirclean linux-dirclean
$ make
```

# Configure Airplay
Launch **make menuconfig** to configure buildroot, find airplay and enable it in the following path
```
$ make menuconfig
-->Target packages -->Networking applications
   [*] airplay
$ make
```
