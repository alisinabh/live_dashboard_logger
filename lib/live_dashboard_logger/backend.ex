defmodule LiveDashboardLogger.Backend do
  @moduledoc false

  @behaviour :gen_event

  defstruct [:pubsub_server, :topic, processed_messages: 0]

  alias LiveDashboardLogger.Log
  alias LiveDashboardLogger.PubSub

  @impl true
  def init({__MODULE__, opts}) do
    topic = Keyword.fetch!(opts, :topic)
    server = Keyword.fetch!(opts, :pubsub_server)
    listener = Keyword.fetch!(opts, :listener)

    Process.monitor(listener)

    {:ok, %__MODULE__{topic: topic, pubsub_server: server, processed_messages: 0}}
  end

  def add_to_all_nodes(pubsub_server, topic, listener \\ self()) do
    Enum.each([Node.self() | Node.list()], fn node ->
      Node.spawn_link(node, fn ->
        {:ok, _} =
          LoggerBackends.add(
            {LiveDashboardLogger.Backend,
             listener: listener, topic: topic, pubsub_server: pubsub_server}
          )
      end)
    end)
  end

  @impl true
  def handle_call({:configure, _opts}, state) do
    {:ok, :ok, state}
  end

  @impl true
  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %__MODULE__{} = state) do
    log = Log.new(level, msg, ts, md)
    :ok = PubSub.publish_log(state.pubsub_server, state.topic, log)

    {:ok, %__MODULE__{state | processed_messages: state.processed_messages + 1}}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, _state) do
    :remove_handler
  end

  def handle_info(_unknown, state) do
    {:ok, state}
  end
end
