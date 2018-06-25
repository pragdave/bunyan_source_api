defmodule Bunyan.Source.Api do

  alias Bunyan.Shared.{ Level, Readable }

  use Readable

  @compile { :inline, log: 3 }

  @server      Bunyan.Source.Api.Server
  @server_name @server

  def start(options) do
    { :ok, _ } = GenServer.start_link(@server, options, name: @server_name)
  end



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


  @spec log(level :: 0 | 10 | 20 | 30, msg_or_fun :: binary | (() -> binary()) , extra :: any()) :: any()
  defp log(level, msg_or_fun, extra) do
    GenServer.cast(@server_name, { level, msg_or_fun, extra })
  end
end
