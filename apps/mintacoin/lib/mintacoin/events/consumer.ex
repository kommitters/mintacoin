defmodule Mintacoin.Events.Consumer do
  @moduledoc """
  This module provides functions to handle the transaction responses from crypto and update the DB records involved with the transactions.
  """

  alias Mintacoin.{
    Crypto,
    Crypto.TxResponse,
    Events.Structs.AccountCreated,
    BlockchainEvent,
    BlockchainEvents,
    Wallet,
    Wallets
  }

  @spec create_account(blockchain_event :: BlockchainEvent.t()) ::
          {:ok, BlockchainEvent.t()} | {:error, term()}
  def create_account(%BlockchainEvent{id: blockchain_event_id, event_payload: event_payload}) do
    with %AccountCreated{destination: address} = account_created_event <-
           struct(AccountCreated, event_payload),
         {:ok, %TxResponse{id: tx_id, hash: tx_hash, successful: successful, raw_tx: tx_response}} <-
           Crypto.create_account(account_created_event),
         # Pipeline continues only if the transaction was successful,
         # but the BlockchainEvent is updated eitherway.
         {:ok, %BlockchainEvent{successful: true} = blockchain_event} <-
           BlockchainEvents.update(blockchain_event_id, %{
             successful: successful,
             tx_id: tx_id,
             tx_hash: tx_hash,
             tx_response: tx_response
           }),
         {:ok, %Wallet{}} <-
           Wallets.update_by_address(address, %{
             blockchain_event_id: blockchain_event_id,
             settled_in_blockchain: true
           }) do
      {:ok, blockchain_event}
    else
      {:error, %TxResponse{}} ->
        {:error, :blockchain_transaction_error}

      {:error, error} ->
        {:error, error}

      {:ok, %BlockchainEvent{}} ->
        {:error, :blockchain_transaction_failed}

      error when is_struct(error) ->
        {:error, :invalid_event_payload}
    end
  end

  def create_account(_blockchain_event), do: {:error, :bad_argument}
end
