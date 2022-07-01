defmodule Mintacoin.Crypto.TxResponse do
  @moduledoc """
  `TxResponse` struct definition
  """

  @type t :: %__MODULE__{
          successful: boolean(),
          hash: String.t(),
          created_at: Date.t(),
          blockchain: atom(),
          tx_json: map()
        }

  defstruct [
    :successful,
    :hash,
    :created_at,
    :blockchain,
    :tx_json
  ]
end
