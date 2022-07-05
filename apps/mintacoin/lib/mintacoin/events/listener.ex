defmodule Mintacoin.Events.Listener do
  use GenServer

  def child_spec(opts) do
    %{
      id: Keyword.get(opts, :id, __MODULE__),
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []),
    do: GenServer.start_link(__MODULE__, opts)

  @impl true
  def init(opts) do
    event_name = Keyword.get(opts, :event_name, nil)

    with {:ok, _pid, _ref} <- Mintacoin.Repo.listen(event_name) do
      {:ok, opts}
    else
      error -> {:stop, error}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "account_created", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      IO.inspect(data, label: "Account Created")

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end

  def handle_info({:notification, _pid, _ref, "asset_created", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      IO.inspect(data, label: "Asset Created")

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end

  def handle_info({:notification, _pid, _ref, "payment_created", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      IO.inspect(data, label: "Payment Created")

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end

  def handle_info({:notification, _pid, _ref, "asset_authorized", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      IO.inspect(data, label: "Asset Authorized")

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end
end
