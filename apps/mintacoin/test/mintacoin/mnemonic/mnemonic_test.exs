defmodule Mintacoin.Mnemonic.CannedMnemonicImpl do
  @moduledoc false

  @behaviour Mintacoin.Mnemonic.Spec

  @impl true
  def random_entropy_and_mnemonic do
    send(self(), {:random_entropy_and_mnemonic, "ENTROPY_AND_SEED_WORDS"})
    :ok
  end

  @impl true
  def to_entropy(_seed_words) do
    send(self(), {:to_entropy, "ENTROPY"})
    :ok
  end

  @impl true
  def from_entropy(_entropy) do
    send(self(), {:from_entropy, "SEED_WORDS"})
    :ok
  end
end

defmodule Mintacoin.MnemonicTest do
  use ExUnit.Case

  alias Mintacoin.Mnemonic.CannedMnemonicImpl

  setup do
    Application.put_env(:mnemonic, :impl, CannedMnemonicImpl)

    on_exit(fn ->
      Application.delete_env(:mnemonic, :impl)
    end)
  end

  test "random_entropy_and_mnemonic/0" do
    Mintacoin.Mnemonic.random_entropy_and_mnemonic()
    assert_receive({:random_entropy_and_mnemonic, "ENTROPY_AND_SEED_WORDS"})
  end

  test "to_entropy/1" do
    Mintacoin.Mnemonic.to_entropy("SEED_WORDS")
    assert_receive({:to_entropy, "ENTROPY"})
  end

  test "from_entropy/1" do
    Mintacoin.Mnemonic.from_entropy("ENTROPY")
    assert_receive({:from_entropy, "SEED_WORDS"})
  end
end
