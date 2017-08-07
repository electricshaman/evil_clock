defmodule EvilClock.Mixfile do
  use Mix.Project

  def project do
    [app: :evil_clock,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  def application do
    [applications: [:logger, :nerves_uart, :timex],
     mod: {EvilClock, []}]
  end

  defp deps do
    [{:timex, "~> 3.0"},
     {:nerves_uart, "~> 0.1.1"},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp description do
    """
    Elixir application for interfacing with Alpha Clock Five from Evil Mad Scientist Laboratories
    """
  end

  defp package do
    [name: :evil_clock,
     maintainers: ["Jeff Smith"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/electricshaman/evil_clock"}]
  end
end
