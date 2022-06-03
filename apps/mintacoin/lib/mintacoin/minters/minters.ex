defmodule Mintacoin.Minters do
  @moduledoc """
  This module is responsible for doing the CRD operations for Minters
  """

  alias Mintacoin.Repo
  alias Ecto.Changeset
  alias Mintacoin.Minter

  @type id :: String.t()
  @type api_key :: String.t()
  @type changes :: map()
  @type error :: Changeset.t() | :not_found

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

  @spec is_authorized?(api_key :: api_key()) :: boolean()
  def is_authorized?(api_key) do
    Minter
    |> Repo.get_by(api_key: api_key)
    |> has_access?()
  end

  @spec persist_changes(minter :: Minter.t(), changes :: changes()) ::
          {:ok, Minter.t()} | {:error, error()}
  defp persist_changes(%Minter{} = minter, changes) do
    minter
    |> Minter.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes(_minter, _changes), do: {:error, :not_found}

  @spec has_access?(minter :: Minter.t()) :: boolean()
  defp has_access?(%Minter{status: status}), do: status != @deleted_status
  defp has_access?(_minter), do: false
end
