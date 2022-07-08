defmodule Mintacoin.Core.AccountsTest do
  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 2]

  alias Mintacoin.{Repo, Account, Blockchain, BlockchainEvent, Wallet, Wallets}
  alias Mintacoin.Core.Accounts, as: CoreAccounts
  alias Ecto.{Adapters.SQL.Sandbox, Query}

  setup do
    :ok = Sandbox.checkout(Repo)

    %Blockchain{id: blockchain_id} = insert(:blockchain, name: "Stellar")

    %{
      valid_params: %{
        email: "account@example.com",
        name: "Account name",
        blockchain: "Stellar"
      },
      invalid_params: %{
        empty_fields: %{
          email: "",
          name: "",
          blockchain: ""
        },
        invalid_blockchain: %{
          email: "account@example.com",
          name: "Account name",
          blockchain: "invalid_blockchain"
        }
      },
      blockchain_id: blockchain_id
    }
  end

  describe "create/1" do
    test "with valid params", %{
      valid_params:
        %{
          email: email,
          name: name
        } = valid_params,
      blockchain_id: blockchain_id
    } do
      # Create account from Core
      {:ok, %Account{id: account_id, email: ^email, name: ^name}} =
        CoreAccounts.create(valid_params)

      # Verify Wallet creation
      {:ok, %Wallet{address: destination}} =
        Wallets.retrieve_by_account_and_blockchain(account_id, blockchain_id)

      # Verify BlockchainEvent creation, and event_payload matching
      %BlockchainEvent{
        event_payload: %{
          "destination" => ^destination,
          "balance" => 1.5
        }
      } = BlockchainEvent |> Query.last(:inserted_at) |> Repo.one!()
    end

    test "create_account_step fails because of blank email and name", %{
      invalid_params: %{
        empty_fields: invalid_params
      }
    } do
      {:error, changeset} = CoreAccounts.create(invalid_params)
      %{email: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_account_step fails because email has already been taken", %{
      valid_params: valid_params
    } do
      {:ok, %Account{}} = CoreAccounts.create(valid_params)
      {:error, changeset} = CoreAccounts.create(valid_params)
      %{email: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_wallet_step fails because of invalid blockchain name", %{
      invalid_params: %{
        invalid_blockchain: invalid_params
      }
    } do
      {:error, :blockchain_not_found} = CoreAccounts.create(invalid_params)
    end
  end
end
