defmodule Mintacoin.Payments do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Payments
  """

  alias Ecto.{Query.CastError, NoResultsError, Changeset, UUID}
  alias Mintacoin.{Repo, Payment}

  @type id :: UUID.t()
  @type changes :: map()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, Payment.t()} | {:error, error()}
  def create(changes) do
    %Payment{}
    |> Payment.create_changeset(changes)
    |> Repo.insert()
  end

  @spec retrieve(id :: id()) :: {:ok, Payment.t()} | {:error, error()}
  def retrieve(id) do
    {:ok, Repo.get!(Payment, id)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

  @spec update(id :: id(), changes :: changes()) :: {:ok, Payment.t()} | {:error, error()}
  def update(id, changes) do
    id
    |> retrieve()
    |> persist_changes(changes)
  end

  @spec persist_changes({:ok, Payment.t()} | {:error, error()}, changes :: changes()) ::
          {:ok, Payment.t()} | {:error, error()}
  defp persist_changes({:ok, %Payment{} = payment}, changes) do
    payment
    |> Payment.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes({:error, _error} = error, _changes), do: error
end
