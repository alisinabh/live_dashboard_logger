defmodule LiveDashboardLogger.Hooks do
  import Phoenix.LiveView
  import Phoenix.Component

  alias Phoenix.LiveDashboard.PageBuilder

  def on_mount(:default, _params, _session, socket) do
    {:cont, PageBuilder.register_after_opening_head_tag(socket, &after_opening_head_tag/1)}
  end

  defp after_opening_head_tag(assigns) do
    ~H"""
    <script nonce={@csp_nonces[:script]}>
      window.LiveDashboard.registerCustomHooks({
        ScrollHook: {
          updated() {
            if (this.el.querySelector('.logger-autoscroll-checkbox').checked) {
              const messagesElement = this.el.querySelector('#logger-messages')
              messagesElement.scrollTop = messagesElement.scrollHeight
            }
          }
        }
      })
    </script>
    <style>
      .logger-wrap pre {
        white-space: pre-wrap !important;
      }
    </style>
    """
  end
end

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
    ],
    on_mount: [
      LiveDashboardLogger.Hooks
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

      <div class="card mb-4" id="logger-messages-card" phx-hook="ScrollHook">
        <div class="card-body">
          <div id="logger-messages" style="height: calc(100vh - 400px);" class={if(@text_wrap_enabled, do: "logger-wrap")} phx-update="stream">
            <%= for {id, %Log{level: level} = log} <- @streams.logs do %>
              <pre id={id} class={"log-level-#{level}"}>{format_log(log)}</pre>
            <% end %>
          </div>
          <div class="text-right mt-3">
            <label>
              Wrap
              <input
                phx-click="toggle_text_wrap"
                checked={@text_wrap_enabled}
                type="checkbox"
              />
            </label>
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
      |> assign(autoscroll_enabled: true, text_wrap_enabled: true, topic: topic)
      |> stream(:logs, [])

    {:ok, socket}
  end

  def handle_info({:log, %Log{} = log}, socket) do
    {:noreply, stream_insert(socket, :logs, log)}
  end

  def handle_event("toggle_autoscroll", _params, socket) do
    {:noreply, assign(socket, :autoscroll_enabled, !socket.assigns.autoscroll_enabled)}
  end

  def handle_event("toggle_text_wrap", _params, socket) do
    {:noreply, assign(socket, :text_wrap_enabled, !socket.assigns.text_wrap_enabled)}
  end

  def menu_link(_, _) do
    {:ok, "Live Logs"}
  end

  defp format_log(%Log{} = log) do
    Logger.Formatter.format(@log_format, log.level, log.message, log.timestamp, log.metadata)
  end
end
