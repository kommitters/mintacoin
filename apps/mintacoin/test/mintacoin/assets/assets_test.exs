defmodule Mintacoin.Assets.AssetsTest do
  @moduledoc """
    This module is used to group common tests for Assets functions
  """

  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory

  alias Mintacoin.{Repo, Asset, Assets, Minter, Blockchain, Blockchains}
  alias Mintacoin.Utils.DefaultResources
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)
    # Create default blockchain
    {:ok, _blockchain} = Blockchains.create(%{name: "Stellar"})

    %Minter{id: minter_id} = insert(:minter)

    %{
      asset: %{
        code: "ASSET_CODE",
        supply: "100",
        minter_id: minter_id
      }
    }
  end

  describe "create/1" do
    setup do
      %{
        blockchain_name: "BLOCKCHAIN_NAME",
        invalid_supply: "invalid_supply",
        non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146"
      }
    end

    test "when blockchain_id is provided", %{
      asset:
        %{
          code: code,
          supply: supply,
          minter_id: minter_id
        } = asset_data,
      blockchain_name: blockchain_name
    } do
      {:ok, %Blockchain{id: blockchain_id}} = Blockchains.create(%{name: blockchain_name})

      {:ok,
       %Asset{
         code: ^code,
         supply: ^supply,
         minter_id: ^minter_id,
         blockchain_id: ^blockchain_id
       }} =
        asset_data
        |> Map.put(:blockchain_id, blockchain_id)
        |> Assets.create()
    end

    test "when blockchain_id is not provided (use default one)", %{
      asset:
        %{
          code: code,
          supply: supply,
          minter_id: minter_id
        } = asset_data
    } do
      %Blockchain{id: default_blockchain_id} = DefaultResources.blockchain()

      {:ok,
       %Asset{
         code: ^code,
         supply: ^supply,
         minter_id: ^minter_id,
         blockchain_id: ^default_blockchain_id
       }} = Assets.create(asset_data)
    end

    test "with missing params" do
      {:error, changeset} = Assets.create(%{})

      %{code: ["can't be blank"], supply: ["can't be blank"], minter_id: ["can't be blank"]} =
        errors_on(changeset)
    end

    test "with invalid supply format", %{asset: asset_data, invalid_supply: invalid_supply} do
      {:error, changeset} = Assets.create(%{asset_data | supply: invalid_supply})
      %{supply: ["must have number format"]} = errors_on(changeset)
    end

    test "with non existing minter", %{asset: asset_data, non_existing_id: non_existing_id} do
      {:error, changeset} = Assets.create(%{asset_data | minter_id: non_existing_id})

      %{minter_id: ["does not exist"]} = errors_on(changeset)
    end

    test "with non existing blockchain", %{asset: asset_data, non_existing_id: non_existing_id} do
      {:error, changeset} =
        asset_data
        |> Map.put(:blockchain_id, non_existing_id)
        |> Assets.create()

      %{blockchain_id: ["does not exist"]} = errors_on(changeset)
    end

    test "with existing asset code", %{asset: asset_data} do
      {:ok, _asset} = Assets.create(asset_data)
      {:error, changeset} = Assets.create(asset_data)

      %{code: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    setup %{asset: asset_data} do
      {:ok, asset} = Assets.create(asset_data)

      %{
        asset: asset,
        non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146",
        invalid_id: "invalid_id"
      }
    end

    test "with valid id", %{
      asset: %Asset{id: id, code: code, supply: supply, minter_id: minter_id}
    } do
      {:ok, %Asset{code: ^code, supply: ^supply, minter_id: ^minter_id}} = Assets.retrieve(id)
    end

    test "with non existing id", %{non_existing_id: id} do
      {:error, :not_found} = Assets.retrieve(id)
    end

    test "with invalid id", %{invalid_id: id} do
      {:error, :not_found} = Assets.retrieve(id)
    end
  end

  describe "retrieve_by_code/1" do
    setup %{asset: asset_data} do
      {:ok, asset} = Assets.create(asset_data)
      %{asset: asset, non_existing_code: "non_existing_code"}
    end

    test "with valid code", %{
      asset: %{id: id, code: code, supply: supply, minter_id: minter_id}
    } do
      {:ok, %Asset{id: ^id, code: ^code, supply: ^supply, minter_id: ^minter_id}} =
        Assets.retrieve_by_code(code)
    end

    test "with non existing code", %{non_existing_code: code} do
      {:error, :not_found} = Assets.retrieve_by_code(code)
    end
  end
end
