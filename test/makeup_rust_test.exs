defmodule MakeupRustTest do
  use ExUnit.Case

  test "greets the world" do
    assert Makeup.Lexers.RustLexer.lex("use crate::{Type, subcrate};") == [
             {:keyword, %{language: :rust}, "use"},
             {:whitespace, %{language: :rust}, " "},
             {:keyword, %{language: :rust}, "crate"},
             {:operator, %{language: :rust}, ":"},
             {:operator, %{language: :rust}, ":"},
             {:punctuation, %{group_id: "3158012706-1", language: :rust}, "{"},
             {:name_constant, %{language: :rust}, ["T", "ype"]},
             {:punctuation, %{language: :rust}, ","},
             {:whitespace, %{language: :rust}, " "},
             {:name, %{language: :rust}, "subcrate"},
             {:punctuation, %{group_id: "3158012706-1", language: :rust}, "}"},
             {:punctuation, %{language: :rust}, ";"}
           ]
  end
end
