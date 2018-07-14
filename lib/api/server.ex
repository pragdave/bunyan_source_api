defmodule Bunyan.Source.Api.Server do

  use GenServer

  alias Bunyan.Shared.{ Collector, LogMsg }

  @me __MODULE__

  def start_link(options) do
    { :ok, _pid } = GenServer.start_link(__MODULE__, options, name: @me)
  end

  def init(options) do
    { :ok, options }
  end

  def handle_cast({ level, msg_or_fun, extra }, options) do
    IO.inspect { level, msg_or_fun, extra , options }
    if level >= options.runtime_log_level do
      msg = %LogMsg{
        level:     level,
        msg:       msg_or_fun,
        extra:     extra,
        timestamp: :os.timestamp(),
        pid:       self(),
        node:      node()
      }
      Collector.log(options.collector, msg)
    end
    { :noreply, options }
  end

  def handle_cast(other, options) do
    IO.puts "unexpected cast"
    IO.inspect other
    IO.inspect options
    :erlang.halt
  end

end
