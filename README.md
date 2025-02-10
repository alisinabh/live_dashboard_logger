# LiveDashboard Logger

LiveDashboard Logger adds real-time log viewing capabilities to [Phoenix Live Dashboard](https://github.com/phoenixframework/phoenix_live_dashboard) through a custom logger backend. This allows you to monitor your application's logs directly from your dashboard, making debugging and monitoring easier.

## Features

- Real-time log streaming in Phoenix Live Dashboard
- Supports multi-node setups
- Clean integration with existing Phoenix Live Dashboard setup
- Minimal performance overhead

## Installation

1. Add `:live_dashboard_logger` to your dependencies in `mix.exs`:

```elixir
# mix.exs
def deps do
  [
    {:live_dashboard_logger, "~> 0.0.1"}
  ]
end
```

2. Add the `LiveDashboardLogger` page to your Phoenix Live Dashboard configuration in your router:

```elixir
# lib/your_app_web/router.ex
live_dashboard "/dashboard",
  metrics: YourAppWeb.Telemetry,
  additional_pages: [
    live_logs: LiveDashboardLogger
  ]
```

## Usage

Once installed, you'll find a new "Live Logs" page in your Phoenix Live Dashboard.
The page displays incoming logs in real-time.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](/LICENSE.md) file for details.
