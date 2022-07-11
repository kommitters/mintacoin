defmodule Mintacoin.Events.ListenerTest do
  @moduledoc """

  """

  use ExUnit.Case

  import Mintacoin.Factory

  alias Mintacoin.Events.{Listener, Structs.AccountCreated}
  alias Ecto.Adapters.SQL.Sandbox

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)

    %{pid: self()}
  end

  describe "handle_info/2" do
    test "with valid payload", %{pid: pid} do
      %{event_payload: %{"balance" => balance, "destination" => destination}} =
        blockchain_event =
        :blockchain_event
        |> params_for()

      encoded_blockchain_event = Jason.encode!(blockchain_event)

      {:noreply,
       %AccountCreated{
         balance: ^balance,
         destination: ^destination
       }} =
        Listener.handle_info(
          {:notification, pid, "ref", "event_created", encoded_blockchain_event},
          []
        )
    end

    test "with empty payload", %{pid: pid} do
      blockchain_event =
        :blockchain_event
        |> params_for(event_payload: %{})
        |> Jason.encode!()

      {:noreply, %AccountCreated{balance: nil, destination: nil}} =
        Listener.handle_info(
          {:notification, pid, "ref", "event_created", blockchain_event},
          []
        )
    end
  end

  test "Assert notification received in handle_info", %{pid: pid} do
    blockchain_event =
      :blockchain_event
      |> params_for()
      |> Jason.encode!()

    Process.send(
      pid,
      {:notification, pid, "ref", "event_created", blockchain_event},
      []
    )

    assert_receive({:notification, ^pid, "ref", "event_created", ^blockchain_event})
  end
end
