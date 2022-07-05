defmodule Mintacoin.Repo do
  use Ecto.Repo,
    otp_app: :mintacoin,
    adapter: Ecto.Adapters.Postgres

  @spec listen(event_name :: String.t()) ::
          {:error, any} | {:eventually, reference} | {:ok, pid, reference}
  def listen(event_name) do
    with {:ok, pid} <- Postgrex.Notifications.start_link(__MODULE__.config()),
         {:ok, ref} <- Postgrex.Notifications.listen(pid, event_name) do
      {:ok, pid, ref}
    end
  end
end
