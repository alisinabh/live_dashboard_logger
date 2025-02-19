defmodule LiveDashboardLogger do
  @moduledoc """
  Logs Page for Live Dashboard

  ## Add LiveDashboardLogger to Phoenix Live Dashboard

  To add LiveDashboardLogger to Phoenix Live Dashboard, simply include it in the `additional_pages`
  list of `live_dashboard` route macro.

  ### Example

  ```elixir
  live_dashboard "/dashboard",
    metrics: LoggertestWeb.Telemetry,
    additional_pages: [
      # Add this line
      live_logs: LiveDashboardLogger
    ]
  ```

  Then the "Live Logs" menu item should appear in your dashboard.
  """
  use Phoenix.LiveDashboard.PageBuilder

  alias LiveDashboardLogger.Log
  alias LiveDashboardLogger.PubSub

  @log_format Logger.Formatter.compile("$time [$level] $message")

  def render(assigns) do
    ~H"""
    <div class="logs-card" data-messages-present="true">
      <h5 class="card-title">Live Logs</h5>

      <div class="card mb-4" id="logger-messages-card" phx-hook="PhxRequestLoggerMessages">
        <div class="card-body">
          <div id="logger-messages" style="height: calc(100vh - 400px);" phx-update="stream">
            <%= for {id, %Log{level: level} = log} <- @streams.logs do %>
              <pre id={id} class={"log-level#{level} text-wrap"}>{format_log(log)}</pre>
            <% end %>
          </div>
          <!-- Autoscroll ON/OFF checkbox -->
          <div id="logger-autoscroll" class="text-right mt-3">
            <label>
              Autoscroll
              <input
                phx-click="toggle_autoscroll"
                checked={@autoscroll_enabled}
                class="logger-autoscroll-checkbox"
                type="checkbox"
              />
            </label>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    topic = Base.encode16(:rand.bytes(20))

    if connected?(socket) do
      endpoint = socket.endpoint
      pubsub_server = endpoint.config(:pubsub_server) || endpoint.__pubsub_server__()
      :ok = PubSub.subscribe_logs(pubsub_server, topic)

      LiveDashboardLogger.Backend.add_to_all_nodes(pubsub_server, topic)
    end

    socket =
      socket
      |> assign(autoscroll_enabled: true, topic: topic)
      |> stream(:logs, [])

    {:ok, socket}
  end

  def handle_info({:log, %Log{} = log}, socket) do
    {:noreply, stream_insert(socket, :logs, log)}
  end

  def handle_event("toggle_autoscroll", _params, socket) do
    {:noreply, assign(socket, :autoscroll_enabled, !socket.assigns.autoscroll_enabled)}
  end

  def menu_link(_, _) do
    {:ok, "Live Logs"}
  end

  defp format_log(%Log{} = log) do
    Logger.Formatter.format(@log_format, log.level, log.message, log.timestamp, log.metadata)
  end
end
