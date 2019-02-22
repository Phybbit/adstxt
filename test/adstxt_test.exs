defmodule AdstxtTest do
  use ExUnit.Case
  doctest Adstxt

  test "4.3 MULTIPLE SYSTEMS AND RESELLERS" do
    result =
      """
      greenadexchange.com, 12345, DIRECT, d75815a79
      silverssp.com, 9675, RESELLER, f496211
      blueadexchange.com, XF436, DIRECT
      orangeexchange.com, 45678, RESELLER
      silverssp.com, ABE679, RESELLER
      """
      |> Adstxt.parse!()

    expected = %{
      data: [
        %{
          domain: "greenadexchange.com",
          publisher_id: "12345",
          account_type: "DIRECT",
          cert_auth_id: "d75815a79"
        },
        %{
          domain: "silverssp.com",
          publisher_id: "9675",
          account_type: "RESELLER",
          cert_auth_id: "f496211"
        },
        %{
          domain: "blueadexchange.com",
          publisher_id: "XF436",
          account_type: "DIRECT"
        },
        %{
          domain: "orangeexchange.com",
          publisher_id: "45678",
          account_type: "RESELLER"
        },
        %{
          domain: "silverssp.com",
          publisher_id: "ABE679",
          account_type: "RESELLER"
        }
      ],
      contacts: [],
      subdomain_referrals: [],
      errors: []
    }

    assert result == expected
  end

  test "4.4 CONTACT RECORDS" do
    result =
      """
      # Ads.txt file for example.com:
      greenadexchange.com, 12345, DIRECT, d75815a79
      blueadexchange.com, XF436, DIRECT
      contact=adops@example.com
      contact=http://example.com/contact-us
      """
      |> Adstxt.parse!()

    expected = %{
      data: [
        %{
          domain: "greenadexchange.com",
          publisher_id: "12345",
          account_type: "DIRECT",
          cert_auth_id: "d75815a79"
        },
        %{
          domain: "blueadexchange.com",
          publisher_id: "XF436",
          account_type: "DIRECT"
        }
      ],
      contacts: ["adops@example.com", "http://example.com/contact-us"],
      subdomain_referrals: [],
      errors: []
    }
  end

  test "4.5 SUBDOMAIN REFERRAL" do
    result =
      """
      # Ads.txt file for example.com:
      greenadexchange.com, 12345, DIRECT, d75815a79
      blueadexchange.com, XF436, DIRECT
      subdomain=divisionone.example.com
      """
      |> Adstxt.parse!()

    expected = %{
      data: [
        %{
          domain: "greenadexchange.com",
          publisher_id: "12345",
          account_type: "DIRECT",
          cert_auth_id: "d75815a79"
        },
        %{
          domain: "blueadexchange.com",
          publisher_id: "XF436",
          account_type: "DIRECT"
        }
      ],
      contacts: [],
      subdomain_referrals: ["divisionone.example.com"],
      errors: []
    }
  end
end
