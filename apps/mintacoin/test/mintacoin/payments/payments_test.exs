defmodule Mintacoin.Payments.PaymentsTest do
  @moduledoc """
    This module is used to group common tests for Payments functions
  """

  use Mintacoin.DataCase

  alias Mintacoin.{Repo, Account, Asset, Payment, Payments}
  alias Ecto.{Adapters.SQL.Sandbox, UUID}

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
        amount: "10.0"
      },
      non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146",
      invalid_id: "invalid_id",
      non_existing_asset_code: "MTK:123",
      invalid_amount: "10.0.0"
    }
  end

  describe "create/1" do
    test "with valid params", %{
      payment:
        %{source: source, destination: destination, asset_code: asset_code, amount: amount} =
          payment_data
    } do
      {:ok,
       %Payment{
         source: ^source,
         destination: ^destination,
         asset_code: ^asset_code,
         amount: ^amount,
         status: :emitted
       }} = Payments.create(payment_data)
    end

    test "with empty params" do
      {:error, changeset} = Payments.create(%{})

      %{
        amount: ["can't be blank"],
        asset_code: ["can't be blank"],
        destination: ["can't be blank"],
        source: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "with non existing source", %{payment: payment_data, non_existing_id: non_existing_id} do
      {:error, changeset} = Payments.create(%{payment_data | source: non_existing_id})
      %{source: ["does not exist"]} = errors_on(changeset)
    end

    test "with non existing destination", %{
      payment: payment_data,
      non_existing_id: non_existing_id
    } do
      {:error, changeset} = Payments.create(%{payment_data | destination: non_existing_id})
      %{destination: ["does not exist"]} = errors_on(changeset)
    end

    test "with non existing asset_code", %{
      payment: payment_data,
      non_existing_asset_code: non_existing_asset_code
    } do
      {:error, changeset} = Payments.create(%{payment_data | asset_code: non_existing_asset_code})
      %{asset_code: ["does not exist"]} = errors_on(changeset)
    end

    test "with invalid amount", %{
      payment: payment_data,
      invalid_amount: invalid_amount
    } do
      {:error, changeset} = Payments.create(%{payment_data | amount: invalid_amount})
      %{amount: ["must have a decimal number format"]} = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    setup do
      %{payment: insert(:payment)}
    end

    test "with existing id", %{
      payment: %Payment{id: id} = payment
    } do
      {:ok, ^payment} = Payments.retrieve(id)
    end

    test "with non existing id", %{non_existing_id: id} do
      {:error, :not_found} = Payments.retrieve(id)
    end

    test "with invalid id", %{invalid_id: id} do
      {:error, :not_found} = Payments.retrieve(id)
    end
  end

  describe "update/1" do
    setup do
      %{
        payment: insert(:payment),
        valid_attrs: %{status: :processed},
        invalid_attrs: %{status: :invalid}
      }
    end

    test "with existing id", %{
      payment: %Payment{id: id},
      valid_attrs: %{status: status} = attrs
    } do
      {:ok, %Payment{id: ^id, status: ^status}} = Payments.update(id, attrs)
    end

    test "with non existing status", %{
      payment: %Payment{id: id},
      invalid_attrs: invalid_attrs
    } do
      {:error, changeset} = Payments.update(id, invalid_attrs)
      %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "with non existing id", %{non_existing_id: id, valid_attrs: attrs} do
      {:error, :not_found} = Payments.update(id, attrs)
    end

    test "with invalid id", %{invalid_id: id, valid_attrs: attrs} do
      {:error, :not_found} = Payments.update(id, attrs)
    end

    test "changes only status", %{
      payment: %Payment{id: id},
      valid_attrs: %{status: status} = attrs
    } do
      source = UUID.generate()
      destination = UUID.generate()
      amount = "1"

      {:ok,
       %Payment{
         source: actual_source,
         destination: actual_destination,
         amount: actual_amount,
         status: actual_status
       }} =
        attrs
        |> Map.put(:source, source)
        |> Map.put(:destination, destination)
        |> Map.put(:amount, amount)
        |> (&Payments.update(id, &1)).()

      refute source == actual_source
      refute destination == actual_destination
      refute amount == actual_amount
      assert status == actual_status
    end
  end
end
