## 0.4.8 (2017-05-29)
Thanks to @jknipp for adding blacklist support.
You can configure this in the settings just like you configure the whitelist

```elixir
config :currency_formatter, :blacklist, ["XDR", "XAG", "XAU"]
```

## 0.4.7 (2017-05-25)
Thanks to @jknipp for syncing up with the latest version of the currency_iso.json

## 0.4.6 (2017-04-04)
  - bumped deps
## 0.4.5 (2017-01-09)
Thanks to @marceldegraaf for removing deprecation warnings for elixir 1.4

## 0.4.4 (2016-12-07)
Added a configuration option so you can whitelist supported currencies. To make use of this you can update you app's config.exs with

```elixir
config :currency_formatter, :whitelist, ["EUR", "GBP", "USD"]
```

Thank you @vraravam for the suggestion :)

## 0.4.3 (2016-10-31)
  - Updated data source, returning usd by default. Thank you @optikfluffel !
  - bumped deps

## 0.4.2 (2016-08-11)
  - bumped deps

## 0.4.1 (2016-08-01)
  - Added a new function CurrencyFormatter.symbol/1 which will return the disambiguous currency symbol

## 0.4.0 (2016-06-25)
  - Added a new function (CurrencyFormatter.get_currencies_for_select) which returns a list with all currencies to be used in a select dropdown.

## 0.3.0 (2016-06-25)
  - Added a new function (CurrencyFormatter.get_currencies) which returns a map with all currencies and their formatting rules. Thank you @minibikini !
  - bumped all dependencies

## 0.2.0 (2016-06-18)
Added a new function (CurrencyFormatter.instructions(:EUR)) which returns formatting settings for a currency. You can use this information to create for example an input field to use with the Autonumeric js library.

## 0.0.1 (2016-03-23)
  - Initial commit
