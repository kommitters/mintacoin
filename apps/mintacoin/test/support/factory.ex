defmodule Mintacoin.Factory do
  @moduledoc """
    This module is responsible of managing factories.
  """
  use ExMachina.Ecto, repo: Mintacoin.Repo

  use Mintacoin.{
    MinterFactory,
    AccountFactory,
    AssetFactory,
    BlockchainFactory,
    PaymentFactory,
    BlockchainEventFactory,
    WalletFactory
  }
end
