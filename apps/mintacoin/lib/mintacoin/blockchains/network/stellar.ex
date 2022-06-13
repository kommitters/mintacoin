defmodule Mintacoin.Blockchains.Network.Stellar do
  @moduledoc """
  This module is the Stellar implementation of the Blockchain Network module.
  """

  @behaviour Mintacoin.Blockchains.Network.Spec

  alias Mintacoin.Blockchains

  @impl true
  def name, do: "Stellar"

  @impl true
  def struct do
    {:ok, blockchain} = Blockchains.retrieve_by(name: name())
    blockchain
  end
end
