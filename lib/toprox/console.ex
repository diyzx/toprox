defmodule Toprox.Console do
  @moduledoc """
  A simple proxy for standard Console backend which allows to filter messages based on metadata.

  ## Usage

  In `config.exs`:

          config :logger, backends: [
            {Toprox, :warn_console}
          ]

          config :logger, :warn_console,
            level: :warn,
            backend: {
              Toprox.Console, [
                format: ">>> $date $time [$level] $metadata$message",
                metadata: [:user_id]
            ]
          }

  In code:

          Logger.error "Error", topic: :warn_console

  """

  @behaviour :gen_event

  @doc false
  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  @doc false
  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  @doc false
  def handle_event(event, state) do
    {:ok, new_console_state} = log_event(event, state)

    {:ok, %{state | console_state: new_console_state}}
  end

  @doc false
  def handle_info(info, state) do
    {:ok, new_console_state} = process_info(info, state)

    {:ok, %{state | console_state: new_console_state}}
  end

  ## Helpers

  defp log_event(event, %{console_state: console_state} = state) do
    Logger.Backends.Console.handle_event(event,
      %{console_state | metadata: state.metadata, format: state.format})
  end

  defp process_info(info, %{console_state: console_state} = state) do
    Logger.Backends.Console.handle_info(info,
      %{console_state | metadata: state.metadata, format: state.format})
  end

  defp configure(name, opts) do
    state = %{name: nil, console_state: nil, metadata: nil, format: nil}

    configure(name, opts, state)
  end
  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    metadata = Keyword.get(opts, :metadata)
    format = Logger.Formatter.compile(Keyword.get(opts, :format))
    Application.put_env(:logger, name, opts)

    {:ok, console_state} = Logger.Backends.Console.init(:console)

    %{state | name: name, console_state: console_state, metadata: metadata, format: format}
  end
end
