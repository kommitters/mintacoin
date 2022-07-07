defmodule Mintacoin.Repo.Migrations.AddWalletsTable do
  use Ecto.Migration

  def change do
    create table(:wallets, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:address, :string, null: false)
      add(:encrypted_secret, :string, null: false)
      add(:settled_in_blockchain, :boolean, null: false)
      add(:account_id, references(:accounts, type: :uuid), null: false)
      add(:blockchain_id, references(:blockchains, type: :uuid), null: false)
      add(:blockchain_event_id, references(:blockchain_events, type: :uuid), null: true)

      timestamps()
    end

    create(unique_index(:wallets, [:account_id, :blockchain_id], name: :account_blockchain_index))
  end
end
