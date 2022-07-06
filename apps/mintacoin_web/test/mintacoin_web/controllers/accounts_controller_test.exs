defmodule MintacoinWeb.AccountsControllerTest do
  use MintacoinWeb.ConnCase

  import Mintacoin.Factory

  alias Mintacoin.{Minter, Encryption, Mnemonic, Keypair, Account}

  @auth_header "authorization"

  setup %{conn: conn} do
    %Minter{api_key: api_key, email: email} = insert(:minter)
    %Account{signature: signature} = insert(:account, email: email)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header(@auth_header, "Bearer #{api_key}")

    %{
      create_attrs: %{"name" => "Test Name", "email" => "test@mail.com", "signature" => signature},
      update_attrs: %{"name" => "Updated Test Name", "email" => "updatedtest@mail.com"},
      invalid_attrs: %{},
      invalid_attrs_with_signature: %{"signature" => signature},
      non_existing_address: "78f0eb93-4466-451c-b3e7-5c6189500919",
      conn: conn
    }
  end

  describe "create account" do
    test "returns bad request response when signature is invalid", %{
      conn: conn,
      invalid_attrs: invalid_attrs
    } do
      conn = post(conn, Routes.accounts_path(conn, :create), invalid_attrs)

      %{"detail" => "Bad Request"} = json_response(conn, 400)["errors"]
    end

    test "returns account when data is valid", %{conn: conn, create_attrs: create_attrs} do
      conn = post(conn, Routes.accounts_path(conn, :create), create_attrs)
      %{"address" => address} = json_response(conn, 201)

      conn = get(conn, Routes.accounts_path(conn, :show, address))
      %{"address" => ^address} = json_response(conn, 200)
    end

    test "returns errors when data is invalid", %{
      conn: conn,
      invalid_attrs_with_signature: invalid_attrs_with_signature
    } do
      conn = post(conn, Routes.accounts_path(conn, :create), invalid_attrs_with_signature)

      %{"email" => ["can't be blank"], "name" => ["can't be blank"]} =
        json_response(conn, 422)["errors"]
    end
  end

  describe "retrieve account" do
    setup [:create_account]

    test "returns account when address exists", %{
      conn: conn,
      account: %{address: address}
    } do
      conn = get(conn, Routes.accounts_path(conn, :show, address))
      %{"address" => ^address} = json_response(conn, 200)
    end

    test "returns not found response when address doesn't exist", %{
      conn: conn,
      non_existing_address: non_existing_address
    } do
      conn = get(conn, Routes.accounts_path(conn, :show, non_existing_address))
      assert response(conn, 404)
    end
  end

  describe "update account" do
    setup [:create_account]

    test "returns updated account when data is valid", %{
      conn: conn,
      update_attrs: %{"name" => update_name, "email" => update_email} = update_attrs,
      account: %{address: address}
    } do
      conn = put(conn, Routes.accounts_path(conn, :update, address), update_attrs)
      assert %{"address" => ^address} = json_response(conn, 200)

      conn = get(conn, Routes.accounts_path(conn, :show, address))

      %{"address" => ^address, "name" => ^update_name, "email" => ^update_email} =
        json_response(conn, 200)
    end

    test "returns not found response when account's address doesn't exist", %{
      conn: conn,
      non_existing_address: non_existing_address,
      update_attrs: update_attrs
    } do
      conn = put(conn, Routes.accounts_path(conn, :update, non_existing_address), update_attrs)
      assert response(conn, 404)
    end
  end

  describe "delete account" do
    setup [:create_account]

    test "deletes account with given address", %{conn: conn, account: %{address: address}} do
      conn = delete(conn, Routes.accounts_path(conn, :delete, address))
      %{"address" => ^address, "status" => "archived"} = json_response(conn, 200)

      conn = get(conn, Routes.accounts_path(conn, :show, address))
      assert response(conn, 404)
    end

    test "returns not found response when account's address doesn't exist", %{
      conn: conn,
      non_existing_address: non_existing_address
    } do
      conn = delete(conn, Routes.accounts_path(conn, :delete, non_existing_address))
      assert response(conn, 404)
    end
  end

  describe "recover account signature" do
    setup [:create_account]

    test "returns signature when seed words are valid", %{
      conn: conn,
      account: %{address: address, signature: signature, seed_words: seed_words}
    } do
      conn = post(conn, Routes.accounts_path(conn, :recover, address), %{seed_words: seed_words})
      %{"signature" => ^signature} = json_response(conn, 200)
    end

    test "returns bad request response when seed words are invalid", %{
      conn: conn,
      account: %{address: address}
    } do
      conn =
        post(conn, Routes.accounts_path(conn, :recover, address), %{seed_words: ["seed", "words"]})

      assert response(conn, 400)
    end

    test "returns not found response when account's address doesn't exist", %{
      conn: conn,
      non_existing_address: non_existing_address,
      account: %{seed_words: seed_words}
    } do
      conn =
        post(
          conn,
          Routes.accounts_path(conn, :recover, non_existing_address, %{seed_words: seed_words})
        )

      assert response(conn, 404)
    end
  end

  defp create_account(_conn) do
    {:ok, {entropy, seed_words}} = Mnemonic.random_entropy_and_mnemonic()
    {:ok, {derived_key, signature}} = Keypair.random()
    {:ok, encrypted_signature} = Encryption.encrypt(signature, entropy)

    account =
      insert(:account,
        derived_key: derived_key,
        signature: signature,
        encrypted_signature: encrypted_signature,
        seed_words: seed_words
      )

    %{account: account}
  end
end
