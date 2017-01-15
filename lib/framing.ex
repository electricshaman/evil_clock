defmodule EvilClock.Framing do
  def build_ascii(ascii, points, clock_addr) do
    padded_ascii = String.pad_trailing(ascii, 5)

    for p <- points, into: <<0xFF, clock_addr::binary, padded_ascii::binary>>,
      do: dec_point_string_from_atom(p)
  end

  def dec_point_string_from_atom(p) do
    case p do
      p when p in [:lower, :l] -> "1"
      p when p in [:upper, :u] -> "2"
      p when p in [:both, :b] ->  "3"
      _ -> "_"
    end
  end
end
