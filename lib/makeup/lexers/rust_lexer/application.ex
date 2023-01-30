defmodule Makeup.Lexers.RustLexer.Application do
  @moduledoc false

  use Application

  alias Makeup.Lexers.RustLexer
  alias Makeup.Registry

  def start(_type, _args) do
    Registry.register_lexer(RustLexer,
      options: [],
      names: ["rust"],
      extensions: ["rs"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
