defmodule CurrencyFormatterTest do
  use ExUnit.Case, async: false
  doctest CurrencyFormatter
  test "should correctly format in euro and dollars" do
    assert "€0,01" = CurrencyFormatter.format(1, :eur)
    assert "$0.01" = CurrencyFormatter.format(1, "USD")
    assert "0,01Ft" = CurrencyFormatter.format(1, "huf")
    assert "A$0.01" = CurrencyFormatter.format(1, :AUD)
  end

  test "should format an amount_in_cents as integer to a price in euro" do
    assert "$0.01" = CurrencyFormatter.format(1)
    assert "$0.12" = CurrencyFormatter.format(12)
    assert "$1.23" = CurrencyFormatter.format(123)
    assert "$12.34" = CurrencyFormatter.format(1234)
    assert "$123.45" = CurrencyFormatter.format(12345)
    assert "$1,234.56" = CurrencyFormatter.format(123456)
    assert "$1,000" = CurrencyFormatter.format(100000)
    assert "$-1,000" = CurrencyFormatter.format(-100000)
    assert "$12,345.67" = CurrencyFormatter.format(1234567)
    assert "$-12,345.67" = CurrencyFormatter.format(-1234567)
    assert "$123,456.78" = CurrencyFormatter.format(12345678)
    assert "$1,234,567.89" = CurrencyFormatter.format(123456789)
    assert "$12,345,678.90" = CurrencyFormatter.format(1234567890)
    assert "$1" = CurrencyFormatter.format(100)
  end

  test "should format an amount_in_cents as integer to a price in dollars" do
    assert "€0,01" = CurrencyFormatter.format(1, :eur)
    assert "€0,12" = CurrencyFormatter.format(12, :eur)
    assert "€1,23" = CurrencyFormatter.format(123, :eur)
    assert "€12,34" = CurrencyFormatter.format(1234, :eur)
    assert "€123,45" = CurrencyFormatter.format(12345, :eur)
    assert "€1.234,56" = CurrencyFormatter.format(123456, :eur)
    assert "€1.000" = CurrencyFormatter.format(100000, :eur)
    assert "€-1.000" = CurrencyFormatter.format(-100000, :eur)
    assert "€12.345,67" = CurrencyFormatter.format(1234567, :eur)
    assert "€-12.345,67" = CurrencyFormatter.format(-1234567, :eur)
    assert "€123.456,78" = CurrencyFormatter.format(12345678, :eur)
    assert "€1.234.567,89" = CurrencyFormatter.format(123456789, :eur)
    assert "€12.345.678,90" = CurrencyFormatter.format(1234567890, :eur)
    assert "€1" = CurrencyFormatter.format(100, :eur)
  end

  test "should format an amount_in_cents as string to a price" do
    assert "$0.01" = CurrencyFormatter.format("1")
    assert "$0.12" = CurrencyFormatter.format("12")
    assert "$1.23" = CurrencyFormatter.format("12.3")
    assert "$12.34" = CurrencyFormatter.format("12.34")
    assert "$123.45" = CurrencyFormatter.format("123,45")
    assert "$1,234.56" = CurrencyFormatter.format("1234,56")
    assert "$12,345.67" = CurrencyFormatter.format("12345.67")
    assert "$123,456.78" = CurrencyFormatter.format("123456,78")
    assert "$1,234,567.89" = CurrencyFormatter.format("1234567.89")
    assert "$12,345,678.90" = CurrencyFormatter.format("12345678,90")
    assert "$1" = CurrencyFormatter.format("1.00")
  end

  test "should use a currency symbol when given" do
    assert "$1,234,567.89" = CurrencyFormatter.format(123456789, :USD)
  end

  test "should return a map with formatting instructions do" do
    assert %{"alternate_symbols" => [], "decimal_mark" => ",", "html_entity" => "&#x20AC;", "iso_code" => "EUR", "iso_numeric" => "978", "name" => "Euro", "priority" => 2, "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100, "symbol" => "€", "symbol_first" => true, "thousands_separator" => "."} == CurrencyFormatter.instructions(:eur)
    assert %{"alternate_symbols" => [], "decimal_mark" => ",", "html_entity" => "&#x20AC;", "iso_code" => "EUR", "iso_numeric" => "978", "name" => "Euro", "priority" => 2, "smallest_denomination" => 1, "subunit" => "Cent", "subunit_to_unit" => 100, "symbol" => "€", "symbol_first" => true, "thousands_separator" => "."} == CurrencyFormatter.instructions("EUR")
  end

  test "should return the complete currencies list" do
     assert %{"usd" => %{}, "eur" => %{}} = CurrencyFormatter.get_currencies()
  end

  test "should return a list usable for select dropdowns" do
    assert  ["AED", "AFN", "ALL"] = CurrencyFormatter.get_currencies_for_select() |> Enum.take(3)
  end

  test "should return a list usable for select dropdowns using names" do
    assert [
      {"AED", "United Arab Emirates Dirham"},
      {"AFN", "Afghan Afghani"} ,
      {"ALL", "Albanian Lek"}
    ]= CurrencyFormatter.get_currencies_for_select(:names) |> Enum.take(3)
  end

  test "should return a list usable for select dropdowns using currency symbols" do
    assert {"AUD", "$"} = CurrencyFormatter.get_currencies_for_select(:symbols) |> Enum.find( fn({iso, _}) -> iso == "AUD" end)
  end

  test "should return a list usable for select dropdowns using disambiguate currency symbols" do
    assert {"AUD", "A$"} = CurrencyFormatter.get_currencies_for_select(:disambiguate_symbols) |> Enum.find( fn({iso, _}) -> iso == "AUD" end)
  end

  test "should raise an error" do
    assert_raise RuntimeError, ":other is not supported, please use either :names, :symbols or :disambiguate_symbols", fn -> CurrencyFormatter.get_currencies_for_select(:other) end
  end
end

