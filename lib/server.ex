defmodule EvilClock.Server do
  use GenServer
  use Timex

  require Logger

  alias Nerves.UART
  alias EvilClock.{Config, Framing}

  @default_opts clock: Config.get(:evil_clock, :primary_clock),
    scroll_rate: Config.get(:evil_clock, :scroll_rate),
    fw_ver: Config.get(:evil_clock, :firmware_version),
    points: List.duplicate(:none, 5),
    resume_after: 1000

  # Server

  def start_link([_uart, _port, _speed] = args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([uart, port, speed]) do
    Logger.debug("Evil clock server starting")

    UART.open(uart, port, speed: speed, active: true)
    UART.configure(uart, framing: {UART.Framing.Line, separator: "\r\n"})

    {:ok, {uart}}
  end

  def handle_cast({:display_ascii, ascii, opts}, {uart} = state) when byte_size(ascii) > 5 do
    # Push start of scrolling to the right side
    padded = String.duplicate(" ", 4) <> ascii

    Stream.interval(opts[:scroll_rate])
    |> Stream.take_while(fn(offset) -> offset <= byte_size(padded) end)
    |> Stream.each(fn(offset) -> write_slice(uart, offset, 5, padded, opts) end)
    |> Stream.run

    schedule_mode_time(opts)
    {:noreply, state}
  end

  def handle_cast({:display_ascii, ascii, opts}, {uart} = state) when byte_size(ascii) <= 5 do
    write_slice(uart, 0, 5, ascii, opts)

    schedule_mode_time(opts)
    {:noreply, state}
  end

  def handle_cast({:set_time, timestamp, opts}, {uart} = state) do
    framing = Framing.build_set_time_frame(timestamp, opts[:fw_ver])
    UART.write(uart, framing)
    {:noreply, state}
  end

  def handle_cast({:mode_time, opts}, {uart} = state) do
    handle_mode_time(uart, opts)
    {:noreply, state}
  end

  def handle_info({:mode_time, opts}, {uart} = state) do
    handle_mode_time(uart, opts)
    {:noreply, state}
  end

  def handle_info({_app, port, {:error, reason}}, state) do
    Logger.error("Error involving clock on #{port}: #{inspect reason}")
    {:stop, reason, state}
  end

  def handle_info({_app, port, msg}, state) do
    Logger.debug("Received from clock on #{port}: #{inspect msg} // state: #{inspect state}")
    {:noreply, state}
  end

  defp write_slice(uart, offset, length, text, opts) do
    slice = String.slice(text, offset, length) |> String.upcase
    framing = Framing.build_ascii_frame(slice, opts[:points], opts[:clock], opts[:fw_ver])
    UART.write(uart, framing)
  end

  defp schedule_mode_time(opts) do
    Process.send_after(self(), {:mode_time, opts}, opts[:resume_after])
  end

  defp handle_mode_time(uart, opts) do
    framing = Framing.build_mode_time_frame(opts[:fw_ver])
    UART.write(uart, framing)
  end

  # Client API

  def display_ascii(ascii, opts \\ []) do
    # TODO: Separate options for different commands
    opts = Keyword.merge(@default_opts, opts)
    GenServer.cast(__MODULE__, {:display_ascii, ascii, opts})
  end

  def set_time(timestamp, opts \\ [])
  def set_time(timestamp, opts) when is_binary(timestamp) do
    opts = Keyword.merge(@default_opts, opts)
    GenServer.cast(__MODULE__, {:set_time, timestamp, opts})
  end
  def set_time(timestamp, opts) when is_integer(timestamp) do
    set_time(timestamp |> to_string, opts)
  end

  def set_time_local(opts \\ []) do
    utc_offset = Timezone.local |> Timezone.total_offset
    timestamp = Timex.local |> Timex.shift(seconds: utc_offset) |> Timex.to_unix
    set_time(timestamp, opts)
  end

  def mode_time(opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    GenServer.cast(__MODULE__, {:mode_time, opts})
  end
end
