defmodule MintacoinWeb.Utils.RequestParams do
  @moduledoc """
  This module provides formats and transformations
  for the resources' parameters.
  """

  @type params :: map()
  @type resource :: atom()

  @allowed_params [
    accounts: ~w(email name)
  ]

  @spec fetch_allowed(params :: params(), resource :: resource()) :: params()
  def fetch_allowed(params, resource) do
    @allowed_params
    |> Keyword.get(resource, [])
    |> (&Map.take(params, &1)).()
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      key
      |> String.to_existing_atom()
      |> (&Map.put(acc, &1, value)).()
    end)
  rescue
    Protocol.UndefinedError -> %{}
  end
end
