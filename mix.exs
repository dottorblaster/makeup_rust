defmodule MakeupRust.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_rust,
      description: description(),
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        extras: ["README.md"],
        main: "Makeup.Lexers.RustLexer"
      ],
      package: package()
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
      {:makeup, "~> 1.1"},
      {:nimble_parsec, "~> 1.4.0"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description(), do: "Rust lexer for Makeup"

  defp package() do
    [
      name: "makeup_rust",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["BSD"],
      links: %{"GitHub" => "https://github.com/dottorblaster/makeup_rust"}
    ]
  end
end
