# Evil Clock

Elixir application for interfacing with [Alpha Clock Five](http://www.evilmadscientist.com/2011/alpha-clock-five/) from Evil Mad Scientist Laboratories

![Alpha Clock Five](https://c1.staticflickr.com/8/7009/6505330263_b18b23b9a7_n.jpg "Alpha Clock Five")![World](https://c1.staticflickr.com/8/7147/6505327051_de08b7d603_n.jpg "Alpha Clock Five")

Communicate with the evil clock's microcontroller using a simple protocol over TTL serial.  You'll need a serial TTL-232 cable such as the [FTDI Serial TTL-232 USB Cable](https://www.adafruit.com/products/70) from Adafruit.

Currently supports the following commands from firmware versions 1.0 and 2.0:

 - `ST`: Set Time
 - `A0/Ax`: ASCII Display
 - `MT`: Mode Time

## Usage

  1. Ensure `evil_clock` is started before your application:

    ```elixir
    def application do
      [applications: [:evil_clock]]
    end
    ```

  2. Configure settings in `config/config.exs`:

    ```elixir
	config :evil_clock,
	  port: "ttyUSB0",
	  speed: 19200,
	  firmware_version: 2,
	  primary_clock: "A0",
	  scroll_rate: 250
    ```

  3. Start your application, and call the clock using functions on `EvilClock.Server`:
	  - `display_ascii`
	  - `set_time`
	  - `set_local_time`
	  - `mode_time`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `evil_clock` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:evil_clock, "~> 0.1.0"}]
    end
    ```

  2. Ensure `evil_clock` is started before your application:

    ```elixir
    def application do
      [applications: [:evil_clock]]
    end
    ```

## Copyright and License
Copyright (c) 2017 Jeff Smith

Evil Clock source code is licensed under the [MIT License](https://github.com/electricshaman/evil_clock/blob/master/LICENSE).
