defmodule Database.Accounts.AccountsTest do
  @moduledoc """
    This module is used to group common tests for Minters functions
  """

  use ExUnit.Case, async: false

  alias Mintacoin.Minters
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)
  end

  describe "minters creation" do
    setup do
      %{
        full_minter: %{
          email: "test@mail.com",
          name: "Test Minter",
          api_key: "LTS3c860j40uU2MaAmnHA4kQKV5mvHDhSKwCgP3vFpU"
        },
        incomplete_minter: %{
          name: "Test Minter 2",
          api_key: "vPKbiO11yQ5JKnRn0Rpfo+WiJy9KxM8SoJbpFq2ybbk"
        }
      }
    end

    test "Create minter", %{full_minter: %{email: email} = minter_data} do
      {:ok, %{email: ^email}} = Minters.create_minter(minter_data)
    end

    test "validate required fields", %{incomplete_minter: minter_data} do
      {:error, _error} = Minters.create_minter(minter_data)
    end
  end

  describe "minters archive" do
    setup do
      {:ok, %{id: id}} =
        Minters.create_minter(%{
          email: "test3@mail.com",
          name: "Test Minter 3",
          api_key: "i4b0OpB00oHVZERCdOEKf+3/Oz2zeBxNKvzdzYc/wgc"
        })

      %{id: id}
    end

    test "archive minter with given id", %{id: id} do
      {:ok, %{status: :archived}} = Minters.archive_minter(id)
    end

    test "not found minter" do
      {:error, _error} = Minters.archive_minter("32c2a7a2-ebb9-4b28-a199-cd34234b2d58")
    end
  end

  describe "minters validate access" do
    setup do
      Minters.create_minter(%{
        email: "test4@mail.com",
        name: "Test Minter 4",
        api_key: "J6CwjuzoR3I2hGzXFFUz7mtp/insEoadWQ80nDUOkCw"
      })

      %{api_key: "J6CwjuzoR3I2hGzXFFUz7mtp/insEoadWQ80nDUOkCw"}
    end

    test "with an authorized key", %{api_key: api_key} do
      true = Minters.is_authorized(api_key)
    end

    test "with an invalid key" do
      false = Minters.is_authorized("INVALID")
    end
  end
end
