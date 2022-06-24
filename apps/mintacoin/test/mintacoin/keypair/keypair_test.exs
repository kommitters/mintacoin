defmodule Mintacoin.Keypair.CannedKeypairImpl do
  @moduledoc """
  This modules defines the canned implementation for `Keypair`
  """

  @behaviour Mintacoin.Keypair.Spec

  @impl true
  def random do
    send(self(), {:random, "KEYPAIR"})
    :ok
  end

  @impl true
  def from_secret_key(_secret_key) do
    send(self(), {:from_secret_key, "KEYPAIR"})

    {:ok, "30MGLHU1OGC23O06RFSHSA5325O49V05UEFA81FMN8JHV0AUVKG0",
     "0Qmk3ZinGhZLuIMJC2j/WNN+scV3MMLxkI5ALlAVun8"}
  end
end

defmodule Mintacoin.KeypairTest do
  @moduledoc """
  This modules defines the test cases of the `Keypair` abstraction module.
  """

  use ExUnit.Case

  alias Mintacoin.Keypair.CannedKeypairImpl

  setup do
    Application.put_env(:keypair, :impl, CannedKeypairImpl)

    on_exit(fn ->
      Application.delete_env(:keypair, :impl)
    end)
  end

  test "random/0" do
    Mintacoin.Keypair.random()
    assert_receive({:random, "KEYPAIR"})
  end

  test "from_secret_key/1" do
    Mintacoin.Keypair.from_secret_key("PUBLIC_KEY")
    assert_receive({:from_secret_key, "KEYPAIR"})
  end
end
