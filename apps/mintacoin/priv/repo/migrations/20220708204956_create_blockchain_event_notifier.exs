defmodule Mintacoin.Repo.Migrations.CreateBlockchainEventNotifier do
  use Ecto.Migration

  def up do
    execute("""
    -- NOTIFY FUNCTION notify_event_creation

    CREATE OR REPLACE FUNCTION notify_event_creation()
      RETURNS trigger
      LANGUAGE 'plpgsql'
      NOT LEAKPROOF
    AS $BODY$
    BEGIN
      PERFORM pg_notify(
        'event_created',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );

      RETURN NEW;
    END;
    $BODY$;
    """)

    execute("DROP TRIGGER IF EXISTS event_inserted ON blockchain_events;")

    execute("""
    -- TRIGGER event_inserted

    CREATE TRIGGER event_inserted
      AFTER INSERT
      ON blockchain_events
      FOR EACH ROW
      EXECUTE PROCEDURE notify_event_creation()
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS event_inserted ON blockchain_events;")
    execute("DROP FUNCTION IF EXISTS notify_event_creation;")
  end
end
