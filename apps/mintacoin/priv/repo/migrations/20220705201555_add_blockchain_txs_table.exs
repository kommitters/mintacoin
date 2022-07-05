defmodule Mintacoin.Repo.Migrations.AddBlockchainTxsTable do
  use Ecto.Migration

  def change do
    create table(:blockchain_txs, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:blockchain_id, references(:blockchains, type: :uuid), null: false)
      add(:operation_type, :string)
      add(:operation_payload, :map)
      add(:signatures, {:array, :string})
      add(:state, :string)
      add(:successful, :boolean)
      add(:tx_id, :string)
      add(:tx_hash, :string)
      add(:tx_response, :map)

      timestamps()
    end
  end
end
