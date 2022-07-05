defmodule Mintacoin.Repo.Migrations.CreateUserCreatedNotifier do
  use Ecto.Migration

  def up do
    execute("""
    -- NOTIFY FUNCTION notify_user_creation

    CREATE OR REPLACE FUNCTION notify_user_creation()
      RETURNS trigger
      LANGUAGE 'plpgsql'
      NOT LEAKPROOF
    AS $BODY$
    BEGIN
      PERFORM pg_notify(
        'account_created',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );

      RETURN NEW;
    END;
    $BODY$;
    """)

    execute("DROP TRIGGER IF EXISTS account_inserted ON accounts;")

    execute("""
    -- TRIGGER account_inserted

    CREATE TRIGGER account_inserted
      AFTER INSERT
      ON accounts
      FOR EACH ROW
      EXECUTE PROCEDURE notify_user_creation()
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS account_inserted ON accounts;")
    execute("DROP FUNCTION IF EXISTS notify_user_creation;")
  end
end
