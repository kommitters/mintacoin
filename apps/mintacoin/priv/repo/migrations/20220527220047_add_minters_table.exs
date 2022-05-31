defmodule Mintacoin.Repo.Migrations.AddMintersTable do
  use Ecto.Migration

  def change do
    create table(:minters, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:email, :string, null: false, unique: true)
      add(:name, :string)
      add(:status, :string, null: false)
      add(:api_key, :string, null: false, unique: true)

      timestamps()
    end

    create(unique_index(:minters, [:email]))
    create(unique_index(:minters, [:api_key]))
  end
end
