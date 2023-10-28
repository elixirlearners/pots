defmodule Pots.MixProject do
  use Mix.Project

  def project do
    [
      app: :pots,
      version: "0.1.2",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),

      # Docs
      name: "Pots",
      source_url: "https://github.com/elixirlearners/pots",
      authors: [
        "Caleb Gasser"
      ],
      docs: [
        extras: ["README.md", "LICENSE", "CHANGELOG.md"]
      ]
    ]
  end

  defp description() do
    """
    Some wrapper functionality around generating Dockerfiles and managing them
    for an elixir project. This project is still very much in the early stages
    so use at your own risk. 
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.30.9", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
                CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elixirlearners/pots"}
    ]
  end
end
