defmodule LiveDashboardLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_dashboard_logger,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:logger_backends, "~> 1.0"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_live_dashboard, "~> 0.8.6"}
    ]
  end
end
