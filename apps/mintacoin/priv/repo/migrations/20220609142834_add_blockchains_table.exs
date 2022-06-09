defmodule Mintacoin.Repo.Migrations.AddBlockchainsTable do
  use Ecto.Migration

  def change do
    create table(:blockchains, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false, unique: true)

      timestamps()
    end

    create unique_index(:blockchains, [:name])
  end
end
