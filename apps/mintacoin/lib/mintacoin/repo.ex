defmodule Mintacoin.Repo do
  use Ecto.Repo,
    otp_app: :mintacoin,
    adapter: Ecto.Adapters.Postgres
end
