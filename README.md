# Laserauth

User authentication for a laser cutter using iButton devices.

WIP!

Assumes a password protected Tasmota device with power measurement. Requires an iButton reader.

## Installation

### Onewire Setup

In `/boot/config.txt`, add:

```
dtoverlay=w1-gpio,gpiopin=17
```

Adjust the gpio as needed (there's nothing special about pin 17, except that 3.3V and GND are close to it).

Create the file `/etc/modprobe.d/wire.conf` with the following content:

```
options wire timeout=0 timeout_us=100000
```

This is needed for reducing the polling intervals (defaults to 10 seconds, which is fine for temperature sensors, but waaaay to long for iButtons).

#### Hardware

Connect a DS9092 (or similar) to the Pi:

Outside ring to Pi GND. Inside pin to the GPIO set above (17 in the example). A 10kOhm (4.7kOhm is also ok) resistor from the GPIO to 3.3V (used as a digital pullup).

### Flutter App

Follow the steps to install flutter-pi on [their repository](https://github.com/ardera/flutter-pi#compiling):

* Checkout, compile and install flutter-pi (into /usr/local/bin).
* Follow Section "Running your App on the Raspberry Pi".

#### On the dev machine:

* Install flutterpi_tool (`flutter pub global activate flutterpi_tool`).
* Build the project `flutterpi_tool build --arch=arm64 --cpu=pi4 --release`.
* Copy the directory `./build/flutter_assets` over to the Pi (using `scp` or `rsync`).

#### Running:

* Create a config.yaml in the cwd based on the config.sample.yaml included in this git repository.
* On the Pi, run `flutter-pi --release <path-to-flutter_assets>`.

## Setting the polling interval of the onewire bus

This is not how the setup actually looks, but good for testing:

```sh
$ sudo modprobe -r w1-gpio
$ sudo modprobe -r wire
$ sudo modprobe wire timeout=0 timeout_us=100000
$ sudo modprobe w1-gpio gpiopin=17
```

## Notes About The iButton Setup

The way this works might be a bit unintuitive:

Linux comes with a onewire implementation that can use a standard GPIO via bit banging. However, this isn't really designed for iButtons (the protocol is mostly used for temperature sensors and simliar devices).

Using the GPIO bitbanging solution is ok, but has the downside of not having any ESD protection. Other devices that use I2C or SPI are usually better for this, but cost way more (there also no good off-the-shelf solutions for this).

The kernel module w1-gpio is responsible for handling the bit banging. The protocol itself is implemented in the wire kernel module. Thus, the pin to be used for this is set as an option to the module w1-gpio and everything else is on the wire module.

The wire module checks for new devices by polling. Thus, if you want to get timely notification of new iButtons, this polling interval has to be reduced dramatically (see above on instructions on how to do that).

When a new device is detected, it's attached to the kernel as a hardware device on the w1 subsystem. So, the application uses udev monitoring to get notifications for new devices on that subsystem. For some reason, device removals aren't reported, but this is not needed for this application anyways.
