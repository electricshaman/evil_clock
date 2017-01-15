defmodule EvilClock.Server do
  use GenServer

  require Logger

  alias Nerves.UART
  alias EvilClock.{Config, Framing}

  @primary_clock  Config.get(:evil_clock, :primary_clock)
  @scroll_freq    Config.get(:evil_clock, :scroll_frequency)

  @def_dec_points [:none, :none, :none, :none, :none]

  # Server

  def start_link([_uart, _port, _speed] = args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([uart, port, speed]) do
    UART.open(uart, port, speed: speed, active: true)
    UART.configure(uart, framing: {UART.Framing.Line, separator: "\r\n"})

    {:ok, {uart}}
  end

  def handle_cast({:write, framing}, {uart} = state) do
    UART.write(uart, framing)
    {:noreply, state}
  end

  def handle_info({_app, port, {:error, reason}}, state) do
    Logger.error("Received error from clock: #{inspect reason}")
    {:stop, reason, state}
  end

  def handle_info({_app, port, msg}, state) do
    Logger.debug("Received from clock on #{port}: #{inspect msg} // state: #{inspect state}")
    {:noreply, state}
  end

  # Client API

  def write_ascii(ascii, points \\ @def_dec_points, clock \\ @primary_clock)
  def write_ascii(ascii, points, clock) when byte_size(ascii) <= 5 and length(points) == 5 do
    framing = Framing.build_ascii(ascii, points, clock)
    GenServer.cast(__MODULE__, {:write, framing})
  end

end
