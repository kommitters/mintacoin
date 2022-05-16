defmodule Mintacoin.Repo.Migrations.CreateMintersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:minters) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:minters, [:email])

    create table(:minters_tokens) do
      add :minter_id, references(:minters, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:minters_tokens, [:minter_id])
    create unique_index(:minters_tokens, [:context, :token])
  end
end
