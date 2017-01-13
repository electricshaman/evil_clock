defmodule EvilClock.Mixfile do
  use Mix.Project

  def project do
    [app: :evil_clock,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :nerves_uart, :timex],
     mod: {EvilClock, []}]
  end

  defp deps do
    [{:timex, "~> 3.0"},
     {:nerves_uart, "~> 0.1.1"}]
  end
end
