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
         {:ok, %BlockchainEvent{} = blockchain_event} <-
           BlockchainEvents.update(blockchain_event_id, %{
             successful: successful,
             tx_id: tx_id,
             tx_hash: tx_hash,
             tx_response: tx_response
           }),
         {:ok, %Wallet{id: wallet_id}} <- Wallets.retrieve_by_address(address),
         {:ok, %Wallet{}} <-
           Wallets.update(wallet_id, %{
             blockchain_event_id: blockchain_event_id,
             settled_in_blockchain: true
           }) do
      {:ok, blockchain_event}
    else
      {:error, error} ->
        {:error, error}

      error ->
        {:error, error}
    end
  end

  def create_account(_blockchain_event), do: {:error, :bad_argument}
end
