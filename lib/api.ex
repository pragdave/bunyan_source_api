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
    IO.inspect @server_name
    IO.inspect Process.whereis(@server_name)
    GenServer.cast(@server_name, { level, msg_or_fun, extra })
  end
end
