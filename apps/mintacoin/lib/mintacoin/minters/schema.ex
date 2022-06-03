defmodule Mintacoin.Minter do
  @moduledoc """
  Ecto schema for minter
  """

  use Ecto.Schema

  import Ecto.Changeset
  import EctoEnum

  alias Ecto.Changeset

  @type status :: :active | :archived

  @type t :: %__MODULE__{
          email: String.t(),
          name: String.t(),
          status: status(),
          api_key: String.t()
        }

  defenum(Status, :status, [
    :active,
    :archived
  ])

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "minters" do
    field(:email, :string)
    field(:name, :string)
    field(:status, Status, default: :active)
    field(:api_key, :string)

    timestamps()
  end

  @spec changeset(minter :: Minter.t(), changes :: map()) :: Changeset.t()
  def changeset(minter, changes) do
    minter
    |> cast(changes, [
      :email,
      :name,
      :status,
      :api_key
    ])
    |> unique_constraint([:api_key])
    |> unique_constraint([:email])
  end

  @spec create_changeset(minter :: Minter.t(), changes :: map()) :: Changeset.t()
  def create_changeset(minter, changes) do
    minter
    |> cast(changes, [
      :email,
      :name,
      :status,
      :api_key
    ])
    |> validate_required([:email, :name, :api_key])
    |> unique_constraint([:api_key])
    |> unique_constraint([:email])
  end
end
