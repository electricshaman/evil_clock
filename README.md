# Evil Clock

Elixir application for interfacing with [Alpha Clock Five](http://shop.evilmadscientist.com/productsmenu/tinykitlist/447) from Evil Mad Scientist Laboratories

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `evil_clock` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:evil_clock, "~> 0.1.0"}]
    end
    ```

  2. Ensure `evil_clock` is started before your application:

    ```elixir
    def application do
      [applications: [:evil_clock]]
    end
    ```

