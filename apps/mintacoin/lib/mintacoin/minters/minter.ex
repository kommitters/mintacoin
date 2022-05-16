defmodule Mintacoin.Minters.Minter do
  @moduledoc """
  The Minter context.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "minters" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc """
  A minter changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  @spec registration_changeset(minter :: t(), changeset :: map(), options :: list()) ::
          Ecto.Changeset.t()
  def registration_changeset(minter, attrs, opts \\ []) do
    minter
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password(opts)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Mintacoin.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A minter changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  @spec email_changeset(minter :: t(), changeset :: map()) :: Ecto.Changeset.t()
  def email_changeset(minter, attrs) do
    minter
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A minter changeset for changing the password.

  ## Options

  * `:hash_password` - Hashes the password so it can be stored securely
  in the database and ensures the password field is cleared to prevent
  leaks in the logs. If password hashing is not needed and clearing the
  password field is not desired (like when using this changeset for
  validations on a LiveView form), this option can be set to `false`.
  Defaults to `true`.
  """
  @spec password_changeset(minter :: t(), changeset :: map(), options :: list()) ::
          Ecto.Changeset.t()
  def password_changeset(minter, attrs, opts \\ []) do
    minter
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  @spec confirm_changeset(minter :: t()) :: Ecto.Changeset.t()
  def confirm_changeset(minter) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(minter, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no minter or the minter doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  @spec valid_password?(minter :: t(), password :: String.t()) :: boolean()
  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  @spec valid_password?(minter :: any(), password :: any()) :: false
  def valid_password?(_minter, _password) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  @spec validate_current_password(changeset :: Ecto.Changeset.t(), password :: String.t()) :: Ecto.Changeset.t()
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
