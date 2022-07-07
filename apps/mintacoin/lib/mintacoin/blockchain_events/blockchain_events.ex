defmodule Mintacoin.BlockchainEvents do
  @moduledoc """
  This module is responsible for doing the CRUD operations for BlockchainEvents
  """

  alias Ecto.{UUID, Changeset, Query.CastError, NoResultsError}
  alias Mintacoin.{Repo, BlockchainEvent, Blockchain, Blockchains.Network}

  @type id :: UUID.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, BlockchainEvent.t()} | {:error, error()}
  def create(%{blockchain_id: _blockchain_id} = changes) do
    %BlockchainEvent{}
    |> BlockchainEvent.create_changeset(changes)
    |> Repo.insert()
  end

  def create(changes) do
    %Blockchain{id: blockchain_id} = Network.struct()

    changes
    |> Map.put(:blockchain_id, blockchain_id)
    |> create()
  end

  @spec retrieve(id :: id()) :: {:ok, BlockchainEvent.t()} | {:error, error()}
  def retrieve(id), do: retrieve_by(id: id)

  @spec update(id :: id(), changes :: changes()) :: {:ok, BlockchainEvent.t()} | {:error, error()}
  def update(id, changes) do
    id
    |> retrieve()
    |> persist_changes(changes)
  end

  @spec retrieve_by(parameter :: parameter()) :: {:ok, BlockchainEvent.t()} | {:error, error()}
  defp retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(BlockchainEvent, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

  @spec persist_changes({:ok, BlockchainEvent.t()} | {:error, error()}, changes :: changes()) ::
          {:ok, BlockchainEvent.t()} | {:error, error()}
  defp persist_changes({:ok, %BlockchainEvent{} = blockchain_event}, changes) do
    blockchain_event
    |> BlockchainEvent.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes({:error, error}, _changes), do: {:error, error}
end
