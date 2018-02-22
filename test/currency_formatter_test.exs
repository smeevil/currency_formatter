defmodule CurrencyFormatterTest do
  use ExUnit.Case, async: false

  doctest CurrencyFormatter

  setup do
    previous = Application.get_env(:currency_formatter, :whitelist)
    previous_blacklist = Application.get_env(:currency_formatter, :blacklist)

    on_exit(fn ->
      Application.put_env(:currency_formatter, :whitelist, previous)
      Application.put_env(:currency_formatter, :blacklist, previous_blacklist)
    end)

    :ok
  end

  test "should correctly format in euro and dollars" do
    assert "€0,01" == CurrencyFormatter.format(1, :eur)
    assert "$0.01" == CurrencyFormatter.format(1, "USD")
    assert "0,01Ft" == CurrencyFormatter.format(1, "huf")
    assert "$0.01" == CurrencyFormatter.format(1, :AUD)
  end

  test "should format an amount_in_cents as integer to a price in dollars" do
    assert "$0.01" == CurrencyFormatter.format(1, :usd)
    assert "$0.12" == CurrencyFormatter.format(12, :usd)
    assert "$1.23" == CurrencyFormatter.format(123, :usd)
    assert "$12.34" == CurrencyFormatter.format(1234, :usd)
    assert "$123.45" == CurrencyFormatter.format(12345, :usd)
    assert "$1,234.56" == CurrencyFormatter.format(123_456, :usd)
    assert "$1,000" == CurrencyFormatter.format(100_000, :usd)
    assert "$-1,000" == CurrencyFormatter.format(-100_000, :usd)
    assert "$12,345.67" == CurrencyFormatter.format(1_234_567, :usd)
    assert "$-12,345.67" == CurrencyFormatter.format(-1_234_567, :usd)
    assert "$123,456.78" == CurrencyFormatter.format(12_345_678, :usd)
    assert "$1,234,567.89" == CurrencyFormatter.format(123_456_789, :usd)
    assert "$12,345,678.90" == CurrencyFormatter.format(1_234_567_890, :usd)
    assert "$-113,728" == CurrencyFormatter.format(-11_372_800, :usd)
    assert "$-499" == CurrencyFormatter.format(-49900, :usd)
    assert "$1" == CurrencyFormatter.format(100, :usd)
    assert "$1.00" == CurrencyFormatter.format(100, :usd, keep_decimals: true)
  end

  test "should format an amount_in_cents as integer to a price in euros" do
    assert "€0,01" == CurrencyFormatter.format(1, :eur)
    assert "€0,12" == CurrencyFormatter.format(12, :eur)
    assert "€1,23" == CurrencyFormatter.format(123, :eur)
    assert "€12,34" == CurrencyFormatter.format(1234, :eur)
    assert "€123,45" == CurrencyFormatter.format(12345, :eur)
    assert "€1.234,56" == CurrencyFormatter.format(123_456, :eur)
    assert "€1.000" == CurrencyFormatter.format(100_000, :eur)
    assert "€-1.000" == CurrencyFormatter.format(-100_000, :eur)
    assert "€12.345,67" == CurrencyFormatter.format(1_234_567, :eur)
    assert "€-12.345,67" == CurrencyFormatter.format(-1_234_567, :eur)
    assert "€123.456,78" == CurrencyFormatter.format(12_345_678, :eur)
    assert "€1.234.567,89" == CurrencyFormatter.format(123_456_789, :eur)
    assert "€12.345.678,90" == CurrencyFormatter.format(1_234_567_890, :eur)
    assert "€-113.728" == CurrencyFormatter.format(-11_372_800, :eur)
    assert "€-499" == CurrencyFormatter.format(-49900, :eur)
    assert "€1" == CurrencyFormatter.format(100, :eur)
    assert "€1,00" == CurrencyFormatter.format(100, :eur, keep_decimals: true)
  end

  test "should return html" do
    assert ~s[<span class="currency-formatter-symbol">€</span><span class="currency-formatter-amount">1.234</span>] ==
             CurrencyFormatter.raw_html_format(123_400, :eur)
    assert ~s[<span class="currency-formatter-symbol">€</span><span class="currency-formatter-amount">1.234,00</span>] ==
             CurrencyFormatter.raw_html_format(123_400, :eur, keep_decimals: true)
  end

  test "should format an amount_in_cents as string to a price" do
    assert "$0.01" == CurrencyFormatter.format("1", :usd)
    assert "$0.12" == CurrencyFormatter.format("12", :usd)
    assert "$1.23" == CurrencyFormatter.format("12.3", :usd)
    assert "$12.34" == CurrencyFormatter.format("12.34", :usd)
    assert "$123.45" == CurrencyFormatter.format("123,45", :usd)
    assert "$1,234.56" == CurrencyFormatter.format("1234,56", :usd)
    assert "$12,345.67" == CurrencyFormatter.format("12345.67", :usd)
    assert "$123,456.78" == CurrencyFormatter.format("123456,78", :usd)
    assert "$1,234,567.89" == CurrencyFormatter.format("1234567.89", :usd)
    assert "$12,345,678.90" == CurrencyFormatter.format("12345678,90", :usd)
    assert "$1" == CurrencyFormatter.format("1.00", :usd)
  end

  test "should use a currency symbol when given" do
    assert "$1,234,567.89" == CurrencyFormatter.format(123_456_789, :USD)
  end

  test "should allow the ability to disambiguate the currency symbol" do
    assert "US$12.34" == CurrencyFormatter.format(1234, :usd, disambiguate: true)
    assert "C$12.34" == CurrencyFormatter.format(1234, :cad, disambiguate: true)
    assert "C$12" == CurrencyFormatter.format(1200, :cad, disambiguate: true)
    assert "C$12.00" == CurrencyFormatter.format(1200, :cad, disambiguate: true, keep_decimals: true)

    assert "$12.34" == CurrencyFormatter.format(1234, :usd, disambiguate: false)
    assert "$12" == CurrencyFormatter.format(1200, :cad, disambiguate: false)
    assert "$12.00" == CurrencyFormatter.format(1200, :cad, disambiguate: false, keep_decimals: true)
  end

  test "should return a map with formatting instructions" do
    assert %{
             "alternate_symbols" => [],
             "decimal_mark" => ",",
             "html_entity" => "&#x20AC;",
             "iso_code" => "EUR",
             "iso_numeric" => "978",
             "name" => "Euro",
             "priority" => 2,
             "smallest_denomination" => 1,
             "subunit" => "Cent",
             "subunit_to_unit" => 100,
             "symbol" => "€",
             "symbol_first" => true,
             "thousands_separator" => "."
           } == CurrencyFormatter.instructions(:eur)

    assert %{
             "alternate_symbols" => [],
             "decimal_mark" => ",",
             "html_entity" => "&#x20AC;",
             "iso_code" => "EUR",
             "iso_numeric" => "978",
             "name" => "Euro",
             "priority" => 2,
             "smallest_denomination" => 1,
             "subunit" => "Cent",
             "subunit_to_unit" => 100,
             "symbol" => "€",
             "symbol_first" => true,
             "thousands_separator" => "."
           } == CurrencyFormatter.instructions("EUR")
  end

  test "should return formatting instructions for USD by default" do
    assert %{
             "smallest_denomination" => 1,
             "subunit" => "Cent",
             "subunit_to_unit" => 100,
             "symbol_first" => true,
             "alternate_symbols" => ["US$"],
             "decimal_mark" => ".",
             "html_entity" => "$",
             "iso_code" => "USD",
             "iso_numeric" => "840",
             "name" => "United States Dollar",
             "priority" => 1,
             "symbol" => "$",
             "thousands_separator" => ",",
             "disambiguate_symbol" => "US$"
           } == CurrencyFormatter.instructions()
  end

  test "should return the complete currencies list" do
    assert %{"usd" => %{}, "eur" => %{}} = CurrencyFormatter.get_currencies()
  end

  test "should return a list usable for select dropdowns" do
    assert ["AED", "AFN", "ALL"] = CurrencyFormatter.get_currencies_for_select() |> Enum.take(3)
  end

  test "should return a list usable for select dropdowns using names" do
    assert [
             {"AED", "United Arab Emirates Dirham"},
             {"AFN", "Afghan Afghani"},
             {"ALL", "Albanian Lek"}
           ] = CurrencyFormatter.get_currencies_for_select(:names) |> Enum.take(3)
  end

  test "symbol" do
    assert "$" == CurrencyFormatter.symbol(:AUD)
  end

  test "disambiguous_symbol" do
    assert "A$" == CurrencyFormatter.disambiguous_symbol(:AUD)
  end

  test "disambiguous_symbol default to symbol if the currency doesn't have a disambiguate_symbol" do
    assert "դր." == CurrencyFormatter.disambiguous_symbol(:amd)
  end

  test "should return a list usable for select dropdowns using currency symbols" do
    assert {"AUD", "$"} ==
             CurrencyFormatter.get_currencies_for_select(:symbols)
             |> Enum.find(fn {iso, _} -> iso == "AUD" end)
  end

  test "should return a list usable for select dropdowns using disambiguate currency symbols" do
    assert {"AUD", "A$"} ==
             CurrencyFormatter.get_currencies_for_select(:disambiguate_symbols)
             |> Enum.find(fn {iso, _} -> iso == "AUD" end)
  end

  test "should raise an error" do
    assert_raise RuntimeError,
                 ":other is not supported, please use either :names, :symbols or :disambiguate_symbols",
                 fn -> CurrencyFormatter.get_currencies_for_select(:other) end
  end

  test "get_currencies_for_select should only return whitelisted currencies" do
    Application.put_env(:currency_formatter, :whitelist, ["EUR", "USD", "CAD"])

    [{"CAD", "C$"}, {"EUR", "€"}, {"USD", "US$"}] =
      CurrencyFormatter.get_currencies_for_select(:disambiguate_symbols)
  end

  test "get_currencies should return all currencies except blacklisted currencies" do
    blacklist = ["XDR", "XAG", "XAU"]
    Application.put_env(:currency_formatter, :blacklist, blacklist)

    currencies = CurrencyFormatter.get_currencies()

    [] =
      currencies
      |> Enum.filter(fn {_, %{"iso_code" => iso_code}} -> Enum.member?(blacklist, iso_code) end)

    blacklist
    |> Enum.each(fn code ->
      assert Map.get(currencies, String.downcase(code)) == nil
    end)
  end
end
