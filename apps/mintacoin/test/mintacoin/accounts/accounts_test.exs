defmodule Mintacoin.Accounts.AccountsTest do
  @moduledoc """
    This module is used to group common tests for Accounts functions
  """

  use Mintacoin.DataCase, async: false

  alias Mintacoin.{Account, Accounts}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)

    %{
      account: %{
        email: "account@mail.com",
        name: "Account name"
      }
    }
  end

  describe "create/1" do
    test "with valid params", %{account: %{email: email, name: name} = account_data} do
      {:ok, %Account{email: ^email, name: ^name} = account} = Accounts.create(account_data)
      assert is_binary(account.id)
      assert is_binary(account.address)
      assert is_binary(account.derived_key)
      assert is_binary(account.encrypted_signature)
      assert is_binary(account.signature)
      assert is_binary(account.seed_words)
      :active = account.status
    end

    test "with invalid params" do
      {:error, changeset} = Accounts.create(%{})
      %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "with existing account", %{account: account_data} do
      {:ok, _account} = Accounts.create(account_data)
      {:error, changeset} = Accounts.create(account_data)

      %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "retrieve/1" do
    test "with valid address", %{account: %{email: email, name: name} = account_data} do
      {:ok, %Account{address: address}} = Accounts.create(account_data)
      {:ok, %Account{email: ^email, name: ^name}} = Accounts.retrieve(address)
    end

    test "with archived account", %{account: account_data} do
      {:ok, %Account{address: address}} = Accounts.create(account_data)
      {:ok, %Account{address: ^address, status: :archived}} = Accounts.delete(address)

      {:error, :not_found} = Accounts.retrieve(address)
    end

    test "with non existing address" do
      {:error, :not_found} = Accounts.retrieve("8dd3eaa3-c073-46f6-8e20-72c7f7203146")
      {:error, :not_found} = Accounts.retrieve("INVALID_ADDRESS")
      {:error, :not_found} = Accounts.retrieve(1)
    end
  end

  describe "retrieve_by/1" do
    test "with valid parameter", %{account: %{email: email} = account_data} do
      {:ok, %Account{id: id}} = Accounts.create(account_data)

      {:ok, %Account{id: ^id, seed_words: nil, signature: nil}} =
        Accounts.retrieve_by(email: email)
    end

    test "with non existing parameter" do
      {:error, :not_found} = Accounts.retrieve_by(email: "INVALID_EMAIL")
    end

    test "with bad argument" do
      {:error, :bad_argument} = Accounts.retrieve_by(1)
    end
  end

  describe "update/1" do
    test "with valid params", %{account: account_data} do
      {:ok, %Account{id: id, address: address}} = Accounts.create(account_data)

      {:ok, %Account{id: ^id, address: ^address, name: "Another name"}} =
        Accounts.update(address, %{name: "Another name"})
    end

    test "with blank required fields", %{account: account_data} do
      {:ok, %Account{address: address}} = Accounts.create(account_data)
      {:error, changeset} = Accounts.update(address, %{name: "", email: ""})
      %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "with existing email", %{account: account_data} do
      {:ok, %Account{address: address}} = Accounts.create(account_data)

      {:ok, _account} = Accounts.create(%{email: "account0@mail.com", name: "Account 0"})

      {:error, changeset} = Accounts.update(address, %{email: "account0@mail.com"})
      %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "with wrong email format", %{account: account_data} do
      {:ok, %Account{address: address}} = Accounts.create(account_data)
      {:error, changeset} = Accounts.update(address, %{email: "INVALID_EMAIL"})
      %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end
  end

  describe "delete/1" do
    test "with valid address", %{account: account_data} do
      {:ok, %Account{address: address, status: :active}} = Accounts.create(account_data)
      {:ok, %Account{address: ^address, status: :archived}} = Accounts.delete(address)
    end

    test "with non existing address" do
      {:error, :not_found} = Accounts.delete("8dd3eaa3-c073-46f6-8e20-72c7f7203146")
      {:error, :not_found} = Accounts.delete("INVALID_ADDRESS")
      {:error, :not_found} = Accounts.delete(1)
    end
  end

  describe "recover_signature/2" do
    test "should return signature", %{account: account_data} do
      {:ok, %Account{address: address, seed_words: seed_words, signature: signature}} =
        Accounts.create(account_data)

      {:ok, ^signature} = Accounts.recover_signature(address, seed_words)
    end
  end
end
