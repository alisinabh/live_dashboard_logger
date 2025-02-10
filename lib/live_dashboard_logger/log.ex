defmodule LiveDashboardLogger.Log do
  @moduledoc """
  Simple Log struct
  """

  defstruct [:id, :message, :timestamp, :level, :node, metadata: []]

  @type t :: %__MODULE__{
          message: String.t(),
          timestamp: timestamp(),
          level: Logger.level(),
          metadata: Keyword.t(),
          node: node()
        }

  @type timestamp :: {{1970..9999, 1..12, 1..31}, {0..23, 0..59, 0..59, 0..999}}

  def new(level, message, timestamp, metadata \\ [], node \\ node()) do
    log =
      %__MODULE__{
        id: nil,
        level: level,
        message: message,
        timestamp: timestamp,
        metadata: metadata,
        node: node
      }

    id = :erlang.phash2(log, 4_294_967_296)

    %__MODULE__{log | id: id}
  end
end
