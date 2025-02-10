defmodule LiveDashboardLogger.PubSub do
  @moduledoc false

  @topic_prefix "logs:"

  def publish_log(server, topic, log) do
    Phoenix.PubSub.broadcast!(server, @topic_prefix <> topic, {:log, log})
  end

  def subscribe_logs(server, topic) do
    Phoenix.PubSub.subscribe(server, @topic_prefix <> topic)
  end
end
