defmodule MakeupRust.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_rust,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [],
      mod: {Makeup.Lexers.RustLexer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:makeup, "~> 1.0"},
      {:nimble_parsec, "~> 1.2.3"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs], runtime: false}
    ]
  end
end
