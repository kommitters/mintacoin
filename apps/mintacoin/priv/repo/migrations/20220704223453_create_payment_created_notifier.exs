defmodule Mintacoin.Repo.Migrations.CreatePaymentCreatedNotifier do
  use Ecto.Migration

  def up do
    execute("""
    -- NOTIFY FUNCTION notify_payment_creation

    CREATE OR REPLACE FUNCTION notify_payment_creation()
      RETURNS trigger
      LANGUAGE 'plpgsql'
      NOT LEAKPROOF
    AS $BODY$
    BEGIN
      PERFORM pg_notify(
        'payment_created',
        json_build_object(
          'operation', TG_OP,
          'record', row_to_json(NEW)
        )::text
      );

      RETURN NEW;
    END;
    $BODY$;
    """)

    execute("DROP TRIGGER IF EXISTS payment_inserted ON accounts;")

    execute("""
    -- TRIGGER payment_inserted

    CREATE TRIGGER payment_inserted
      AFTER INSERT
      ON payments
      FOR EACH ROW
      EXECUTE PROCEDURE notify_payment_creation()
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS payment_inserted ON payments;")
    execute("DROP FUNCTION IF EXISTS notify_payment_creation;")
  end
end
