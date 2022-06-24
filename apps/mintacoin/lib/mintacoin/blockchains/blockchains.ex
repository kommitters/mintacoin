defmodule Mintacoin.Blockchains do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Blockchains
  """

  alias Ecto.{NoResultsError, Changeset, UUID, Query.CastError}
  alias Mintacoin.{Repo, Blockchain}

  @type id :: UUID.t()
  @type name :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, Blockchain.t()} | {:error, error()}
  def create(changes) do
    %Blockchain{}
    |> Blockchain.changeset(changes)
    |> Repo.insert()
  end

  @spec retrieve(id :: id()) :: {:ok, Blockchain.t()} | {:error, error()}
  def retrieve(id), do: retrieve_by(id: id)

  @spec retrieve_by(parameter :: parameter()) :: {:ok, Blockchain.t()} | {:error, error()}
  def retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(Blockchain, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

  @spec update(id :: id(), changes :: changes()) :: {:ok, Blockchain.t()} | {:error, error()}
  def update(id, changes), do: update_by([id: id], changes)

  @spec update_by_name(name :: name(), changes :: changes()) ::
          {:ok, Blockchain.t()} | {:error, error()}
  def update_by_name(name, changes), do: update_by([name: name], changes)

  @spec update_by(parameter :: parameter(), changes :: changes()) ::
          {:ok, Blockchain.t()} | {:error, error()}
  defp update_by(parameter, changes) when is_list(parameter) do
    parameter
    |> retrieve_by()
    |> persist_changes(changes)
  end

  @spec persist_changes({:ok, Blockchain.t()} | {:error, error()}, changes :: changes()) ::
          {:ok, Blockchain.t()} | {:error, error()}
  defp persist_changes({:ok, %Blockchain{} = blockchain}, changes) do
    blockchain
    |> Blockchain.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes({:error, error}, _changes), do: {:error, error}
end
