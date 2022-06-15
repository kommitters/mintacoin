defmodule Mintacoin.Minters.MintersTest do
  @moduledoc """
    This module is used to group common tests for Minters functions
  """

  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 1]

  alias Mintacoin.{Minter, Minters}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)
  end

  describe "create/1" do
    setup do
      %{
        minter: %{
          email: "test@mail.com",
          name: "Test Minter",
          api_key: "LTS3c860j40uU2MaAmnHA4kQKV5mvHDhSKwCgP3vFpU"
        }
      }
    end

    test "with valid params", %{minter: %{email: email} = minter_data} do
      {:ok, %Minter{email: ^email}} = Minters.create(minter_data)
    end

    test "validate required fields" do
      {:error, changeset} = Minters.create(%{})

      %{
        api_key: ["can't be blank"],
        email: ["can't be blank"],
        name: ["can't be blank"]
      } = errors_on(changeset)
    end

    test "validate email format", %{minter: minter_data} do
      {:error, changeset} = Minters.create(%{minter_data | email: "INVALID_EMAIL"})

      %{
        email: ["must have the @ sign and no spaces"]
      } = errors_on(changeset)
    end
  end

  describe "delete/1" do
    setup do
      %Minter{id: id} = insert(:minter)
      %{id: id}
    end

    test "with valid id, delete minter", %{id: id} do
      {:ok, %Minter{status: :deleted}} = Minters.delete(id)
    end

    test "with not valid id, return not found error" do
      {:error, :not_found} = Minters.delete("32c2a7a2-ebb9-4b28-a199-cd34234b2d58")
    end
  end

  describe "retrieve/1" do
    setup do
      %Minter{id: id} = insert(:minter)
      %{id: id}
    end

    test "with valid id, return minter", %{id: id} do
      {:ok, %Minter{id: ^id}} = Minters.retrieve(id)
    end

    test "with not valid id, return not found error" do
      {:error, :not_found} = Minters.retrieve("32c2a7a2-ebb9-4b28-a199-cd34234b2d58")
    end
  end

  describe "retrieve_authorized_by_api_key/1" do
    setup do
      %Minter{api_key: api_key} = insert(:minter)
      %{api_key: api_key}
    end

    test "returns minter with an authorized key", %{api_key: api_key} do
      {:ok, %Minter{api_key: ^api_key}} = Minters.retrieve_authorized_by_api_key(api_key)
    end

    test "returns not found error with an invalid key" do
      {:error, :not_found} = Minters.retrieve_authorized_by_api_key("INVALID")
    end
  end

  describe "retrieve_by/1" do
    setup do
      %{minter: insert(:minter)}
    end

    test "with valid params, return minter", %{minter: %Minter{email: email}} do
      {:ok, %Minter{email: ^email}} = Minters.retrieve_by(email: email)
    end

    test "with not valid params, return not found error" do
      {:error, :not_found} = Minters.retrieve_by(email: "invalid@example.com")
    end

    test "with bad argument" do
      {:error, :bad_argument} = Minters.retrieve_by("invalid")
    end
  end
end
