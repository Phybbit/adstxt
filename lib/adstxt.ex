defmodule Adstxt do
  @moduledoc """
  Documentation for Adstxt.
  """

  @typedoc """
  The adstxt format v1.0.1 as specified in:
  https://iabtechlab.com/wp-content/uploads/2017/09/IABOpenRTB_Ads.txt_Public_Spec_V1-0-1.pdf

  The `errors` field is an additional field to help debug incorrect content.
  """
  @type adstxt :: %{
          :data => [
            %{
              :domain => String.t(),
              :publisher_id => String.t(),
              :account_type => String.t(),
              optional(:certification_auth_id) => String.t()
            }
          ],
          :contacts => [String.t()],
          :subdomain_referrals => [String.t()],
          :errors => [String.t()]
        }

  @doc """
  Hello world.

  ## Examples

      # 4.1 SINGLE SYSTEM DIRECT
      iex> Adstxt.parse!("greenadexchange.com, XF7342, DIRECT, 5jyxf8k54")
      %{data: [
        %{
          domain: "greenadexchange.com",
          publisher_id: "XF7342",
          account_type: "DIRECT",
          cert_auth_id: "5jyxf8k54"
        }],
        contacts: [],
        subdomain_referrals: [],
        errors: [],
      }

      # 4.2 SINGLE SYSTEM RESELLER
      iex> Adstxt.parse!("redssp.com, 57013, RESELLER")
      %{data: [
        %{
          domain: "redssp.com",
          publisher_id: "57013",
          account_type: "RESELLER"
        }],
        contacts: [],
        subdomain_referrals: [],
        errors: [],
      }
  """
  @spec parse!(content :: String.t()) :: adstxt
  def parse!(content) when is_bitstring(content) do
    base = %{data: [], contacts: [], subdomain_referrals: [], errors: []}

    content
    |> String.split("\n")
    |> Enum.map(&parse_line(String.trim(&1)))
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce(base, fn {key, value}, acc ->
      Map.put(acc, key, acc[key] ++ [value])
    end)
  end

  def parse!(_) do
    raise "Invalid content type, please pass a string."
  end

  defp parse_line("#" <> _comment), do: nil

  defp parse_line(""), do: nil

  defp parse_line(line) do
    if line =~ "=" do
      parse_variable_record(line)
    else
      parse_data_record(line)
    end
  end

  defp parse_variable_record("contact=" <> contact) do
    {:contacts, contact}
  end

  defp parse_variable_record("subdomain=" <> subdomain) do
    {:subdomain_referrals, subdomain}
  end

  defp parse_variable_record(invalid) do
    {:errors, "Invalid variable record: '#{invalid}'"}
  end

  defp parse_data_record(line) do
    case String.split(line, ",") do
      [domain, pub_id, type, auth_id] ->
        {:data,
         %{
           domain: clean_value(domain),
           publisher_id: clean_value(pub_id),
           account_type: clean_value(type),
           cert_auth_id: clean_value(auth_id)
         }}

      [domain, pub_id, type] ->
        {:data,
         %{
           domain: clean_value(domain),
           publisher_id: clean_value(pub_id),
           account_type: clean_value(type)
         }}

      _ ->
        {:errors, "Data record should have 3 or 4 fields. Got: '#{line}'"}
    end
  end

  defp clean_value(value) do
    String.trim(value)
    |> URI.decode()
  end
end
