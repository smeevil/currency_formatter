defmodule CurrencyFormatter.Mixfile do
  use Mix.Project

  def project do
    [app: :currency_formatter,
     version: "0.0.1",
     description: "A function to format a number to a currency using iso standards",
     package: package,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
        {:poison  , ">0.0.0"},
        {:earmark , "~> 0.1"  , only: :dev},
        {:ex_doc  , "~> 0.11" , only: :dev}
    ]
  end
  defp package do
    [
      maintainers: "Gerard de Brieder",
      licenses: "WTFPL",
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      links: %{
        "GitHub" => "https://github.com/smeevil/currency_formatter",
        "Docs"   => "http://smeevil.github.io/currency_formatter/"
      }
    ]
  end
end
