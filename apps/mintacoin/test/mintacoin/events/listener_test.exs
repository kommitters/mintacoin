defmodule Mintacoin.Events.ListenerTest do
  @moduledoc """
  This module defines the test cases for the `Listener` GenServer module.
  """

  use ExUnit.Case

  import Mintacoin.Factory

  alias Mintacoin.{Wallet, BlockchainEvent, Events.Listener}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)

    blockchain = insert(:blockchain, name: "Stellar")

    %Wallet{address: destination} = insert(:wallet, blockchain: blockchain)

    blockchain_event =
      insert(:blockchain_event,
        event_type: :create_account,
        event_payload: %{balance: 1.5, destination: destination},
        blockchain: blockchain
      )

    %{
      pid: self(),
      blockchain_event: blockchain_event
    }
  end

  test "handle_info/2", %{
    pid: pid,
    blockchain_event:
      %{event_payload: %{balance: balance, destination: destination}} = blockchain_event
  } do
    encoded_payload =
      blockchain_event
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Map.delete(:blockchain)
      |> (&Jason.encode!(%{operation: "INSERT", record: &1})).()

    {:noreply,
     {:ok,
      %BlockchainEvent{event_payload: %{"balance" => ^balance, "destination" => ^destination}}}} =
      Listener.handle_info(
        {:notification, pid, "ref", "event_created", encoded_payload},
        []
      )
  end

  test "Assert notification received in handle_info", %{
    pid: pid,
    blockchain_event: blockchain_event
  } do
    encoded_payload =
      blockchain_event
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Map.delete(:blockchain)
      |> (&Jason.encode!(%{operation: "INSERT", record: &1})).()

    send(
      pid,
      {:notification, pid, "ref", "event_created", encoded_payload}
    )

    assert_receive({:notification, ^pid, "ref", "event_created", ^encoded_payload})
  end
end
