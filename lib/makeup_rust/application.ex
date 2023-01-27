defmodule MakeupRust.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Makeup.Registry
  alias Makeup.Lexers.RustLexer

  @impl true
  def start(_type, _args) do
    Registry.register_lexer(RustLexer,
      options: [],
      names: ["rust"],
      extensions: ["rs"]
    )

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
