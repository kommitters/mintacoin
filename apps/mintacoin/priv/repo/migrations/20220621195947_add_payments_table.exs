defmodule Mintacoin.Repo.Migrations.AddPaymentsTable do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:source, references(:accounts, column: :address, type: :uuid), null: false)
      add(:destination, references(:accounts, column: :address, type: :uuid), null: false)
      add(:asset_code, references(:assets, column: :code, type: :string), null: false)
      add(:amount, :string, null: false)
      add(:status, :string, null: false)

      timestamps()
    end
  end
end
