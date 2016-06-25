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

```elixir
  iex> CurrencyFormatter.instructions(:EUR)
  %{"alternate_symbols" => [], "decimal_mark" => ",", "html_entity" => "&#x20AC;",
  "iso_code" => "EUR", "iso_numeric" => "978", "name" => "Euro", "priority" => 2,
  "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100,
  "symbol" => "€", "symbol_first" => true, "thousands_separator" => "."}

```

```elixir
  iex> currencies = CurrencyFormatter.get_currencies()
  iex> Enum.count(currencies)
  165
  iex> currencies["usd"]
  %{"alternate_symbols" => ["US$"], "decimal_mark" => ".", "html_entity" => "$",
    "iso_code" => "USD", "iso_numeric" => "840", "name" => "United States Dollar",
    "priority" => 1, "smallest_denomination" => 1, "subunit" => "Cent",
    "subunit_to_unit" => 100, "symbol" => "$", "symbol_first" => true,
    "thousands_separator" => ","}
```
## Installation

As this is [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add currency_formatter to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:currency_formatter, "~> 0.0.1"}]
end
```

## Documentation

API documentation is available at [https://hexdocs.pm/currency_formatter](https://hexdocs.pm/currency_formatter)

