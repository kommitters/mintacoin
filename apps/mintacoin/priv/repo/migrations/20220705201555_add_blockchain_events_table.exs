defmodule Mintacoin.Repo.Migrations.AddBlockchainEventsTable do
  use Ecto.Migration

  def change do
    create table(:blockchain_events, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:blockchain_id, references(:blockchains, type: :uuid), null: false)
      add(:event_type, :string)
      add(:event_payload, :map)
      add(:state, :string)
      add(:successful, :boolean)
      add(:tx_id, :string)
      add(:tx_hash, :string)
      add(:tx_response, :map)

      timestamps()
    end
  end
end
