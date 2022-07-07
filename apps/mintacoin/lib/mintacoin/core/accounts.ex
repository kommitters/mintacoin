defmodule Mintacoin.Core.Accounts do
  @moduledoc """

  """

  alias Mintacoin.Accounts, as: AccountsDB

  alias Mintacoin.{
    Blockchain,
    Blockchains,
    BlockchainEvents,
    Wallet,
    Wallets,
    Events.Structs.AccountCreated,
    Crypto,
    Encryption
  }

  alias Ecto.Multi

  def create(params),
    do:
      Multi.new()
      |> Multi.run(:create_account_step, create_account(params))
      |> Multi.run(:create_wallet_step, create_wallet(params))
      |> Multi.run(:create_blockchain_event_step, &create_blockchain_event/2)
      |> Mintacoin.Repo.transaction()
      |> handle_multi_response()

  defp create_account(params) do
    fn _repo, _ ->
      params
      |> AccountsDB.create()
      |> format_response()
    end
  end

  defp create_wallet(%{blockchain: blockchain}) do
    fn _repo, %{create_account_step: %{id: account_id, signature: signature}} ->
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
      end
    end
  end

  defp create_blockchain_event(_repo, %{
         create_wallet_step: %Wallet{address: address, blockchain_id: blockchain_id}
       }) do
    %{
      blockchain_id: blockchain_id,
      event_type: :create_account,
      event_payload: %AccountCreated{
        destination: address,
        balance: 1.5
      }
    }
    |> BlockchainEvents.create()
    |> format_response()
  end

  @spec handle_multi_response(response :: tuple()) :: tuple()
  defp handle_multi_response({:ok, %{create_event_step: account}}),
    do: format_response(account)

  defp handle_multi_response({:error, :create_account_step, error, _result}), do: {:error, error}
  defp handle_multi_response(_response), do: {:error, "Error creating the account"}

  @spec format_response(response :: tuple() | map()) :: tuple()
  defp format_response({:error, reason}) when is_binary(reason),
    do: {:error, reason}

  defp format_response({:ok, response}), do: {:ok, response}
  defp format_response(response), do: {:ok, response}
end
