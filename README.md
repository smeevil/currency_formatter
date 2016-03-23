# CurrencyFormatter

This package offers an Elixir function to format a number to a currency using ISO standards.

The JSON iso data has been gracefully borrowed from the [ruby money](https://github.com/RubyMoney/money/blob/master/config/currency_iso.json) gem.

## Examples :

```elixir
    iex> CurrencyFormatter.format(123456)
    "$1,234.56"

    iex> CurrencyFormatter.format(654321, :eur)
    "€6.543,21"

    iex> CurrencyFormatter.format(654321, "AUD")
    "A$6,543.21"
```

## Installation

As this is [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add currency_formatter to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:currency_formatter, "~> 0.0.1"}]
end
```


