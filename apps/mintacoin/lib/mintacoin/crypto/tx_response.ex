defmodule Mintacoin.Crypto.TxResponse do
  @moduledoc """
  `TxResponse` struct definition
  """

  @type t :: %__MODULE__{
          successful: boolean(),
          id: String.t(),
          hash: String.t(),
          created_at: DateTime.t(),
          blockchain: atom(),
          raw_tx: map()
        }

  defstruct [
    :successful,
    :id,
    :hash,
    :created_at,
    :blockchain,
    :raw_tx
  ]
end
