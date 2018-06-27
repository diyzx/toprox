# Toprox

[![Build Status](https://travis-ci.org/diyZX/toprox.svg?branch=master)](https://travis-ci.org/diyZX/toprox)
[![Hex version](https://img.shields.io/hexpm/v/toprox.svg "Hex version")](https://hex.pm/packages/toprox)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

A simple proxy for different Logger backends which allows to filter messages based on metadata.

## Installation

Add `toprox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:toprox, "~> 0.1"}
  ]
end
```

## Configuration

Config would have an entry similar to this:

```elixir
config :logger, backends: [
  {Toprox, :graylog},
  {Toprox, :rotate_log},
  {Toprox, :warn_console},
  :console
]
  
config :logger, :graylog,
  level: :info,
  backend: {
    Logger.Backends.Gelf, [
      host: "graylog.example.com",
      port: 12201,
      application: "MyApplication",
      compression: :gzip,
      metadata: [:request_id, :function, :module, :file, :line]
    ]
  }

config :logger, :rotate_log,
  level: :info,
  backend: {
    Loggix, [
      path: "test.log",
      json_encoder: Poison,
      rotate: %{max_bytes: 1024, keep: 5},
      metadata: [:user_id, :request_id]
    ]
  }

config :logger, :warn_console,
  level: :warn,
  backend: {
    Toprox.Console, [
      format: ">>> $date $time [$level] $metadata$message\n",
      metadata: [:user_id]
    ]
  }

config :logger, :console,
  format: "$date [$level] $metadata$message\n",
  metadata: [:request_id]
```

If you want to use `toprox` for standard Console backend you should use Toprox.Console instead like in the sample above.

## Usage

Use `:topic` in Logger metadata to write message to appropriate log:

```elixir
Logger.info "Info", topic: :graylog
Logger.error "Error", topic: [:rotate_log, :warn_console]
```
