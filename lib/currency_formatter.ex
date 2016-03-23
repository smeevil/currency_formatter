defmodule CurrencyFormatter do
  @moduledoc """
  This module takes care of formatting a number to a currency
  """

  @currencies "./lib/currency_iso.json" |> File.read! |> Poison.decode!

  @doc """
  Formats a number to currency

  ## examples

    iex> CurrencyFormatter.format(123456)
    "$1,234.56"

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
    format = Map.get(@currencies, String.downcase(currency))

    number_string
    |> remove_non_numbers
    |> add_subunit_separator
    |> add_padding
    |> split_units_and_subunits
    |> handle_cents(format)
    |> set_symbol(format)
  end

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
