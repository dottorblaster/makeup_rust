defmodule Makeup.Lexers.RustLexer.Testing do
  @moduledoc false
  # The tests need to be checked manually!!! (remove this line when they've been checked)
  alias Makeup.Lexers.RustLexer
  alias Makeup.Lexer.Postprocess

  def lex(text) do
    text
    |> RustLexer.lex(group_prefix: "group")
    |> Postprocess.token_values_to_binaries()
    |> Enum.map(fn {ttype, meta, value} -> {ttype, Map.delete(meta, :language), value} end)
  end
end
