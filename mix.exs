defmodule Toprox.Mixfile do
  use Mix.Project

  def project do
    [
      app: :toprox,
      version: "0.1.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env),
      package: package(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  def application do
    []
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18.3", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    A simple proxy for different Logger backends which allows to filter messages based on metadata.
    """
  end

  defp package do
    [
      maintainers: ["Eugene Rubashko"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/diyZX/toprox"},
      files: ~w(mix.exs README* lib)
    ]
  end
end
