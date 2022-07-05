defmodule Mintacoin.BlockchainTxs do
  @moduledoc """
  This module is responsible for doing the CRUD operations for BlockchainTxs
  """

  alias Ecto.{UUID, Changeset, Query.CastError, NoResultsError}
  alias Mintacoin.{Repo, BlockchainTx, Blockchain, Blockchains.Network}

  @type id :: UUID.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, BlockchainTx.t()} | {:error, error()}
  def create(%{blockchain_id: _blockchain_id} = changes) do
    %BlockchainTx{}
    |> BlockchainTx.create_changeset(changes)
    |> Repo.insert()
  end

  def create(changes) do
    %Blockchain{id: blockchain_id} = Network.struct()

    changes
    |> Map.put(:blockchain_id, blockchain_id)
    |> create()
  end

  @spec retrieve(id :: id()) :: {:ok, BlockchainTx.t()} | {:error, error()}
  def retrieve(id), do: retrieve_by(id: id)

  @spec retrieve_by(parameter :: parameter()) :: {:ok, BlockchainTx.t()} | {:error, error()}
  def retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(BlockchainTx, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

  @spec update(id :: id(), changes :: changes()) :: {:ok, BlockchainTx.t()} | {:error, error()}
  def update(id, changes) do
    id
    |> retrieve()
    |> persist_changes(changes)
  end

  @spec persist_changes({:ok, BlockchainTx.t()} | {:error, error()}, changes :: changes()) ::
          {:ok, BlockchainTx.t()} | {:error, error()}
  defp persist_changes({:ok, %BlockchainTx{} = blockchain_tx}, changes) do
    blockchain_tx
    |> BlockchainTx.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes({:error, error}, _changes), do: {:error, error}
end
