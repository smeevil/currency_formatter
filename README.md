# CurrencyFormatter
![](https://img.shields.io/hexpm/v/currency_formatter.svg) ![](https://img.shields.io/hexpm/dt/currency_formatter.svg) ![](https://img.shields.io/hexpm/dw/currency_formatter.svg) ![](https://img.shields.io/coveralls/smeevil/currency_formatter.svg) ![](https://img.shields.io/github/issues/smeevil/currency_formatter.svg) ![](https://img.shields.io/github/issues-pr/smeevil/currency_formatter.svg) ![](https://semaphoreci.com/api/v1/smeevil/currency_formatter/branches/master/shields_badge.svg)

This package offers an Elixir function to format a number to a currency using ISO standards.

The JSON iso data has been gracefully borrowed from the [ruby money](https://github.com/RubyMoney/money/blob/master/config/currency_iso.json) gem.

## Examples :

Formatting cents to currency string
```elixir
iex> CurrencyFormatter.format(654321, :eur)
"€6.543,21"


iex> CurrencyFormatter.format(123456)
"$1,234.56"

iex> CurrencyFormatter.format(654321, "AUD")
"$6,543.21"

iex> CurrencyFormatter.format(123456, disambiguate: true)
"US$1,234.56"

iex> CurrencyFormatter.format(654321, "AUD", disambiguate: true)
"A$6,543.21"
```

Requesting formatting instructions for a currency

```elixir
iex> CurrencyFormatter.instructions(:EUR)
%{"alternate_symbols" => [], "decimal_mark" => ",", "html_entity" => "&#x20AC;",
  "iso_code" => "EUR", "iso_numeric" => "978", "name" => "Euro", "priority" => 2,
  "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100,
  "symbol" => "€", "symbol_first" => true, "thousands_separator" => "."}
```

Get a map of all currencies and their instructions
```elixir
iex> currencies = CurrencyFormatter.get_currencies()
iex> Enum.count(currencies)
172
iex> currencies["usd"]
%{"alternate_symbols" => ["US$"], "decimal_mark" => ".",
  "disambiguate_symbol" => "US$", "html_entity" => "$", "iso_code" => "USD",
  "iso_numeric" => "840", "name" => "United States Dollar", "priority" => 1,
  "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100,
  "symbol" => "$", "symbol_first" => true, "thousands_separator" => ","}
```

Getting a list of tuples for use with a select dropdown
```elixir
iex> CurrencyFormatter.get_currencies_for_select()
["AED", "AFN", "ALL", ...]
```

```elixir
iex> CurrencyFormatter.get_currencies_for_select(:names)
[{"AED", "United Arab Emirates Dirham"}, {"AFN", "Afghan Afghani"} , {"ALL", "Albanian Lek"}, ...]

```
```elixir
iex> CurrencyFormatter.get_currencies_for_select(:symbols)
[{"AED", "د.إ"}, {"AFN", "؋"}, {"ALL", "L"}, ...]

```
```elixir
iex> CurrencyFormatter.get_currencies_for_select(:disambiguate_symbols)
[[{"AED", "د.إ"}, {"AFN", "؋"}, {"ALL", "Lek"}, ...]
```

Get the disambiguous symbol of a currrency
```elixir
iex> CurrencyFormatter.symbol(:AUD)
"A$"
```
## Installation

As this is [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add currency_formatter to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:currency_formatter, "~> 0.4"}]
end
```

## Setup
By default you will have 172 currencies available, there are two configuration options that can be set in your app's `config.exs` file to limit the number of currencies.

If you would like to limit the list to only include specific currencies, you can configure a whitelist by passing a list of ISO codes to include:

```elixir
config :currency_formatter, :whitelist, ["EUR", "GBP", "USD"]
```

To exclude certain currencies from the list, you can configure a blacklist using a list of ISO codes to exclude:

```elixir
config :currency_formatter, :blacklist, ["XDR", "XAG", "XAU"]
```

## Documentation

API documentation is available at [https://hexdocs.pm/currency_formatter](https://hexdocs.pm/currency_formatter) and [http://smeevil.github.io/currency_formatter](http://smeevil.github.io/currency_formatter)


