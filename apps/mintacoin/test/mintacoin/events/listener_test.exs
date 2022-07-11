defmodule Mintacoin.Events.ListenerTest do
  @moduledoc """

  """

  use ExUnit.Case

  import Mintacoin.Factory

  alias Mintacoin.Events.{Listener, Structs.AccountCreated}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)
    %{pid: self(), blockchain_event: params_for(:blockchain_event)}
  end

  describe "handle_info/2" do
    test "with valid payload", %{
      pid: pid,
      blockchain_event:
        %{event_payload: %{"balance" => balance, "destination" => destination}} = blockchain_event
    } do
      encoded_payload = Jason.encode!(%{operation: "INSERT", record: blockchain_event})

      {:noreply,
       %AccountCreated{
         balance: ^balance,
         destination: ^destination
       }} =
        Listener.handle_info(
          {:notification, pid, "ref", "event_created", encoded_payload},
          []
        )
    end

    test "with empty payload", %{pid: pid, blockchain_event: blockchain_event} do
      blockchain_event = %{blockchain_event | event_payload: %{}}

      encoded_payload = Jason.encode!(%{operation: "INSERT", record: blockchain_event})

      {:noreply, %AccountCreated{balance: nil, destination: nil}} =
        Listener.handle_info(
          {:notification, pid, "ref", "event_created", encoded_payload},
          []
        )
    end
  end

  test "Assert notification received in handle_info", %{
    pid: pid,
    blockchain_event: blockchain_event
  } do
    encoded_payload = Jason.encode!(%{operation: "INSERT", record: blockchain_event})

    send(
      pid,
      {:notification, pid, "ref", "event_created", encoded_payload}
    )

    assert_receive({:notification, ^pid, "ref", "event_created", ^encoded_payload})
  end
end
