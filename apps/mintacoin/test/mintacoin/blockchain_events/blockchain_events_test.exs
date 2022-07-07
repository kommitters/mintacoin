defmodule Mintacoin.BlockchainEvents.BlockchainEventsTest do
  @moduledoc """
    This module is used to group common tests for BlockchainEvent functions
  """
  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 1]

  alias Ecto.{Changeset, Adapters.SQL.Sandbox}

  alias Mintacoin.{
    Repo,
    BlockchainEvent,
    BlockchainEvents,
    Blockchain,
    Blockchains,
    Blockchains.Network
  }

  setup do
    :ok = Sandbox.checkout(Repo)
    {:ok, %Blockchain{id: blockchain_id}} = Blockchains.create(%{name: Network.name()})

    %{
      blockchain_event: %{
        blockchain_id: blockchain_id,
        event_type: :create_account,
        event_payload: %{
          signatures: "signature_1"
        }
      },
      invalid_id: "1",
      non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146"
    }
  end

  describe "create/1" do
    test "with valid params", %{
      blockchain_event: %{blockchain_id: blockchain_id} = blockchain_event_data
    } do
      {:ok,
       %BlockchainEvent{
         blockchain_id: ^blockchain_id,
         event_payload: %{
           signatures: "signature_1"
         },
         state: :pending,
         successful: false,
         tx_id: nil,
         tx_hash: nil,
         tx_response: %{}
       }} = BlockchainEvents.create(blockchain_event_data)
    end

    test "with invalid params" do
      {:error, changeset} = BlockchainEvents.create(%{})

      %{
        event_payload: ["can't be blank"],
        event_type: ["can't be blank"]
      } = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    setup do
      %{blockchain_event: insert(:blockchain_event)}
    end

    test "with valid id", %{blockchain_event: %BlockchainEvent{id: id} = blockchain_event} do
      {:ok, ^blockchain_event} = BlockchainEvents.retrieve(id)
    end

    test "with non existing id", %{non_existing_id: id} do
      {:error, :not_found} = BlockchainEvents.retrieve(id)
    end

    test "with invalid id", %{invalid_id: id} do
      {:error, :not_found} = BlockchainEvents.retrieve(id)
    end
  end

  describe "update/1" do
    setup do
      %{
        blockchain_event: insert(:blockchain_event),
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
          state: :invalid_state,
          successful: "invalid_successful",
          tx_response: "invalid_tx_response"
        }
      }
    end

    test "with invalid id", %{invalid_id: id, valid_attrs: valid_attrs} do
      {:error, :not_found} = BlockchainEvents.update(id, valid_attrs)
    end

    test "with non existing id", %{non_existing_id: id, valid_attrs: valid_attrs} do
      {:error, :not_found} = BlockchainEvents.update(id, valid_attrs)
    end

    test "with invalid params", %{
      blockchain_event: %BlockchainEvent{id: id},
      invalid_attrs: invalid_attrs
    } do
      {:error,
       %Changeset{
         errors: [
           state: {"is invalid", [type: BlockchainEvent.State, validation: :cast]},
           successful: {"is invalid", [type: :boolean, validation: :cast]},
           tx_response: {"is invalid", [type: :map, validation: :cast]}
         ]
       }} = BlockchainEvents.update(id, invalid_attrs)
    end

    test "with valid params", %{
      blockchain_event: %BlockchainEvent{id: id},
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
       %BlockchainEvent{
         id: ^id,
         state: ^state,
         successful: ^successful,
         tx_id: ^tx_id,
         tx_hash: ^tx_hash,
         tx_response: ^tx_response
       }} = BlockchainEvents.update(id, valid_attrs)
    end
  end
end
