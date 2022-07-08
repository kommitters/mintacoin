defmodule Mintacoin.Core.Accounts do
  @moduledoc """
  This module defines the pipeline with the business logic for Account operations
  """

  alias Mintacoin.{
    Repo,
    Account,
    Accounts,
    Blockchain,
    Blockchains,
    BlockchainEvent,
    BlockchainEvents,
    Wallet,
    Wallets,
    Events.Structs.AccountCreated,
    Crypto,
    Encryption
  }

  alias Ecto.{Multi, Changeset}

  @starting_balance 1.5

  @type error :: Changeset.t() | :blockchain_not_found
  @type resource :: Account.t() | Wallet.t() | BlockchainEvent.t()

  @spec create(params :: map()) :: {:ok, Account.t()} | {:error, error()}
  def create(params),
    do:
      Multi.new()
      |> Multi.run(:create_account_step, create_account(params))
      |> Multi.run(:create_wallet_step, create_wallet(params))
      |> Multi.run(:create_blockchain_event_step, &create_blockchain_event/2)
      |> Repo.transaction()
      |> handle_multi_response()

  defp create_account(params) do
    fn _repo, _ ->
      params
      |> Accounts.create()
      |> format_response()
    end
  end

  defp create_wallet(%{blockchain: blockchain}) do
    fn _repo, %{create_account_step: %Account{id: account_id, signature: signature}} ->
      case Blockchains.retrieve_by(name: blockchain) do
        {:ok, %Blockchain{id: blockchain_id}} ->
          {address, secret} = Crypto.random_keypair()
          {:ok, encrypted_secret} = Encryption.encrypt(secret, signature)

          %{
            blockchain_id: blockchain_id,
            account_id: account_id,
            address: address,
            encrypted_secret: encrypted_secret,
            secret: secret
          }
          |> Wallets.create()
          |> format_response()

        {:error, :not_found} ->
          {:error, :blockchain_not_found}
      end
    end
  end

  defp create_blockchain_event(_repo, %{
         create_wallet_step: %Wallet{address: address, blockchain_id: blockchain_id}
       }) do
    event_payload =
      Map.from_struct(%AccountCreated{
        destination: address,
        balance: @starting_balance
      })

    %{
      blockchain_id: blockchain_id,
      event_type: :create_account,
      event_payload: event_payload
    }
    |> BlockchainEvents.create()
    |> format_response()
  end

  @spec handle_multi_response(response :: tuple()) :: {:ok, Account.t()} | {:error, error()}
  defp handle_multi_response({:ok, %{create_account_step: account}}), do: {:ok, account}
  defp handle_multi_response({:error, _step, error, _result}), do: {:error, error}

  @spec format_response(response :: {:ok, resource()} | {:error, error()}) ::
          {:ok, resource()} | {:error, error()}
  defp format_response({:ok, resource}), do: {:ok, resource}
  defp format_response({:error, reason}), do: {:error, reason}
end
