defmodule Mintacoin.Minters.MinterToken do
  @moduledoc """
  The MinterToken context.
  """

  use Ecto.Schema
  import Ecto.Query
  alias Mintacoin.Minters.{MinterToken, Minter}

  @type t :: %__MODULE__{}

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "minters_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    belongs_to :minter, Minter

    timestamps(updated_at: false)
  end

  @doc false
  @spec build_session_token(minter :: t()) :: tuple()
  def build_session_token(minter) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %MinterToken{token: token, context: "session", minter_id: minter.id}}
  end

  @doc false
  @spec verify_session_token_query(token :: String.t()) :: tuple()
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: minter in assoc(token, :minter),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: minter

    {:ok, query}
  end

  @doc false
  @spec build_email_token(minter :: t(), context :: String.t()) :: map()
  def build_email_token(minter, context) do
    build_hashed_token(minter, context, minter.email)
  end

  defp build_hashed_token(minter, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %MinterToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       minter_id: minter.id
     }}
  end

  @doc false
  @spec verify_email_token_query(token :: String.t(), context :: String.t()) :: tuple() | :error
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in token_and_context_query(hashed_token, context),
            join: minter in assoc(token, :minter),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == minter.email,
            select: minter

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc false
  @spec verify_change_email_token_query(token :: String.t(), context :: String.t()) ::
          tuple() | :error
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  @spec token_and_context_query(token :: String.t(), context :: String.t()) :: struct()
  def token_and_context_query(token, context) do
    from MinterToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given minter for the given contexts.
  """
  @spec minter_and_contexts_query(minter :: t(), contexts :: atom()) :: list(struct())
  def minter_and_contexts_query(minter, :all) do
    from t in MinterToken, where: t.minter_id == ^minter.id
  end

  @spec minter_and_contexts_query(minter :: t(), contexts :: list()) :: list(struct())
  def minter_and_contexts_query(minter, [_ | _] = contexts) do
    from t in MinterToken, where: t.minter_id == ^minter.id and t.context in ^contexts
  end
end
