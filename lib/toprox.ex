defmodule Toprox do
  @moduledoc false

  @behaviour :gen_event

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event({level, _gl, {Logger, _msg, _ts, md}} = event, %{module: module} = state) do
    if level?(level, state.level) and topic?(state.name, md[:topic]) do
      {:ok, new_backend_state} = module.handle_event(event, state.backend_state)

      {:ok, %{state | backend_state: new_backend_state}}
    else
      {:ok, state}
    end
  end

  def handle_event(:flush, %{module: module} = state) do
    {:ok, new_backend_state} = module.handle_event(:flush, state.backend_state)

    {:ok, %{state | backend_state: new_backend_state}}
  end

  def handle_info(info, %{module: module} = state) do
    {:ok, new_backend_state} = module.handle_info(info, state.backend_state)

    {:ok, %{state | backend_state: new_backend_state}}
  end

  ## Helpers

  defp level?(_, nil),     do: true
  defp level?(level, min), do: Logger.compare_levels(level, min) != :lt

  defp topic?(name, topic) when is_list(topic), do: name in topic
  defp topic?(name, topic), do: name == topic

  defp configure(name, opts) do
    state = %{name: nil, level: nil, module: nil, backend_state: nil}

    configure(name, opts, state)
  end
  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level, :debug)
    {module, backend_opts} = Keyword.get(opts, :backend)
    backend_opts = Keyword.put(backend_opts, :level, level)

    Application.put_env(:logger, :"_proxy_#{name}", backend_opts)
    {:ok, backend_state} = module.init({module, :"_proxy_#{name}"})

    %{state | name: name, level: level, module: module, backend_state: backend_state}
  end
end
