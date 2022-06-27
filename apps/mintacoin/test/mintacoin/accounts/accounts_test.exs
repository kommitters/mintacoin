defmodule Mintacoin.Accounts.AccountsTest do
  @moduledoc """
    This module is used to group common tests for Accounts functions
  """

  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 1, insert: 2]

  alias Mintacoin.{Account, Accounts}
  alias Ecto.Adapters.SQL.Sandbox

  @active_status :active
  @archived_status :archived

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)

    %{
      invalid_id: "8dd3eaa3-c073-46f6-8e20-72c7f7203146",
      invalid_address: "INVALID_ADDRESS",
      invalid_email: "INVALID_EMAIL"
    }
  end

  describe "create/1" do
    setup do
      %{
        account: %{
          email: "account@mail.com",
          name: "Account name"
        }
      }
    end

    test "with valid params", %{account: %{email: email, name: name} = account_data} do
      {:ok,
       %Account{
         id: id,
         address: address,
         derived_key: derived_key,
         encrypted_signature: encrypted_signature,
         signature: signature,
         seed_words: seed_words,
         status: status,
         email: ^email,
         name: ^name
       }} = Accounts.create(account_data)

      assert is_binary(id)
      assert is_binary(address)
      assert is_binary(derived_key)
      assert is_binary(encrypted_signature)
      assert is_binary(signature)
      assert is_binary(seed_words)
      @active_status = status
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
    test "with valid address" do
      %Account{address: address, email: email, name: name} = insert(:account)
      {:ok, %Account{email: ^email, name: ^name}} = Accounts.retrieve(address)
    end

    test "with archived account" do
      %Account{address: address, status: @archived_status} =
        insert(:account, status: @archived_status)

      {:error, :not_found} = Accounts.retrieve(address)
    end

    test "with non existing address", %{invalid_id: invalid_id, invalid_address: invalid_address} do
      {:error, :not_found} = Accounts.retrieve(invalid_id)
      {:error, :not_found} = Accounts.retrieve(invalid_address)
      {:error, :not_found} = Accounts.retrieve(1)
    end
  end

  describe "retrieve_by/1" do
    test "with valid parameter" do
      %Account{id: id, email: email} = insert(:account)

      {:ok, %Account{id: ^id, email: ^email, seed_words: nil, signature: nil}} =
        Accounts.retrieve_by(email: email)
    end

    test "with non existing parameter", %{invalid_email: invalid_email} do
      {:error, :not_found} = Accounts.retrieve_by(email: invalid_email)
    end

    test "with bad argument" do
      {:error, :bad_argument} = Accounts.retrieve_by(1)
    end
  end

  describe "update/1" do
    setup do
      %{
        account: insert(:account),
        valid_attrs: %{name: "Another name"},
        invalid_attrs: %{name: "", email: ""}
      }
    end

    test "with valid params", %{
      account: %Account{id: id, address: address},
      valid_attrs: %{name: name} = valid_attrs
    } do
      {:ok, %Account{id: ^id, address: ^address, name: ^name}} =
        Accounts.update(address, valid_attrs)
    end

    test "with blank required fields", %{
      account: %Account{address: address},
      invalid_attrs: invalid_attrs
    } do
      {:error, changeset} = Accounts.update(address, invalid_attrs)
      %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "with existing email", %{account: %Account{address: address}} do
      %Account{email: email} = insert(:account)

      {:error, changeset} = Accounts.update(address, %{email: email})
      %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "with wrong email format", %{
      account: %Account{address: address},
      invalid_email: invalid_email
    } do
      {:error, changeset} = Accounts.update(address, %{email: invalid_email})
      %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end
  end

  describe "delete/1" do
    test "with valid address" do
      %Account{address: address, status: @active_status} = insert(:account)
      {:ok, %Account{address: ^address, status: @archived_status}} = Accounts.delete(address)
    end

    test "with non existing id and address", %{
      invalid_id: invalid_id,
      invalid_address: invalid_address
    } do
      {:error, :not_found} = Accounts.delete(invalid_id)
      {:error, :not_found} = Accounts.delete(invalid_address)
      {:error, :not_found} = Accounts.delete(1)
    end
  end

  describe "recover_signature/2" do
    test "should return signature" do
      %Account{address: address, seed_words: seed_words, signature: signature} = insert(:account)

      {:ok, ^signature} = Accounts.recover_signature(address, seed_words)
    end
  end
end
