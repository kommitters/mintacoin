defmodule Mintacoin.Events.Structs.AccountCreated do
  @moduledoc """
  `AccountCreated` event struct definition.
  """

  @type t :: %__MODULE__{
          destination: String.t(),
          balance: number()
        }

  defstruct [:destination, :balance]
end
