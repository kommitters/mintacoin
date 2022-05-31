defmodule Database.Accounts.AccountsTest do
  @moduledoc """
    This module is used to group common tests for Minters functions
  """

  use Mintacoin.DataCase, async: false

  alias Mintacoin.{Minter, Minters}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)
  end

  describe "create_minter/1" do
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
      {:ok, %Minter{email: ^email}} = Minters.create_minter(minter_data)
    end

    test "validate required fields" do
      {:error, changeset} = Minters.create_minter(%{})

      %{
        api_key: ["can't be blank"],
        email: ["can't be blank"],
        name: ["can't be blank"]
      } = errors_on(changeset)
    end
  end

  describe "archive_minter/1" do
    setup do
      {:ok, %Minter{id: id}} =
        Minters.create_minter(%{
          email: "test3@mail.com",
          name: "Test Minter 3",
          api_key: "i4b0OpB00oHVZERCdOEKf+3/Oz2zeBxNKvzdzYc/wgc"
        })

      %{id: id}
    end

    test "with valid id, archive minter", %{id: id} do
      {:ok, %Minter{status: :archived}} = Minters.archive_minter(id)
    end

    test "with not valid id, return not found error" do
      {:error, :not_found} = Minters.archive_minter("32c2a7a2-ebb9-4b28-a199-cd34234b2d58")
    end
  end

  describe "is_authorized?/1" do
    setup do
      {:ok, %Minter{api_key: api_key}} =
        Minters.create_minter(%{
          email: "test4@mail.com",
          name: "Test Minter 4",
          api_key: "J6CwjuzoR3I2hGzXFFUz7mtp/insEoadWQ80nDUOkCw"
        })

      %{api_key: api_key}
    end

    test "return true with an authorized key", %{api_key: api_key} do
      true = Minters.is_authorized?(api_key)
    end

    test "rerturn false with an invalid key" do
      false = Minters.is_authorized?("INVALID")
    end
  end
end
