use Mix.Config

config :evil_clock,
  port: "ttyUSB0",
  speed: 19200,
  firmware_version: 2,
  primary_clock: "A0",
  scroll_rate: 250
