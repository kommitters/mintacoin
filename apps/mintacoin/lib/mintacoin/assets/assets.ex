defmodule Mintacoin.Assets do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Assets
  """

  alias Ecto.{NoResultsError, Changeset, UUID}
  alias Ecto.Query.CastError
  alias Mintacoin.{Repo, Asset, Blockchain}
  alias Mintacoin.Utils.DefaultResources

  @type id :: UUID.t()
  @type code :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, Asset.t()} | {:error, error()}
  def create(%{blockchain_id: _blockchain_id} = changes) do
    %Asset{}
    |> Asset.changeset(changes)
    |> Repo.insert()
  end

  def create(changes) do
    %Blockchain{id: blockchain_id} = DefaultResources.blockchain()

    changes
    |> Map.put(:blockchain_id, blockchain_id)
    |> create()
  end

  @spec retrieve(id :: id()) :: {:ok, Asset.t()} | {:error, error()}
  def retrieve(id), do: retrieve_by(id: id)

  @spec retrieve_by_code(code :: code()) :: {:ok, Asset.t()} | {:error, error()}
  def retrieve_by_code(code), do: retrieve_by(code: code)

  @spec retrieve_by(parameter :: parameter()) :: {:ok, Asset.t()} | {:error, error()}
  defp retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(Asset, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end
end
