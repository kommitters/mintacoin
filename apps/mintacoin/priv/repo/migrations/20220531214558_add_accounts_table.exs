defmodule Mintacoin.Repo.Migrations.AddAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string, null: false, unique: true)
      add(:name, :string)
      add(:address, :uuid, unique: true)
      add(:derived_key, :string, null: false)
      add(:encrypted_signature, :string, null: false)
      add(:status, :string, null: false)

      timestamps()
    end

    create unique_index(:accounts, [:email])
    create unique_index(:accounts, [:encrypted_signature])
    create unique_index(:accounts, [:address])
  end
end
