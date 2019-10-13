defmodule Aisf.MixProject do
  use Mix.Project

  def project do
    [
      app: :aisf,
      version: "0.1.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Aisf.Application, []},
      extra_applications: [:logger, :runtime_tools, :edeliver]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, ">= 3.2.0 and < 3.5.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:absinthe_ecto, "~> 0.1.3"},
      {:absinthe_plug, "~> 1.4.0"},
      {:poison, "~> 3.0"},
      {:bcrypt_elixir, "~> 2.0.3"},
      {:wallaby, "~> 0.23.0", [runtime: false, only: :test]},
      {:faker, "~> 0.12", only: [:dev, :test]},
      {:ex_url, "~> 1.1"},
      {:edeliver, ">= 1.7.0"},
      {:distillery, "~> 2.1", warn_missing: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
