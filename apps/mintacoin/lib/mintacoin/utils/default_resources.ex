defmodule Mintacoin.Utils.DefaultResources do
  @moduledoc """
  This module provides default resources.
  """

  alias Mintacoin.{Blockchain, Blockchains}

  @default_blockchain "Stellar"

  @spec blockchain() :: Blockchain.t()
  def blockchain do
    {:ok, blockchain} = Blockchains.retrieve_by(name: @default_blockchain)
    blockchain
  end
end
