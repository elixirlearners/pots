defmodule Mix.Tasks.Pot.Info do
  use Mix.Task
  require Logger

  @shortdoc "Returns information on container environment around your pots."

  @impl Mix.Task
  def run (_args) do
    IO.puts ("Docker files:")
    PotUtils.get_all_docker_files()
    |> Enum.each(fn file -> 
      IO.puts "\t#{file}"
    end)
    PotUtils.print_images()
    PotUtils.print_containers()
  end
end