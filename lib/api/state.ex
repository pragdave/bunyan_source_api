defmodule Bunyan.Source.Api.State do

  alias Bunyan.Shared.Level

  defstruct(
    collector: nil,
    runtime_log_level: Level.of(:debug)
  )

  @valid_options [ :runtime_log_level ]

  @spec from(keyword()) :: %__MODULE__{} | none()
  def from(options) do
    import Bunyan.Shared.Options

    validate_legal_options(options, @valid_options, Bunyan.Source.Api)

    %__MODULE__{}
    |> maybe_add_level(:runtime_log_level, options[:runtime_log_level])
  end

end
