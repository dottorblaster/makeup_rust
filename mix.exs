defmodule MakeupRust.MixProject do
  use Mix.Project

  def project do
    [
      app: :makeup_rust,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [],
      mod: {MakeupRust.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:makeup, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :docs]}
    ]
  end
end
