unless function_exported?(Bunyan.Shared.Build, :__info__, 1),
do: Code.require_file("shared_build_stuff/mix.exs")

alias Bunyan.Shared.Build

defmodule BunyanSourceApi.MixProject do
  use Mix.Project

  def project() do
    Build.project(
      :bunyan_source_api,
      "0.5.0",
      &deps/1,
      "API for the Bunyan distributed and pluggable logging system (error, warn, info, and debug functions)"
    )
  end

  def application(), do: []

  def deps(_) do
    [
      bunyan:  [ bunyan_shared: ">= 0.0.0" ],
      others:  [],
    ]
  end

end
