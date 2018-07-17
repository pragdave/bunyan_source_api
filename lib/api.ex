# This is a little funky...

# We want the API functions to be available in the top-level Bunyan module,
# but they are an optional dependency.
#
# So we test to see if the api has been given as a dependency in our
# host assembly, and if so we get it to inject the API functions
# into this module.

defmodule Bunyan do

  @moduledoc """
  See BunyanLogger for details
  """

  alias Bunyan.Shared.Level


  @doc """
  Generate a debug-level log message.

  The first parameter may be a string or a zero-arity function that returns a
  string. The function is only called if the message is to be generated.

  The second parameter is any Elixir term, which is formatted and printed below
  the log message.

  ### Example

  ~~~ elixir
  debug("Enter formatting funcion", args)

  debug(fn -> some_expensive_operation end)
  ~~~
  """

  defmacro debug(msg_or_fun, extra \\ nil), do: maybe_generate(:debug, msg_or_fun, extra)

  @doc """
  Generate an info-level log message.

  The first parameter may be a string or a zero-arity function that returns a
  string. The function is only called if the message is to be generated.

  The second parameter is any Elixir term, which is formatted and printed below
  the log message.

  ### Example

  ~~~ elixir
  info("Stale carts removed", statistics)
  ~~~
  """

  defmacro  info(msg_or_fun, extra \\ nil), do: maybe_generate(:info,  msg_or_fun, extra)


  @doc """
  Generate an warning-level log message.

  The first parameter may be a string or a zero-arity function that returns a
  string. The function is only called if the message is to be generated.

  The second parameter is any Elixir term, which is formatted and printed below
  the log message.

  ### Example

  ~~~ elixir
  warn("Disk is 85% full")
  ~~~
  """

  defmacro  warn(msg_or_fun, extra \\ nil), do: maybe_generate(:warn,  msg_or_fun, extra)


  @doc """
  Generate an error-level log message.

  The first parameter may be a string or a zero-arity function that returns a
  string. The function is only called if the message is to be generated.

  The second parameter is any Elixir term, which is formatted and printed below
  the log message.

  ### Example

  ~~~ elixir
  error("Database connection lost")
  ~~~
  """

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


defmodule Bunyan.Source.Api do

  alias Bunyan.Shared.{ Level, Readable }

  @server      Bunyan.Source.Api.Server
  @server_name @server

  use Readable, server_name: @server_name

  @compile { :inline, log: 3 }

  def debug(msg_or_fun, extra) do
    log(Level.of(:debug), msg_or_fun, extra)
  end

  def info(msg_or_fun, extra) do
    log(Level.of(:info), msg_or_fun, extra)
  end

  def warn(msg_or_fun, extra) do
    log(Level.of(:warn), msg_or_fun, extra)
  end

  def error(msg_or_fun, extra) do
    log(Level.of(:error), msg_or_fun, extra)
  end


  @spec log(Level.type_as_number, msg_or_fun :: binary | (() -> binary()) , extra :: any()) :: any()
  defp log(level, msg_or_fun, extra) do
    GenServer.cast(@server_name, { level, msg_or_fun, extra })
  end
end
