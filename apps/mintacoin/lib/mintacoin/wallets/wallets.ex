defmodule Mintacoin.Wallets do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Wallets
  """
  alias Ecto.{NoResultsError, Changeset, UUID}
  alias Ecto.Query.CastError
  alias Mintacoin.{Repo, Wallet}

  @type id :: UUID.t()
  @type address :: String.t()
  @type account_id :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found | :bad_argument

  @spec create(changes :: changes()) :: {:ok, Wallet.t()} | {:error, error()}
  def create(changes) do
    %Wallet{}
    |> Wallet.changeset(changes)
    |> Repo.insert()
  end

  @spec retrieve(id :: id()) :: {:ok, Wallet.t()} | {:error, error()}
  def retrieve(id), do: retrieve_by(id: id)

  @spec retrieve_by_address(address :: address()) :: {:ok, Wallet.t()} | {:error, error()}
  def retrieve_by_address(address), do: retrieve_by(address: address)

  @spec retrieve_by_account_id(account_id :: account_id()) ::
          {:ok, Wallet.t()} | {:error, error()}
  def retrieve_by_account_id(account_id), do: retrieve_by(account_id: account_id)

  @spec retrieve_by(parameter :: parameter()) :: {:ok, Wallet.t()} | {:error, error()}
  def retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(Wallet, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

  def retrieve_by(_parameter), do: {:error, :bad_argument}
end
