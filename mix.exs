defmodule CurrencyFormatter.Mixfile do
  use Mix.Project

  def project do
    [app: :currency_formatter,
     version: "0.4.0",
     description: "A library to help with formatting a number to a currency using iso standards and other convenience functions related to formatting currencies",
     package: package,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
        {:poison  , "~> 2.2.0"},
        {:earmark , "~> 0.2.1"  , only: :dev},
        {:ex_doc  , "~> 0.12.0" , only: :dev}
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
