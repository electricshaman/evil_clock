defmodule EvilClock.Server do
  use GenServer
  require Logger

  @speed 19200
  @port "ttyUSB0"
  @serial Nerves.UART

  def start_link do
    GenServer.start_link(__MODULE__, [@port, @speed], name: __MODULE__)
  end

  def init([port, speed]) do
    @serial.open(Serial, port, speed: speed, active: true)
    @serial.configure(Serial, framing: {Nerves.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{}}
  end

  def write_alpha(alpha, points \\ [:none, :none, :none, :none, :none])
  def write_alpha(alpha, points) when is_binary(alpha) and byte_size(alpha) <= 5 and length(points) == 5 do
    contents = build_alpha_contents(alpha, points)
    GenServer.cast(__MODULE__, {:write, contents})
  end

  def build_alpha_contents(alpha, points) do
    padded_alpha = String.pad_trailing(alpha, 5)
    pre = <<0xFF, "A0">> <> padded_alpha
    for p <- points, into: pre do
      case p do
        p when p in [:lower, :l] -> "1"
        p when p in [:upper, :u] -> "2"
        p when p in [:both, :b] -> "3"
        _ -> "_"
      end
    end
  end

  def handle_cast({:write, msg}, state) do
    write(msg)
    {:noreply, state}
  end

  def handle_info({_app, port, msg}, state) do
    Logger.debug("Received from clock on #{port}: #{inspect msg}")
    {:noreply, state}
  end

  defp write(msg) do
    @serial.write(Serial, msg)
  end
end
