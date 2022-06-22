defmodule Mintacoin.Payments.PaymentsTest do
  @moduledoc """
    This module is used to group common tests for Payments functions
  """

  use Mintacoin.DataCase

  alias Mintacoin.{Repo, Account, Payment, Payments}
  alias Ecto.Adapters.SQL.Sandbox

  import Mintacoin.Factory

  setup do
    :ok = Sandbox.checkout(Repo)

    # Create source and destination accounts
    %Account{address: source} = insert(:account)
    %Account{address: destination} = insert(:account)

    # Create asset
    %Asset{code: asset_code} = insert(:asset)

    %{
      payment: %{
        source: source,
        destination: destination,
        asset_code: asset_code,
        amount: "10.0",
      }
    }
  end

  describe "create/1" do
    test "with valid params", {payment: payment_data} do
      {:ok, %Payment{} = payment} = Payments.create(payment_data)
      IO.inspect payment
    end
  end
end
