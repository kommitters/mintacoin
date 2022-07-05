defmodule Mintacoin.Repo.Migrations.CreateAssetCreatedNotifier do
  use Ecto.Migration

  def up do
    execute("""
    -- NOTIFY FUNCTION notify_asset_creation

    CREATE OR REPLACE FUNCTION notify_asset_creation()
      RETURNS trigger
      LANGUAGE 'plpgsql'
      NOT LEAKPROOF
    AS $BODY$
    BEGIN
      PERFORM pg_notify(
        'asset_created',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );

      RETURN NEW;
    END;
    $BODY$;
    """)

    execute("DROP TRIGGER IF EXISTS asset_inserted ON accounts;")

    execute("""
    -- TRIGGER asset_inserted

    CREATE TRIGGER asset_inserted
      AFTER INSERT
      ON assets
      FOR EACH ROW
      EXECUTE PROCEDURE notify_asset_creation()
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS asset_inserted ON payments;")
    execute("DROP FUNCTION IF EXISTS notify_asset_creation;")
  end
end
