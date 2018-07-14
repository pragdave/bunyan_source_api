Code.load_file("shared_build_stuff/mix.exs")
alias Bunyan.Shared.Build

defmodule BunyanSourceApi.MixProject do
  use Mix.Project

  def project() do
    Build.project(
      :bunyan_source_api,
      "0.1.0",
      &deps/1,
      "API for the Bunyan distributed and pluggable logging system (error, warn, info, and debug functions)"
    )
  end

  def application(), do: []

  def deps(a) do
    IO.inspect a
    [
      bunyan:  [ bunyan_shared: ">= 0.0.0" ],
      others:  [],
    ]
  end

end
