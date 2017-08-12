defmodule BmMigration.Mixfile do
  use Mix.Project

  def project do
    [app: :bm_migration,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :httpoison, :hound]]
  end

  defp deps do
    [{:csv, "~> 2.0"},
     {:envy, "~> 1.1"},
     {:floki, "~> 0.17.2"},
     {:hound, "~> 1.0"},
     {:httpoison, "~> 0.12.0"},
     {:poison, "~> 3.1"}]
  end
end
