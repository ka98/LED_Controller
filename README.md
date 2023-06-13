# HUB75 Driver for Pynq-Z2 FPGA

## Description

This Project uses a Pynq-Z2 FPGA connected to an Adafruit 64x64 3mm Pixel Matrix connected via Adafruit RGB Matrix HAT for Raspberry Pi.

Currently this project contains a ROM with a rainbow test pattern. The Rom is connected directly to the `to_display` module which creates the **HUB75** signal. The clock for the module is driven by the PS - System.

The Project was built using Vivado **2022.1**

## Roadmap

- [ ] Refactoring `to_display` module to a proper IP-Core
- [ ] Baremetal Driver for setting Pixels / drawing Lines etc.
- [ ] Petalinux

## Building and running

you can directly build and run the project by using the following command:

```shell
make all
```

the script expects:

- vivado/bin being part of $PATH
- Vitis being stored to `/opt/xilinx/Vitis/2022.1`

## Known-Issues

The ICs on the pixel matrix i use (Adafruit 64x64 3mm) are only able to be driven with a 30Mhz clock, so i have to set `BIT_DEPTH` to 7 bits to keep a useable refreshrate.

## Links to parts used in this project

|Name|Link|
|--|--|
|Pynq-Z2 FPGA|https://www.tulembedded.com/FPGA/ProductsPYNQ-Z2.html|
|Adafruit RGB Matrix HAT + RTC for Raspberry Pi - Mini Kit|https://www.adafruit.com/product/2345|
|Adafruit 64x64 RGB LED Matrix - 3mm Pitch - 192mm x 192mm|https://www.adafruit.com/product/4732|