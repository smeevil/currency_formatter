defmodule CurrencyFormatter do
  @moduledoc """
  This module takes care of formatting a number to a currency.
  You can also request a map containing all the formatting settings for a currency.
  """

  @currencies "./lib/currency_iso.json" |> File.read! |> Poison.decode!

  @doc """
  Formats a number to currency

  ## examples

      iex> CurrencyFormatter.format(123456)
      "US$1,234.56"

      iex> CurrencyFormatter.format(654321, :eur)
      "€6.543,21"

      iex> CurrencyFormatter.format(654321, "AUD")
      "A$6,543.21"

  """
  @spec format(Integer.t, Atom.t) :: String.t
  def format(number, currency \\ :USD)
  def format(number, currency) when is_atom(currency) do
    format(number, Atom.to_string(currency))
  end
  def format(number, currency) when is_integer(number) do
    number |> to_string |> format(currency)
  end
  def format(number_string, currency) when is_binary(number_string) and is_binary(currency) do
    format = instructions(currency)

    number_string
    |> remove_non_numbers
    |> add_subunit_separator
    |> add_padding
    |> split_units_and_subunits
    |> handle_cents(format)
    |> set_symbol(format)
  end

 @doc """
  Returns a map with formatting settings for a currency

  ## examples

      iex> CurrencyFormatter.instructions(:EUR)
      %{"alternate_symbols" => [], "decimal_mark" => ",", "html_entity" => "&#x20AC;",
      "iso_code" => "EUR", "iso_numeric" => "978", "name" => "Euro", "priority" => 2,
      "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100,
      "symbol" => "€", "symbol_first" => true, "thousands_separator" => "."}

  """
  @spec instructions(Atom.t) :: Map.t
  def instructions(currency \\ :USD)
  def instructions(currency) when is_atom(currency) do
   currency
   |> Atom.to_string
   |> instructions
  end

  @spec instructions(String.t) :: Map.t
  def instructions(currency) when is_binary(currency) do
    Map.get(@currencies, String.downcase(currency))
  end

  @doc """
  Returns a map containing the full list of currencies

  ## examples

      iex> currencies = CurrencyFormatter.get_currencies()
      iex> Enum.count(currencies)
      172
      iex> currencies["usd"]
      %{"alternate_symbols" => ["US$"], "decimal_mark" => ".",
      "disambiguate_symbol" => "US$", "html_entity" => "$", "iso_code" => "USD",
      "iso_numeric" => "840", "name" => "United States Dollar", "priority" => 1,
      "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100,
      "symbol" => "$", "symbol_first" => true, "thousands_separator" => ","}

  """
  @spec get_currencies() :: Map.t
  def get_currencies do
    @currencies 
    |> whitelist(Application.get_env(:currency_formatter, :whitelist))
    |> blacklist(Application.get_env(:currency_formatter, :blacklist))
  end

  defp whitelist(currencies, nil), do: currencies
  defp whitelist(currencies, whitelist) do
    Map.take(currencies, downcase(whitelist))
  end

  defp blacklist(currencies, nil), do: currencies
  defp blacklist(currencies, blacklist) do
    Map.drop(currencies, downcase(blacklist))
  end

  defp downcase(list) when is_list(list) do
    list |> Enum.map(fn(val) -> String.downcase(val) end)
  end

  @doc """
  Returns a List with tuples that can be used as options for select

  ## Examples
      CurrencyFormatter.get_currencies_for_select()
      ["AED", "AFN", "ALL",...]

  """
  @spec get_currencies_for_select() :: [{String.t, String.t}]
  def get_currencies_for_select do
    get_currencies()
    |> Enum.map( fn({_, c}) -> c["iso_code"] end)
    |> Enum.sort
  end

  @doc """
  Returns a List with tuples that can be used as options for select

  ## Examples
      CurrencyFormatter.get_currencies_for_select(:names)
      [{"AED", "United Arab Emirates Dirham"}, {"AFN", "Afghan Afghani"} , {"ALL", "Albanian Lek"}, ...]

      CurrencyFormatter.get_currencies_for_select(:symbols)
      [{"AUD", "$"}, {"CAD", "$"}, {"USD", "$"},...]

      CurrencyFormatter.get_currencies_for_select(:disambiguate_symbols)
      [{"AUD", "A$"}, {"CAD", "C$"}, {"USD", "$"}, ...]
  """
  @spec get_currencies_for_select(Atom.t) :: [{String.t, String.t}]
  def get_currencies_for_select(:names) do
    get_currencies()
    |> map_names
    |> Enum.sort
  end
  def get_currencies_for_select(:symbols) do
    get_currencies()
    |> map_symbols
    |> Enum.sort
  end
  def get_currencies_for_select(:disambiguate_symbols) do
    get_currencies()
    |> map_disambiguate_symbols
    |> Enum.sort
  end
  def get_currencies_for_select(format), do: raise "#{inspect format} is not supported, please use either :names, :symbols or :disambiguate_symbols"

  @doc"""
  Returns the disambiguous symbol of a currency

  ## Example

      iex> CurrencyFormatter.symbol(:AUD)
      "A$"

  """
  def symbol(currency), do: currency |> CurrencyFormatter.instructions |> get_symbol

  defp map_names(map), do: Enum.map(map, fn({_, c}) -> {c["iso_code"], c["name"]} end)
  defp map_symbols(map), do: Enum.map(map, fn({_, c}) -> {c["iso_code"], c["symbol"]} end)
  defp map_disambiguate_symbols(map), do: Enum.map(map, fn({_, c}) -> {c["iso_code"], c["disambiguate_symbol"] || c["symbol"]}end)

  defp remove_non_numbers(string) do
    string |> String.replace(~r/[^0-9-]/, "")
  end

  defp add_subunit_separator(string) do
    string |> String.replace(~r/^0*([0-9-]+)(\d{2})$/, "\\1,\\2")
  end

  defp add_padding(""), do: "0,00"
  defp add_padding(centified) when byte_size(centified) == 1, do: "0,0" <> centified
  defp add_padding(centified) when byte_size(centified) == 2, do: "0," <> centified
  defp add_padding(centified), do: centified

  defp split_units_and_subunits(string) do
    string |> String.split(",", parts: 2)
  end

  defp handle_cents([x , "00"], format), do: set_separators(x, format)
  defp handle_cents([x, y], format), do: set_separators(x, format) <> format["decimal_mark"] <> y

  defp set_separators(string, format) do
    string
    |> String.to_char_list
    |> Enum.reverse
    |> set_separators(format["thousands_separator"], "")
  end
  defp set_separators([a,b,c,d|tail], separator, acc) do
    set_separators([d|tail], separator, [separator,c,b,a|acc])
  end
  defp set_separators(list, _, acc) do
    list
    |> Enum.reverse
    |> Kernel.++(acc)
    |> Kernel.to_string
  end

  defp set_symbol(number_string, %{"symbol_first" => true} = config) do
    get_symbol(config) <> number_string
  end
  defp set_symbol(number_string , config) do
    number_string <> get_symbol(config)
  end

  defp get_symbol(%{"disambiguate_symbol" => symbol}), do: symbol
  defp get_symbol(config), do: config["symbol"]

end
