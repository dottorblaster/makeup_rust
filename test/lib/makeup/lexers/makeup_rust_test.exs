defmodule MakeupRustTest do
  use ExUnit.Case

  import Makeup.Lexers.RustLexer.Testing

  test "greets the world" do
    assert lex("use crate::{Type, subcrate};") ==
             [
               {:keyword, %{}, "use"},
               {:whitespace, %{}, " "},
               {:keyword, %{}, "crate"},
               {:operator, %{}, ":"},
               {:operator, %{}, ":"},
               {:punctuation, %{group_id: "group-1"}, "{"},
               {:name_constant, %{}, "Type"},
               {:punctuation, %{}, ","},
               {:whitespace, %{}, " "},
               {:name, %{}, "subcrate"},
               {:punctuation, %{group_id: "group-1"}, "}"},
               {:punctuation, %{}, ";"}
             ]
  end
end
