defmodule Mintacoin.Assets do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Assets
  """

  import Ecto.Query

  alias Ecto.{NoResultsError, Changeset, UUID}
  alias Ecto.Query.CastError
  alias Mintacoin.{Repo, Asset, Blockchain, Minter, Account}
  alias Mintacoin.Utils.DefaultResources

  @type id :: UUID.t()
  @type code :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found

  @spec create(changes :: changes()) :: {:ok, Asset.t()} | {:error, error()}
  def create(%{blockchain_id: _blockchain_id} = changes) do
    changes
    |> complete_code_with_address()
    |> (&Asset.changeset(%Asset{}, &1)).()
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

  @spec complete_code_with_address(changes :: changes()) :: changes()
  defp complete_code_with_address(%{minter_id: minter_id, code: code} = changes) do
    query =
      from(minter in Minter,
        join: account in Account,
        on: minter.email == account.email,
        where: minter.id == ^minter_id,
        select: %{address: account.address}
      )

    case Repo.one(query) do
      %{address: address} ->
        %{changes | code: "#{code}:#{address}"}

      nil ->
        changes
    end
  end

  defp complete_code_with_address(changes), do: changes
end
