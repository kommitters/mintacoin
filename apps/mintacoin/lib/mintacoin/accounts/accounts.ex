defmodule Mintacoin.Accounts do
  @moduledoc """
  This module is responsible for doing the CRUD operations for Accounts
  """

  alias Ecto.{Changeset, NoResultsError}
  alias Ecto.Query.CastError
  alias Mintacoin.{Repo, Account, Mnemonic, Encryption, Keypair}

  @type address :: String.t()
  @type seed_words :: String.t()
  @type signature :: String.t()
  @type changes :: map()
  @type parameter :: keyword()
  @type error :: Changeset.t() | :not_found | :decoding_error | :bad_argument

  @active_status :active
  @archived_status :archived

  @spec create(changes :: changes()) :: {:ok, Account.t()} | {:error, error()}
  def create(changes) do
    changes
    |> add_signature_fields()
    |> (&Account.create_changeset(%Account{}, &1)).()
    |> Repo.insert()
  end

  @spec retrieve(address :: address()) :: {:ok, Account.t()} | {:error, error()}
  def retrieve(address) when is_binary(address) do
    retrieve_by(address: address, status: @active_status)
  end

  def retrieve(_address), do: {:error, :not_found}

  @spec retrieve_by(parameter :: parameter()) ::
          {:ok, Account.t()} | {:error, error()}
  def retrieve_by(parameter) when is_list(parameter) do
    {:ok, Repo.get_by!(Account, parameter)}
  rescue
    CastError -> {:error, :not_found}
    NoResultsError -> {:error, :not_found}
  end

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
    update(address, %{status: @archived_status})
  end

  @spec recover_signature(address :: address(), seed_words :: seed_words()) ::
          {:ok, signature()} | {:error, error()}
  def recover_signature(address, seed_words) do
    with {:ok, %Account{encrypted_signature: encrypted_signature}} <- retrieve(address),
         {:ok, entropy} <- Mnemonic.to_entropy(seed_words) do
      Encryption.decrypt(encrypted_signature, entropy)
    else
      {:error, :not_found} -> {:error, :not_found}
      _error -> {:error, :bad_argument}
    end
  end

  @spec persist_changes({:ok, Account.t()} | {:error, error()}, changes :: changes()) ::
          {:ok, Account.t()} | {:error, error()}
  defp persist_changes({:ok, %Account{} = account}, changes) do
    account
    |> Account.changeset(changes)
    |> Repo.update()
  end

  defp persist_changes({:error, error}, _changes), do: {:error, error}

  @spec add_signature_fields(changes :: changes()) :: changes()
  defp add_signature_fields(changes) do
    {:ok, {derived_key, signature}} = Keypair.random()
    {:ok, {entropy, seed_words}} = Mnemonic.random_entropy_and_mnemonic()
    {:ok, encrypted_signature} = Encryption.encrypt(signature, entropy)

    Map.merge(changes, %{
      derived_key: derived_key,
      encrypted_signature: encrypted_signature,
      seed_words: seed_words,
      signature: signature
    })
  end
end
