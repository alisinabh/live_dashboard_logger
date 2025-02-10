# LiveLogger

A simple custom "Live Logs" page in [Phoenix Live Dashboard](https://github.com/phoenixframework/phoenix_live_dashboard) using a custom logger backend.

## Installation

Add `:live_dashboard_logger` into your dependencies.

```elixir
def deps do
  [
    {:live_dashboard_logger, "~> 0.0.0"}
  ]
end
```

Then add the `LiveDashboardLogger` page to `additional_pages` of `live_dashboard` in your router.

```elixir
live_dashboard "/dashboard",
  metrics: LoggertestWeb.Telemetry,
  additional_pages: [
    # Add this line
    live_logs: LiveDashboardLogger
  ]
```

## License

MIT
