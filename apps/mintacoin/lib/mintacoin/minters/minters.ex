defmodule Mintacoin.Minters do
  @moduledoc """
  This module is responsible for doing the CRD operations for Minters
  """

  alias Ecto.{Changeset, NoResultsError, UUID, Query.CastError}
  alias Mintacoin.{Repo, Minter}

  @type id :: UUID.t()
  @type api_key :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found | :bad_argument

  @active_status :active
  @deleted_status :deleted

  @spec create(changes :: changes()) :: {:ok, Minter.t()} | {:error, error()}
  def create(changes) do
    %Minter{}
    |> Minter.create_changeset(changes)
    |> Repo.insert()
  end

  @spec delete(id :: id()) :: {:ok, Minter.t()} | {:error, error()}
  def delete(id) do
    Minter
    |> Repo.get(id)
    |> persist_changes(%{status: @deleted_status})
  end

  @spec retrieve(id :: id()) :: {:ok, Minter.t()} | {:error, error()}
  def retrieve(id), do: retrieve_by(id: id)

  @spec retrieve_authorized_by_api_key(api_key :: api_key()) ::
          {:ok, Minter.t()} | {:error, error()}
  def retrieve_authorized_by_api_key(api_key),
    do: retrieve_by(api_key: api_key, status: @active_status)

  @spec retrieve_by(parameter :: parameter()) ::
          {:ok, Minter.t()} | {:error, error()}
  def retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(Minter, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

  def retrieve_by(_parameter), do: {:error, :bad_argument}

  @spec persist_changes(minter :: Minter.t(), changes :: changes()) ::
          {:ok, Minter.t()} | {:error, error()}
  defp persist_changes(%Minter{} = minter, changes) do
    minter
    |> Minter.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes(_minter, _changes), do: {:error, :not_found}
end
