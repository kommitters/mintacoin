defmodule Mintacoin.Blockchains.Network.Spec do
  @moduledoc """
  Specifies the functions available for the Blockchain Network implementations.
  """

  alias Mintacoin.Blockchain

  @callback name() :: String.t()

  @callback struct() :: Blockchain.t()
end
