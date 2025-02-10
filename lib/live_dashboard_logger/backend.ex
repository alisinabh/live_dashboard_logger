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

  @impl true
  def handle_call({:configure, _opts}, state) do
    {:ok, :ok, state}
  end

  @impl true
  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %__MODULE__{} = state) do
    IO.puts("HANDLING LOG")
    log = Log.new(level, msg, ts, md)
    :ok = PubSub.publish_log(state.pubsub_server, state.topic, log)

    {:ok, %__MODULE__{state | processed_messages: state.processed_messages + 1}}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, _state) do
    IO.puts("HANDLER REMOVED")
    :remove_handler
  end
end
