defmodule Mintacoin.MinterFactory do
  @moduledoc """
  Allow the creation of minters while testing.
  """

  alias Mintacoin.Minter
  alias Ecto.UUID

  defmacro __using__(_opts) do
    quote do
      @spec minter_factory(attrs :: map()) :: Minter.t()
      def minter_factory(attrs) do
        email = Map.get(attrs, :email, sequence(:email, &"minter#{&1}@example.com"))
        name = Map.get(attrs, :name, sequence(:name, &"Minter #{&1}"))
        status = Map.get(attrs, :status, :active)

        api_key =
          Map.get(
            attrs,
            :api_key,
            sequence(:api_key, &"YtLqThNwJ4ABhrOimcvzhXHd+xKcD0nZ/zrIzSpu52#{&1}")
          )

        %Minter{
          id: UUID.generate(),
          email: email,
          name: name,
          status: status,
          api_key: api_key
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end
