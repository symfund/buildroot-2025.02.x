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
![weston](https://private-user-images.githubusercontent.com/1295065/475496824-c24558c6-27d8-4487-9042-0745f89c8613.png?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTQ5MTM3MjYsIm5iZiI6MTc1NDkxMzQyNiwicGF0aCI6Ii8xMjk1MDY1LzQ3NTQ5NjgyNC1jMjQ1NThjNi0yN2Q4LTQ0ODctOTA0Mi0wNzQ1Zjg5Yzg2MTMucG5nP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI1MDgxMSUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNTA4MTFUMTE1NzA2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9ZmVhMTE4NmUxNTBlNWJiNGJiOTlhMjkxZWRhMmExYzY5ODkyMWZmYmZmZmY0NWYzYTFiODZmNjljYmI2OGJhMiZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.J1NNVKQccaQXg64feE5otlaMg--rrgBf-nnQYBesKjc)
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
