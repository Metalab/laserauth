# Laserauth

User authentication for a laser cutter using iButton devices.

WIP!

## Setting the polling interval of the onewire bus

$ sudo modprobe -r w1-gpio
$ sudo modprobe -r wire
$ sudo modprobe wire timeout=0 timeout_us=100000
$ sudo modprobe w1-gpio gpiopin=17
