defmodule Mintacoin.Events.Consumer do
  @moduledoc """
  This module provides functions to handle the transaction responses from crypto and update the DB records involved with the transactions.
  """

  alias Ecto.Changeset

  alias Mintacoin.{
    Crypto,
    Crypto.TxResponse,
    Events.Structs.AccountCreated,
    BlockchainEvent,
    BlockchainEvents,
    Wallet,
    Wallets
  }

  @type error ::
          Changeset.t()
          | :blockchain_transaction_error
          | :blockchain_transaction_failed
          | :invalid_event_payload
          | :bad_argument
          | :not_found

  @spec create_account(blockchain_event :: BlockchainEvent.t()) ::
          {:ok, BlockchainEvent.t()} | {:error, error()}
  def create_account(%BlockchainEvent{id: blockchain_event_id, event_payload: event_payload}) do
    %AccountCreated{destination: address} =
      account_created_event = struct(AccountCreated, event_payload)

    account_created_event
    |> execute_transaction()
    |> update_blockchain_event(blockchain_event_id)
    |> update_wallet(address)
  end

  def create_account(_blockchain_event), do: {:error, :bad_argument}

  @spec execute_transaction(account_created_event :: AccountCreated.t()) ::
          {:ok, TxResponse.t()} | {:error, error()}
  def execute_transaction(%AccountCreated{balance: balance, destination: destination})
      when is_nil(balance) or is_nil(destination) do
    {:error, :invalid_event_payload}
  end

  def execute_transaction(%AccountCreated{} = account_created_event) do
    Crypto.create_account(account_created_event)
  end

  @spec update_blockchain_event(
          tx_response :: {:ok, TxResponse.t()},
          blockchain_event_id :: binary()
        ) ::
          {:ok, BlockchainEvent.t()} | {:error, error()}
  def update_blockchain_event(
        {:ok, %TxResponse{id: tx_id, hash: tx_hash, successful: successful, raw_tx: tx_response}},
        blockchain_event_id
      ) do
    BlockchainEvents.update(blockchain_event_id, %{
      successful: successful,
      tx_id: tx_id,
      tx_hash: tx_hash,
      tx_response: tx_response
    })
  end

  def update_blockchain_event({:error, %TxResponse{}}, _blockchain_event_id) do
    {:error, :blockchain_transaction_error}
  end

  def update_blockchain_event({:error, _error} = error, _blockchain_event_id) do
    error
  end

  @spec update_wallet(blockchain_event :: {:ok, BlockchainEvent.t()}, address :: binary()) ::
          {:ok, Wallet.t()} | {:error, error()}
  def update_wallet(
        {:ok, %BlockchainEvent{id: blockchain_event_id, successful: true} = blockchain_event},
        address
      ) do
    address
    |> Wallets.update_by_address(%{
      blockchain_event_id: blockchain_event_id,
      settled_in_blockchain: true
    })
    |> case do
      {:ok, %Wallet{}} -> {:ok, blockchain_event}
      {:error, error} -> {:error, error}
    end
  end

  def update_wallet({:error, _error} = error, _address) do
    error
  end

  def update_wallet(_blockchain_event, _address) do
    {:error, :blockchain_transaction_failed}
  end
end
