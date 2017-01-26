defmodule EvilClock do
  use Application

  alias EvilClock.{Config, Server}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Config.get(:evil_clock, :port)
    speed = Config.get(:evil_clock, :speed)

    children = [
      worker(Nerves.UART, [[name: Serial]]),
      worker(EvilClock.Server, [[Serial, port, speed]])
    ]

    opts = [strategy: :rest_for_one, name: EvilClock.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defdelegate display_ascii(ascii, opts \\ []), to: Server
  defdelegate set_time(timestamp, opts \\ []), to: Server
  defdelegate set_time_local(opts \\ []), to: Server
  defdelegate mode_time(opts \\ []), to: Server

end
