defmodule EvilClock.Server do
  use GenServer

  require Logger

  alias Nerves.UART
  alias EvilClock.{Config, Framing}

  @default_opts clock: Config.get(:evil_clock, :primary_clock),
    scroll_rate: Config.get(:evil_clock, :scroll_rate),
    points: List.duplicate(:none, 5),
    resume_time_delay: 500

  # Server

  def start_link([_uart, _port, _speed] = args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([uart, port, speed]) do
    UART.open(uart, port, speed: speed, active: true)
    UART.configure(uart, framing: {UART.Framing.Line, separator: "\r\n"})

    {:ok, {uart}}
  end

  def handle_cast({:write_ascii, ascii, opts}, {uart} = state) when byte_size(ascii) > 5 do
    # Push start of scrolling to the right side
    padded = String.duplicate(" ", 4) <> ascii

    Stream.interval(opts[:scroll_rate])
    |> Stream.take_while(fn(offset) -> offset <= byte_size(padded) end)
    |> Stream.each(fn(offset) -> write_slice(uart, offset, 5, padded, opts) end)
    |> Stream.run

    {:noreply, state}
  end

  def handle_cast({:write_ascii, ascii, opts}, {uart} = state) when byte_size(ascii) <= 5 do
    write_slice(uart, 0, 5, ascii, opts)
    {:noreply, state}
  end

  defp write_slice(uart, offset, length, text, opts) do
    slice = String.slice(text, offset, length) |> String.upcase
    framing = Framing.build_ascii(slice, opts[:points], opts[:clock])
    UART.write(uart, framing)
  end

  def handle_info({_app, port, {:error, reason}}, state) do
    Logger.error("Error involving clock on #{port}: #{inspect reason}")
    {:stop, reason, state}
  end

  def handle_info({_app, port, msg}, state) do
    Logger.debug("Received from clock on #{port}: #{inspect msg} // state: #{inspect state}")
    {:noreply, state}
  end

  # Client API

  def write_ascii(ascii, opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    GenServer.cast(__MODULE__, {:write_ascii, ascii, opts})
  end
end
