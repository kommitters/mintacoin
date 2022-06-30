defmodule Mintacoin.Crypto.Stellar do
  @moduledoc """

  """

  @behaviour Mintacoin.Crypto.Spec

  alias Mintacoin.Crypto.Stellar.{Accounts, Assets, Payments}

  @impl true
  defdelegate create_account(params), to: Accounts, as: :create

  @impl true
  defdelegate create_asset(params), to: Assets, as: :create

  @impl true
  defdelegate authorize_asset(params), to: Assets, as: :authorize

  @impl true
  defdelegate process_payment(params), to: Payments, as: :create
end
