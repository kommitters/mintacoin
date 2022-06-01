defmodule Mintacoin.Accounts do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Accounts
  """

  alias Mintacoin.Repo
  alias Ecto.Changeset
  alias Mintacoin.Account

  @type address :: String.t()
  @type seed_words :: String.t()
  @type secret_key :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, Account.t()} | {:error, error()}
  def create(changes) do
    %Account{}
    |> Account.create_changeset(changes)
    |> Repo.insert()
  end

  @spec retrieve(address :: address()) :: {:ok, Account.t()} | nil
  def retrieve(address) when is_binary(address) do
    Repo.get_by(Account, address: address)
  end

  def retrieve(_address), do: {:error, :bad_argument}

  @spec retrieve_by(parameter :: parameter()) :: {:ok, Account.t()} | nil
  def retrieve_by(parameter) when is_list(parameter), do: Repo.get_by(Account, parameter)

  def retrieve_by(_parameter), do: {:error, :bad_argument}

  @spec update(address :: address(), changes :: changes()) ::
          {:ok, Account.t()} | {:error, error()}
  def update(address, changes) do
    address
    |> retrieve()
    |> persist_changes(changes)
  end

  @spec delete(address :: address()) :: {:ok, Account.t()} | {:error, error()}
  def delete(address) do
    address
    |> retrieve()
    |> persist_changes(%{is_active: false})
  end

  @spec recover_secret_key(address :: address(), seed_words :: seed_words()) ::
          {:ok, secret_key()}
  def recover_secret_key(address, seed_words) do
    address
    |> retrieve()
    |> Account.recover_secret_key(seed_words)
  end

  @spec persist_changes(account :: Account.t(), changes :: changes()) ::
          {:ok, Account.t()} | {:error, error()}
  defp persist_changes(%Account{} = account, changes) do
    account
    |> Account.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes(_account, _changes), do: {:error, :not_found}
end
