# HUB75 Driver for Pynq-Z2 FPGA

off              |  on
:-------------------------:|:-------------------------:
![IMG_1731](https://user-images.githubusercontent.com/8614259/217651721-1cfbc688-71d6-46dd-961e-2d30e4304b35.png) |  ![IMG_1729](https://user-images.githubusercontent.com/8614259/217651710-e24480d2-ee9b-486f-aff3-fe7ce93226d5.png)|



## Description

This Project uses a Pynq-Z2 FPGA connected to an Adafruit 64x64 3mm Pixel Matrix connected via Adafruit RGB Matrix HAT for Raspberry Pi.

Currently this project contains a ROM with a rainbow test pattern. The Rom is connected directly to the `to_display` module which creates the **HUB75** signal. The clock for the module is driven by the PS - System.

The Project was built using Vivado **2022.1**

## Roadmap

- [ ] Refactoring `to_display` module to a proper IP-Core
- [ ] Baremetal Driver for setting Pixels / drawing Lines etc.
- [ ] Petalinux

## Building and running

you can directly build and run the project by using the following command
the script expects:

- vivado/bin being part of $PATH
- Vitis being stored to `/opt/xilinx/Vitis/2022.1`

```shell
make all
```

## Known-Issues

The ICs on the pixel matrix i use (Adafruit 64x64 3mm) are only able to be driven with a 30Mhz clock, so i have to set `BIT_DEPTH` to 7 bits to keep a useable refreshrate.

## Links to parts

|Name|Link|
|--|--|
|Pynq-Z2 FPGA|https://www.tulembedded.com/FPGA/ProductsPYNQ-Z2.html|
|Adafruit RGB Matrix HAT + RTC for Raspberry Pi - Mini Kit|https://www.adafruit.com/product/2345|
|Adafruit 64x64 RGB LED Matrix - 3mm Pitch - 192mm x 192mm|https://www.adafruit.com/product/4732|
