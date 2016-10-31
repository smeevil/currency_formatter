defmodule CurrencyFormatter.Mixfile do
  use Mix.Project

  def project do
    [
      app: :currency_formatter,
      version: "0.4.3",
      description: "A library to help with formatting a number to a currency using iso standards and other convenience functions related to formatting currencies",
      package: package,
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      test_coverage: [tool: ExCoveralls]
     ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
        {:poison  , "~> 3.0.0"},
        {:earmark , "~>1.0.2"  , only: :dev},
        {:ex_doc  , "~>0.14.3" , only: :dev},
        {:excoveralls, "~> 0.5.7", only: :test},
    ]
  end
  defp package do
    [
      maintainers: ["Gerard de Brieder"],
      licenses: ["WTFPL"],
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      links: %{
        "GitHub" => "https://github.com/smeevil/currency_formatter",
        "Docs"   => "http://smeevil.github.io/currency_formatter/"
      }
    ]
  end
end
