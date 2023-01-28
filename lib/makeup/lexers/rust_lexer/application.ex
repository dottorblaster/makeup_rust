defmodule Makeup.Lexers.RustLexer.Application do
  @moduledoc false

  use Application

  alias Makeup.Registry
  alias Makeup.Lexers.RustLexer

  def start(_type, _args) do
    IO.inspect "ciaooo"
    Registry.register_lexer(RustLexer,
      options: [],
      names: ["rust"],
      extensions: ["rs"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
