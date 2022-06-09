defmodule Mintacoin.Blockchains.BlockchainsTest do
  @moduledoc """
    This module is used to group common tests for Blockchains functions
  """

  use Mintacoin.DataCase, async: false

  alias Mintacoin.{Blockchain, Blockchains, Repo}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Repo)

    %{
      blockchain: %{
        name: "Blockchain name"
      },
      invalid_id: "1",
      non_existing_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146",
      updated_name: "Blockchain name 2",
      invalid_name: "invalid_name"
    }
  end

  describe "create/1" do
    test "with valid params", %{blockchain: %{name: name} = blockchain_data} do
      {:ok, %Blockchain{name: ^name}} = Blockchains.create(blockchain_data)
    end

    test "with invalid params" do
      {:error, changeset} = Blockchains.create(%{})
      %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "with existing blockchain", %{blockchain: blockchain_data} do
      {:ok, _blockchain} = Blockchains.create(blockchain_data)
      {:error, changeset} = Blockchains.create(blockchain_data)

      %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    setup %{blockchain: blockchain_data} do
      {:ok, blockchain} = Blockchains.create(blockchain_data)

      %{blockchain: blockchain}
    end

    test "with valid id", %{blockchain: %Blockchain{id: id, name: name}} do
      {:ok, %Blockchain{name: ^name}} = Blockchains.retrieve(id)
    end

    test "with non existing id", %{non_existing_id: id} do
      {:error, :not_found} = Blockchains.retrieve(id)
    end

    test "with invalid id", %{invalid_id: id} do
      {:error, :not_found} = Blockchains.retrieve(id)
    end
  end

  describe "retrieve_by/1" do
    setup %{blockchain: blockchain_data} do
      {:ok, blockchain} = Blockchains.create(blockchain_data)
      %{blockchain: blockchain}
    end

    test "with valid parameter", %{blockchain: %{id: id, name: name}} do
      {:ok, %Blockchain{id: ^id, name: ^name}} = Blockchains.retrieve_by(name: name)
    end

    test "with non existing parameter", %{invalid_name: name} do
      {:error, :not_found} = Blockchains.retrieve_by(name: name)
    end
  end

  describe "update/1" do
    setup %{blockchain: blockchain_data} do
      {:ok, blockchain} = Blockchains.create(blockchain_data)
      %{blockchain: blockchain}
    end

    test "with invalid id", %{invalid_id: id, updated_name: updated_name} do
      {:error, :not_found} = Blockchains.update(id, %{name: updated_name})
    end

    test "with non existing id", %{invalid_id: id, updated_name: updated_name} do
      {:error, :not_found} = Blockchains.update(id, %{name: updated_name})
    end

    test "with valid params", %{
      blockchain: %Blockchain{id: id},
      updated_name: updated_name
    } do
      {:ok, %Blockchain{id: ^id, name: ^updated_name}} =
        Blockchains.update(id, %{name: updated_name})
    end

    test "with blank required fields", %{blockchain: %Blockchain{id: id}} do
      {:error, changeset} = Blockchains.update(id, %{name: ""})
      %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "with existing name", %{blockchain: %Blockchain{id: id}, updated_name: updated_name} do
      {:ok, _blockchain} = Blockchains.create(%{name: updated_name})

      {:error, changeset} = Blockchains.update(id, %{name: updated_name})
      %{name: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "update_by_name/2" do
    setup %{blockchain: blockchain_data} do
      {:ok, blockchain} = Blockchains.create(blockchain_data)
      %{blockchain: blockchain}
    end

    test "with valid params", %{blockchain: %Blockchain{name: name}, updated_name: updated_name} do
      {:ok, %Blockchain{name: ^updated_name}} =
        Blockchains.update_by_name(name, %{name: updated_name})
    end

    test "with non existing name", %{invalid_name: invalid_name, updated_name: updated_name} do
      {:error, :not_found} = Blockchains.update_by_name(invalid_name, %{name: updated_name})
    end
  end
end
