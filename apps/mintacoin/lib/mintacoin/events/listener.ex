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
    with {:ok, _pid, _ref} <- Mintacoin.Repo.listen("event_created") do
      {:ok, opts}
    else
      error -> {:stop, error}
    end
  end

  @impl true
  def handle_info({:notification, _pid, _ref, "event_created", payload}, _state) do
    with {:ok, data} <- Jason.decode(payload, keys: :atoms) do
      IO.inspect(data, label: "Event Created")

      {:noreply, :event_handled}
    else
      error -> {:stop, error, []}
    end
  end
end
