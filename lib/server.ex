defmodule EvilClock.Server do
  use GenServer
  require Logger

  @speed            19200
  @port             "ttyUSB0"
  @serial           Nerves.UART
  @def_clock_addr   "A0"
  @def_scroll_freq  300

  # Server

  def start_link do
    GenServer.start_link(__MODULE__, [@port, @speed], name: __MODULE__)
  end

  def init([port, speed]) do
    @serial.open(Serial, port, speed: speed, active: true)
    @serial.configure(Serial, framing: {Nerves.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{}}
  end

  def handle_cast({:write, framing}, state) do
    write_framing(framing)
    {:noreply, state}
  end

  def handle_info({_app, port, msg}, state) do
    Logger.debug("Received data from clock on #{port}: #{inspect msg}")
    {:noreply, state}
  end

  # Client

  def write_ascii(ascii, points \\ [:none, :none, :none, :none, :none], clock_addr \\ @def_clock_addr)
  def write_ascii(ascii, points, clock_addr) when byte_size(ascii) <= 5 and length(points) == 5 do
    framing = build_ascii_framing(ascii, points, clock_addr)
    GenServer.cast(__MODULE__, {:write, framing})
  end

  def build_ascii_framing(ascii, points, clock_addr) do
    padded_ascii = String.pad_trailing(ascii, 5)

    for p <- points, into: <<0xFF, clock_addr::binary, padded_ascii::binary>>,
      do: dp_string_from_atom(p)
  end

  def dp_string_from_atom(p) do
    case p do
      p when p in [:lower, :l] -> "1"
      p when p in [:upper, :u] -> "2"
      p when p in [:both, :b] ->  "3"
      _ -> "_"
    end
  end

  defp write_framing(framing) do
    @serial.write(Serial, framing)
  end
end
