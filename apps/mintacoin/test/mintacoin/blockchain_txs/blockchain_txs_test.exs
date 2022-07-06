defmodule Mintacoin.BlockchainTxs.BlockchainTxsTest do
  @moduledoc """
    This module is used to group common tests for BlockchainTx functions
  """
  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 1]

  alias Ecto.{Changeset, Adapters.SQL.Sandbox}

  alias Mintacoin.{
    Repo,
    BlockchainTx,
    BlockchainTxs,
    Blockchain,
    Blockchains,
    Blockchains.Network
  }

  setup do
    :ok = Sandbox.checkout(Repo)
    {:ok, %Blockchain{id: blockchain_id}} = Blockchains.create(%{name: Network.name()})

    %{
      blockchain_tx: %{
        blockchain_id: blockchain_id,
        operation_type: :create_account,
        operation_payload: %{},
        signatures: []
      },
      invalid_id: "1",
      non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146"
    }
  end

  describe "create/1" do
    test "with valid params", %{
      blockchain_tx: %{blockchain_id: blockchain_id} = blockchain_tx_data
    } do
      {:ok,
       %BlockchainTx{
         blockchain_id: ^blockchain_id,
         state: :pending,
         successful: false,
         tx_id: nil,
         tx_hash: nil,
         tx_response: %{}
       }} = BlockchainTxs.create(blockchain_tx_data)
    end

    test "with invalid params" do
      {:error, changeset} = BlockchainTxs.create(%{})

      %{
        operation_payload: ["can't be blank"],
        operation_type: ["can't be blank"],
        signatures: ["can't be blank"]
      } = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    setup do
      %{blockchain_tx: insert(:blockchain_tx)}
    end

    test "with valid id", %{blockchain_tx: %BlockchainTx{id: id} = blockchain_tx} do
      {:ok, ^blockchain_tx} = BlockchainTxs.retrieve(id)
    end

    test "with non existing id", %{non_existing_id: id} do
      {:error, :not_found} = BlockchainTxs.retrieve(id)
    end

    test "with invalid id", %{invalid_id: id} do
      {:error, :not_found} = BlockchainTxs.retrieve(id)
    end
  end

  describe "update/1" do
    setup do
      %{
        blockchain_tx: insert(:blockchain_tx),
        valid_attrs: %{
          state: :completed,
          successful: true,
          tx_id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
          tx_hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
          tx_response: %{
            id: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
            hash: "7f82fe6ac195e7674f7bdf7a3416683ffd55c8414978c70bf4da08ac64fea129",
            sucessful: true,
            created_at: ~U[2022-06-29 15:45:45Z]
          }
        },
        invalid_attrs: %{
          signatures: [1, 2, 3],
          state: :invalid_state,
          successful: "invalid_successful",
          tx_response: "invalid_tx_response"
        }
      }
    end

    test "with invalid id", %{invalid_id: id, valid_attrs: valid_attrs} do
      {:error, :not_found} = BlockchainTxs.update(id, valid_attrs)
    end

    test "with non existing id", %{non_existing_id: id, valid_attrs: valid_attrs} do
      {:error, :not_found} = BlockchainTxs.update(id, valid_attrs)
    end

    test "with invalid params", %{
      blockchain_tx: %BlockchainTx{id: id},
      invalid_attrs: invalid_attrs
    } do
      {:error,
       %Changeset{
         errors: [
           signatures: {"is invalid", [type: {:array, :string}, validation: :cast]},
           state: {"is invalid", [type: BlockchainTx.State, validation: :cast]},
           successful: {"is invalid", [type: :boolean, validation: :cast]},
           tx_response: {"is invalid", [type: :map, validation: :cast]}
         ]
       }} = BlockchainTxs.update(id, invalid_attrs)
    end

    test "with valid params", %{
      blockchain_tx: %BlockchainTx{id: id},
      valid_attrs:
        %{
          state: state,
          successful: successful,
          tx_id: tx_id,
          tx_hash: tx_hash,
          tx_response: tx_response
        } = valid_attrs
    } do
      {:ok,
       %BlockchainTx{
         id: ^id,
         state: ^state,
         successful: ^successful,
         tx_id: ^tx_id,
         tx_hash: ^tx_hash,
         tx_response: ^tx_response
       }} = BlockchainTxs.update(id, valid_attrs)
    end
  end
end
