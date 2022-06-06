defmodule MintacoinWeb.ChangesetView do
  use MintacoinWeb, :view

  alias Ecto.Changeset

  @type template :: String.t()
  @type formatted_error() :: map()

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `MintacoinWeb.ErrorHelpers.translate_error/1` for more details.
  """
  @spec translate_errors(changeset :: Changeset.t()) :: formatted_error()
  def translate_errors(changeset), do: Changeset.traverse_errors(changeset, &translate_error/1)

  @spec render(template :: template(), changeset :: Changeset.t()) :: formatted_error()
  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end
end
