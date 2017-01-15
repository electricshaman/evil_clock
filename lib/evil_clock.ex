defmodule EvilClock do
  use Application

  alias EvilClock.Config

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
end
