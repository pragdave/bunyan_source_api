defmodule Bunyan.Source.Api.Test do
  use ExUnit.Case

  alias Bunyan.Source.Api
  alias Bunyan.Shared.TestHelpers, as: TH
  alias Bunyan.Shared.Level
  alias TH.DummyCollector,         as: Collector

  def start_api(config) do
    state = Api.state_from_config(Collector, config)
    GenServer.start(Api.Server, state, name: Api.Server)
  end

  def stop_api do
    GenServer.stop(Api.Server)
  end


  test "Generates messages to the collector" do
    Collector.start_link
    start_api([])
    Api.debug("debug", nil)
    Api.info("and info", nil)
    Api.warn("warning", with: "extras")
    Api.error("bad stuff", nil)

    :timer.sleep(10)
    msgs = Collector.get_messages

    Collector.stop
    stop_api()

    assert length(msgs) == 4

    [ m1, m2, m3, m4 ] = msgs

    assert m1.msg   == "debug"
    assert m1.level == Level.of(:debug)
    assert m1.extra == nil

    assert m2.msg   == "and info"
    assert m2.level == Level.of(:info)
    assert m2.extra == nil

    assert m3.msg   == "warning"
    assert m3.level == Level.of(:warn)
    assert m3.extra == [ with: "extras" ]

    assert m4.msg   == "bad stuff"
    assert m4.level == Level.of(:error)
    assert m4.extra == nil
  end

  test "filters messages below the runtime log level" do
    Collector.start_link

    start_api(runtime_log_level: :warn)

    Api.debug("debug", nil)
    Api.info("and info", nil)
    Api.warn("warning", with: "extras")
    Api.error("bad stuff", nil)

    :timer.sleep(10)
    msgs = Collector.get_messages

    Collector.stop
    stop_api()

    assert length(msgs) == 2

    [ m3, m4 ] = msgs

    assert m3.msg   == "warning"
    assert m3.level == Level.of(:warn)
    assert m3.extra == [ with: "extras" ]

    assert m4.msg   == "bad stuff"
    assert m4.level == Level.of(:error)
    assert m4.extra == nil
  end
end
