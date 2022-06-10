defmodule Mintacoin.Repo.Migrations.AddAssetsTable do
  use Ecto.Migration

  def change do
    create table(:assets, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:code, :string, null: false, unique: true)
      add(:supply, :string, null: false)
      add(:blockchain_id, references(:blockchains, type: :uuid), null: false)
      add(:minter_id, references(:minters, type: :uuid), null: false)

      timestamps()
    end

    create unique_index(:assets, [:code])
  end
end
