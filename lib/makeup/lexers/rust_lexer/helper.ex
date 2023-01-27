defmodule Makeup.Lexers.RustLexer.Helper do
  import NimbleParsec

  def with_optional_separator(combinator, separator) when is_binary(separator) do
    combinator |> repeat(string(separator) |> concat(combinator))
  end
end
