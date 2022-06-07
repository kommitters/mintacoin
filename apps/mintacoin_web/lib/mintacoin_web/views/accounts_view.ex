defmodule MintacoinWeb.AccountsView do
  use MintacoinWeb, :view

  alias Mintacoin.Account

  @type template :: String.t()
  @type assigns :: map()
  @type json_template :: map()
  @type account :: Account.t()
  @type object :: map()
  @type key :: atom()
  @type value :: any()

  @account_object %{object: "account"}
  @public_attributes ~w(address email name derived_key seed_words signature status)a

  @spec render(template :: template(), assigns :: assigns()) :: json_template()
  def render("account.json", %{account: account}), do: account_json(account)
  def render("signature.json", %{signature: signature}), do: %{signature: signature}

  @spec account_json(account) :: json_template()
  defp account_json(account) do
    account
    |> Map.from_struct()
    |> Enum.reduce(@account_object, &filter_public_attributes/2)
  end

  @spec filter_public_attributes({key :: key(), value :: value()}, object :: object()) :: object()
  defp filter_public_attributes({_key, nil}, object), do: object

  defp filter_public_attributes({key, value}, object) when key in @public_attributes,
    do: Map.put(object, key, value)

  defp filter_public_attributes(_key_value, object), do: object
end
