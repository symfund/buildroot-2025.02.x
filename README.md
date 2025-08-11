# Buildroot LTS 2025.02.4
Keep up with the latest long term support Buildroot 2025.02.4 release for Nuvoton SoC.

# Build with Raspberry Pi 5 on Ubuntu 25.04
DO NOT WASTE YOUR Raspberry Pi 5. 

The following boards are verified using Raspberry Pi 5 as the build machine.
1. NuMaker-SOM-MA35D16A910 V2.2
2. NuMaker-HMI-MA35H04F70 V1.0
3. NuMaker-IoT-MA35D16F70 V2.2
4. NuMaker-SOM-MA35D16A81 V2.1

# Configuring Weston in Buildroot
1. Git clone this repository
   $ git clone https://github.com/symfund/buildroot-2025.02.x.git
2. Change directory to the root of Buildroot
   $ cd buildroot-2025.02.x
3. List all default board configuration files for MA35 SoC
   $ make list-defconfigs | grep ma35
4. Load a specific buildroot configuration file for target board
   $ make numaker_som_ma35d16a910_defconfig
5. Configure buildroot
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
7. Make bootable SD
   $ sudo dd if=output/images/<core-image-file-for-sdcard> of=/dev/sdb conv=fsync 
