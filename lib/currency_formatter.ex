defmodule CurrencyFormatter do
  @moduledoc """
  This module takes care of formatting a number to a currency.
  You can also request a map containing all the formatting settings for a currency.
  """

  @currencies "./lib/currency_iso.json"
              |> File.read!()
              |> Poison.decode!()

  @doc """
  Formats a number to currency

  ## examples

      iex> CurrencyFormatter.format(123456, :usd)
      "$1,234.56"

      iex> CurrencyFormatter.format(654321, :eur)
      "€6.543,21"

      iex> CurrencyFormatter.format(654321, "AUD")
      "$6,543.21"

      iex> CurrencyFormatter.format(123456, "AUD", disambiguate: true)
      "A$1,234.56"

  """
  @spec format(String.t() | number | atom, String.t()) :: String.t()
  def format(number, currency, opts \\ [])

  def format(number, currency, opts) when is_atom(currency) do
    format(number, Atom.to_string(currency), opts)
  end

  def format(number, currency, opts) when is_integer(number) do
    number
    |> to_string
    |> format(currency, opts)
  end

  def format(number_string, currency, opts)
      when is_binary(number_string) and is_binary(currency) do
    format = instructions(currency)

    decimal =
      format["subunit_to_unit"]
      |> Integer.digits()
      |> Kernel.length()

    number_string
    |> remove_non_numbers
    |> add_subunit_separator(decimal - 1)
    |> add_padding(decimal - 1)
    |> split_units_and_subunits
    |> handle_cents(format, opts)
    |> set_symbol(format, opts)
  end

  @doc """
  Formats a number to currency wrapped in span tags with classes in a Phoenix.HTML safe way
  You can directly use this in your phoenix templates.

  ## example

      iex> CurrencyFormatter.html_format(123456, "EUR")
      [
        safe: [
          60,
          "span",
          [[32, "class", 61, 34, "currency-formatter-symbol", 34]],
          62,
          "€",
          60,
          47,
          "span",
          62
        ],
        safe: [
          60,
          "span",
          [[32, "class", 61, 34, "currency-formatter-amount", 34]],
          62,
          "1.234,56",
          60,
          47,
          "span",
          62
        ]
      ]
  """
  def html_format(number, currency, opts \\ Keyword.new()) do
    opts = Keyword.put_new(opts, :html, true)
    format(number, currency, opts)
  end

  @doc """
  Formats a number to currency wrapped in span tags with classes.
  This will return html as a string without any escaping. When using phoenix, consider using the `format_html/1` function

  ## example

      iex> CurrencyFormatter.raw_html_format(123456, "EUR")
      ~s[<span class="currency-formatter-symbol">€</span><span class="currency-formatter-amount">1.234,56</span>]

      iex> CurrencyFormatter.raw_html_format(123400, "EUR", keep_decimals: true)
      ~s[<span class="currency-formatter-symbol">€</span><span class="currency-formatter-amount">1.234,00</span>]
  """
  def raw_html_format(number, currency, opts \\ Keyword.new()) do
    number
    |> html_format(currency, opts)
    |> Enum.map(&Phoenix.HTML.safe_to_string/1)
    |> Enum.join("")
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
  @spec instructions(atom) :: map
  def instructions(currency \\ :USD)

  def instructions(currency) when is_atom(currency) do
    currency
    |> Atom.to_string()
    |> instructions
  end

  @spec instructions(String.t()) :: map
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
  @spec get_currencies() :: map
  def get_currencies do
    @currencies
    |> whitelist(Application.get_env(:currency_formatter, :whitelist))
    |> blacklist(Application.get_env(:currency_formatter, :blacklist))
  end

  @spec whitelist(map, nil | list) :: map

  defp whitelist(currencies, nil), do: currencies

  defp whitelist(currencies, whitelist) do
    Map.take(currencies, downcase(whitelist))
  end

  @spec blacklist(map, nil | list) :: map
  defp blacklist(currencies, nil), do: currencies

  defp blacklist(currencies, blacklist) do
    Map.drop(currencies, downcase(blacklist))
  end

  @spec downcase(list) :: list
  defp downcase(list) when is_list(list) do
    Enum.map(list, fn val -> String.downcase(val) end)
  end

  @doc """
  Returns a List with tuples that can be used as options for select

  ## Examples
      CurrencyFormatter.get_currencies_for_select()
      ["AED", "AFN", "ALL",...]

  """
  @spec get_currencies_for_select() :: [{String.t(), String.t()}]
  def get_currencies_for_select do
    get_currencies()
    |> Enum.map(fn {_, c} -> c["iso_code"] end)
    |> Enum.sort()
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
  @spec get_currencies_for_select(atom) :: [{String.t(), String.t()}]
  def get_currencies_for_select(:names) do
    get_currencies()
    |> map_names
    |> Enum.sort()
  end

  def get_currencies_for_select(:symbols) do
    get_currencies()
    |> map_symbols
    |> Enum.sort()
  end

  def get_currencies_for_select(:disambiguate_symbols) do
    get_currencies()
    |> map_disambiguate_symbols
    |> Enum.sort()
  end

  def get_currencies_for_select(format) do
    raise(
      "#{inspect(format)} is not supported, please use either :names, :symbols or :disambiguate_symbols"
    )
  end

  @doc """
  Returns the symbol of a currency

  ## Example

      iex> CurrencyFormatter.symbol(:AUD)
      "$"

  """
  @spec symbol(atom) :: String.t()
  def symbol(currency) do
    currency
    |> CurrencyFormatter.instructions()
    |> get_symbol
  end

  @doc """
  Returns the disambiguous symbol of a currency

  ## Example

      iex> CurrencyFormatter.disambiguous_symbol(:AUD)
      "A$"

  """
  @spec symbol(atom) :: String.t()
  def disambiguous_symbol(currency) do
    currency
    |> CurrencyFormatter.instructions()
    |> get_disambiguous_symbol
  end

  @spec map_names(map) :: [map]
  defp map_names(map), do: Enum.map(map, fn {_, c} -> {c["iso_code"], c["name"]} end)

  @spec map_symbols(map) :: [map]
  defp map_symbols(map), do: Enum.map(map, fn {_, c} -> {c["iso_code"], c["symbol"]} end)

  @spec map_disambiguate_symbols(map) :: [map]
  defp map_disambiguate_symbols(map),
    do: Enum.map(map, fn {_, c} -> {c["iso_code"], c["disambiguate_symbol"] || c["symbol"]} end)

  @spec remove_non_numbers(String.t()) :: String.t()
  defp remove_non_numbers(string), do: String.replace(string, ~r/[^0-9-]/, "")

  @spec add_subunit_separator(String.t(), number) :: String.t()
  defp add_subunit_separator(amount, decimal) do
    String.replace(amount, ~r/^0*([0-9-]+)(\d{#{decimal}})$/, "\\1,\\2")
  end

  @spec add_padding(String.t(), number) :: String.t()
  defp add_padding("", _decimal), do: "0,00"

  defp add_padding("-" <> centified, decimal) when byte_size(centified) == 1 do
    case decimal do
      0 -> "-" <> centified
      2 -> "-0,0" <> centified
      3 -> "-0,00" <> centified
      4 -> "-0,000" <> centified
    end
  end

  defp add_padding(centified, decimal) when byte_size(centified) == 1 do
    case decimal do
      0 -> centified
      2 -> "0,0" <> centified
      3 -> "0,00" <> centified
      4 -> "0,000" <> centified
    end
  end

  defp add_padding("-," <> centified, decimal) when byte_size(centified) == 2 do
    case decimal do
      0 -> "-" <> centified
      2 -> "-0," <> centified
      3 -> "-0,0" <> centified
      4 -> "-0,00" <> centified
    end
  end

  defp add_padding(centified, decimal) when byte_size(centified) == 2 do
    case decimal do
      0 -> centified
      2 -> "0," <> centified
      3 -> "0,0" <> centified
      4 -> "0,00" <> centified
    end
  end

  defp add_padding("-" <> centified, decimal) when byte_size(centified) == 3 do
    case decimal do
      3 -> "-0," <> centified
      4 -> "-0,0" <> centified
      _ -> "-" <> centified
    end
  end

  defp add_padding(centified, decimal) when byte_size(centified) == 3 do
    case decimal do
      3 -> "0," <> centified
      4 -> "0,0" <> centified
      _ -> centified
    end
  end

  defp add_padding("-" <> centified, decimal) when byte_size(centified) == 4 do
    case decimal do
      4 -> "-0,0" <> centified
      _ -> "-" <> centified
    end
  end

  defp add_padding(centified, decimal) when byte_size(centified) == 4 do
    case decimal do
      4 -> "0," <> centified
      _ -> centified
    end
  end

  defp add_padding(centified, _decimal), do: centified

  @spec split_units_and_subunits(binary) :: [binary]
  defp split_units_and_subunits(string), do: String.split(string, ",", parts: 2)

  @spec handle_cents(list, map, map) :: String.t()
  defp handle_cents([x, "00" = y], format, opts) do
    if Keyword.get(opts, :keep_decimals) do
      set_separators(x, format) <> format["decimal_mark"] <> y
    else
      set_separators(x, format)
    end
  end

  defp handle_cents([x, y], format, _opts),
    do: set_separators(x, format) <> format["decimal_mark"] <> y

  @spec set_separators(String.t(), map) :: String.t()
  defp set_separators(string, format) do
    string
    |> String.to_charlist()
    |> Enum.reverse()
    |> set_separators(format["thousands_separator"], "")
  end

  defp set_separators([a, b, c, ?- | tail], separator, acc) do
    set_separators([?- | tail], separator, [c, b, a | acc])
  end

  defp set_separators([a, b, c, d | tail], separator, acc) do
    set_separators([d | tail], separator, [separator, c, b, a | acc])
  end

  defp set_separators(list, _, acc) do
    list
    |> Enum.reverse()
    |> Kernel.++(acc)
    |> Kernel.to_string()
  end

  @spec set_symbol(String.t(), map, Keyword.t()) :: String.t()
  defp set_symbol(number_string, %{"symbol_first" => true} = config, opts) do
    symbol = get_symbol(config, opts)

    if Keyword.get(opts, :html) do
      wrap_in_spans(symbol: symbol, amount: number_string)
    else
      symbol <> number_string
    end
  end

  defp set_symbol(number_string, config, opts) do
    if Keyword.get(opts, :html) do
      spans = wrap_in_spans(amount: number_string, symbol: get_symbol(config, opts))
      Phoenix.HTML.safe_to_string(spans)
    else
      number_string <> get_symbol(config, opts)
    end
  end

  defp wrap_in_spans(symbol: symbol, amount: amount) do
    [wrap("currency-formatter-symbol", symbol), wrap("currency-formatter-amount", amount)]
  end

  defp wrap_in_spans(amount: amount, symbol: symbol) do
    [wrap("currency-formatter-amount", amount), wrap("currency-formatter-symbol", symbol)]
  end

  defp wrap(class, text) do
    Phoenix.HTML.Tag.content_tag(:span, text, class: class)
  end

  @spec get_symbol(map, keyword | nil) :: String.t()
  defp get_symbol(config, opts \\ Keyword.new()) do
    if Keyword.get(opts, :disambiguate),
      do: get_disambiguous_symbol(config),
      else: config["symbol"]
  end

  @spec get_disambiguous_symbol(map) :: String.t()
  defp get_disambiguous_symbol(%{"disambiguate_symbol" => symbol}), do: symbol
  defp get_disambiguous_symbol(config), do: config["symbol"]
end
