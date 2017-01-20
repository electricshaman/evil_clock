defmodule EvilClock.Framing do
  @doc """
  Build a single serial message frame for the Ax (ASCII Display) command.

    ## Examples

    iex> EvilClock.Framing.build_ascii_frame("HELLO", List.duplicate(:none, 5), "A0", 1)
    <<255, 65, 48, 72, 69, 76, 76, 79, 95, 95, 95, 95, 95>>

    iex> EvilClock.Framing.build_ascii_frame("HELLO", List.duplicate(:both, 5), "A0", 1)
    <<255, 65, 48, 72, 69, 76, 76, 79, 66, 66, 66, 66, 66>>

    iex> EvilClock.Framing.build_ascii_frame("HELLO", [:u, :l, :u, :l, :none], "A0", 1)
    <<255, 65, 48, 72, 69, 76, 76, 79, 85, 76, 85, 76, 95>>

    iex> EvilClock.Framing.build_ascii_frame("HELLO", List.duplicate(:none, 5), "A0", 2)
    <<255, 65, 48, 72, 69, 76, 76, 79, 95, 95, 95, 95, 95>>

    iex> EvilClock.Framing.build_ascii_frame("HELLO", List.duplicate(:both, 5), "A0", 2)
    <<255, 65, 48, 72, 69, 76, 76, 79, 51, 51, 51, 51, 51>>

    iex> EvilClock.Framing.build_ascii_frame("HELLO", [:u, :l, :u, :l, :none], "A0", 2)
    <<255, 65, 48, 72, 69, 76, 76, 79, 50, 49, 50, 49, 95>>

  """
  def build_ascii_frame(ascii, points, clock_addr, fw_ver) do
    padded_ascii = String.pad_trailing(ascii, 5)

    for p <- points, into: <<0xFF, clock_addr::binary, padded_ascii::binary>>,
      do: dec_point_from_atom(p, fw_ver)
  end

  @doc """
  Translate an atom representing a decimal point segment into its corresponding protocol value for firmware v1.0.
  """
  def dec_point_from_atom(p, 1) do
    case p do
      p when p in [:lower, :l] -> "L"
      p when p in [:upper, :u] -> "U"
      p when p in [:both, :b] ->  "B"
      _ -> "_"
    end
  end

  @doc """
  Translates an atom representing a decimal point segment into its corresponding protocol value for firmware v2.0.

    ## Examples

    ### Firmware 1.0

    iex> EvilClock.Framing.dec_point_from_atom(:lower, 1)
    "L"
    iex> EvilClock.Framing.dec_point_from_atom(:l, 1)
    "L"

    iex> EvilClock.Framing.dec_point_from_atom(:upper, 1)
    "U"
    iex> EvilClock.Framing.dec_point_from_atom(:u, 1)
    "U"

    iex> EvilClock.Framing.dec_point_from_atom(:both, 1)
    "B"
    iex> EvilClock.Framing.dec_point_from_atom(:b, 1)
    "B"

    iex> EvilClock.Framing.dec_point_from_atom(:other, 1)
    "_"

    ### Firmware >= 2.0

    iex> EvilClock.Framing.dec_point_from_atom(:lower, 2)
    "1"
    iex> EvilClock.Framing.dec_point_from_atom(:l, 2)
    "1"

    iex> EvilClock.Framing.dec_point_from_atom(:upper, 2)
    "2"
    iex> EvilClock.Framing.dec_point_from_atom(:u, 2)
    "2"

    iex> EvilClock.Framing.dec_point_from_atom(:both, 2)
    "3"
    iex> EvilClock.Framing.dec_point_from_atom(:b, 2)
    "3"

    iex> EvilClock.Framing.dec_point_from_atom(:other, 2)
    "_"

  """
  def dec_point_from_atom(point, fw_ver) when fw_ver >= 2 do
    case point do
      point when point in [:lower, :l] -> "1"
      point when point in [:upper, :u] -> "2"
      point when point in [:both, :b] ->  "3"
      _ -> "_"
    end
  end

  @doc """
  Build a single serial message frame for the ST (Set Time) command.

    ## Examples

    iex> EvilClock.Framing.build_set_time_frame("1484811870", 1)
    <<255, 83, 84, 49, 52, 56, 52, 56, 49, 49, 56, 55, 48>>

    iex> EvilClock.Framing.build_set_time_frame("1484811870", 2)
    <<255, 83, 84, 49, 52, 56, 52, 56, 49, 49, 56, 55, 48>>

  """
  def build_set_time_frame(timestamp, _fw_ver) do
    <<0xFF, "ST", timestamp::binary>>
  end

  @doc """
  Build a single serial message frame for the MT (Mode Time) command.

    ## Examples

    iex> EvilClock.Framing.build_mode_time_frame(1)
    <<255, 77, 84, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32>>

    iex> EvilClock.Framing.build_mode_time_frame(2)
    <<255, 77, 84, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32>>

  """
  def build_mode_time_frame(_fw_ver) do
    <<0xFF, "MT", String.duplicate(" ", 10)::binary>>
  end
end
