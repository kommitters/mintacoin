defmodule MintacoinWeb.RequestParams do
  @moduledoc """
  This module provides formats and transformations
  for the controllers parameters.
  """

  @type params :: map()
  @type controller :: atom()

  @allowed_params %{
    accounts: ~w(email name)
  }

  @spec fetch_allowed(params :: params(), controller :: controller()) :: params()
  def fetch_allowed(params, controller) do
    params
    |> Map.take(@allowed_params[controller])
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      key
      |> String.to_existing_atom()
      |> (&Map.put(acc, &1, value)).()
    end)
  rescue
    Protocol.UndefinedError -> %{}
  end
end
