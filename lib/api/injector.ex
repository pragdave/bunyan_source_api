defmodule Bunyan.Source.Api.Injector do

  @moduledoc """
  We want the api functions such as `debug` and `warn` to be available at the
  top level, but at the same time we don't want to couple the top level to
  us.

  So the top-level `Bunyan` module checks to see it the application that uses it
  also has us as a dependency. It so, it calls our `inject_into_this_module`
  macro, which adds the necessary calls.

  """

  defmacro inject_into_this_module() do
    quote do
      alias Bunyan.Shared.Level

      defmacro debug(msg_or_fun, extra \\ nil), do: maybe_generate(:debug, msg_or_fun, extra)
      defmacro  info(msg_or_fun, extra \\ nil), do: maybe_generate(:info,  msg_or_fun, extra)
      defmacro  warn(msg_or_fun, extra \\ nil), do: maybe_generate(:warn,  msg_or_fun, extra)
      defmacro error(msg_or_fun, extra \\ nil), do: maybe_generate(:error, msg_or_fun, extra)


      defp compile_time_log_level() do
        with sources when is_list(sources) <- Application.get_env(:bunyan, :sources),
             api     when is_list(api)     <- sources[Bunyan.Source.Api],
             level                         =  api[:compile_time_log_level]
        do
          level
        else
          _ -> if (Mix.env() == :dev), do: :debug,  else: :info
        end
      end

      defp compile_time_log_level_number() do
        Level.of(compile_time_log_level())
      end

      defp maybe_generate(level, msg_or_fun, extra) do

        if compile_time_level_not_less_than?(level) do
          quote do
            Bunyan.Source.Api.unquote(level)(unquote(msg_or_fun), unquote(extra))
          end
        else
          quote do
            _avoid_warning_about_unused_variables = fn -> { unquote(msg_or_fun), unquote(extra) } end
          end
        end
      end

      defp compile_time_level_not_less_than?(target) do
        compile_time_log_level_number() <= Level.of(target)
      end
    end
  end
end
