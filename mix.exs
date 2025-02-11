defmodule LiveDashboardLogger.MixProject do
  use Mix.Project

  @version "0.0.2"
  @source_url "https://github.com/alisinabh/live_dashboard_logger"

  def project do
    [
      app: :live_dashboard_logger,
      version: @version,
      elixir: "~> 1.15",
      source_url: @source_url,
      deps: deps(),
      docs: docs(),
      package: package()
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
      {:phoenix_live_dashboard, "~> 0.8.6"},
      {:ex_doc, "~> 0.37", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      description: "Real-time log viewing for Phoenix Live Dashboard",
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Alisina Bahadori"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    source_ref =
      if String.ends_with?(@version, "-dev") do
        "main"
      else
        "v#{@version}"
      end

    [
      main: "readme",
      extras: [
        "README.md": [title: "Getting Started"],
        "LICENSE.md": [title: "License"]
      ],
      source_url: @source_url,
      source_ref: source_ref,
      assets: %{"assets" => "assets"}
    ]
  end
end
