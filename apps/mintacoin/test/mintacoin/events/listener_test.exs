defmodule Mintacoin.Events.ListenerTest do
  @moduledoc """
  This module defines the test cases for the `Listener` GenServer module.
  """

  use ExUnit.Case

  import Mintacoin.Factory
  import Mock

  alias Mintacoin.Events.{Listener, Consumer}
  alias Mintacoin.BlockchainEvent
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)
    %{pid: self(), blockchain_event: params_for(:blockchain_event)}
  end

  test "handle_info/2", %{
    pid: pid,
    blockchain_event:
      %{event_payload: %{"balance" => balance, "destination" => destination}} = blockchain_event
  } do
    with_mock Consumer, consumer_functions() do
      encoded_payload = Jason.encode!(%{operation: "INSERT", record: blockchain_event})

      {:noreply, %BlockchainEvent{event_payload: %{balance: ^balance, destination: ^destination}}} =
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

  def consumer_functions do
    [
      create_account: fn blockchain_event -> blockchain_event end
    ]
  end
end
