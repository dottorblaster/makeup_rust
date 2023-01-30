defmodule Makeup.Lexers.RustLexer.RegistryTest do
  use ExUnit.Case

  alias Makeup.Lexers.RustLexer
  alias Makeup.Registry

  describe "the elixir lexer has successfully registered itself:" do
    test "language name" do
      assert {:ok, {RustLexer, []}} == Registry.fetch_lexer_by_name("rust")
    end

    test "file extension" do
      assert {:ok, {RustLexer, []}} == Registry.fetch_lexer_by_extension("rs")
    end
  end
end
