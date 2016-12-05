defmodule EvilClock do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Nerves.UART, [[name: Serial]]),
      worker(EvilClock.Server, [])
    ]

    opts = [strategy: :rest_for_one, name: EvilClock.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
