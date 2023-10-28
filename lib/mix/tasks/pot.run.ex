defmodule Mix.Tasks.Pot.Run do
  use Mix.Task
  require Logger

  def run([]) do
    Mix.Task.rerun("pot.run", ["-d"])
  end

  @shortdoc "Podman utilities for building releases"
  def run([interactive]) do
    if PotUtils.get_docker_images == [] do
      Mix.Task.run("pot.build", [])
    end
    runtime = PotUtils.get_runtime()
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    Logger.info("Using container runtime: #{runtime}")
    inter_cmd = case interactive do
      "-i" -> "-i /app/_build/dev/rel/#{app_name}/bin/#{app_name} start"
      "-d" -> "-d #{app_name}"
      _ -> raise "Invalid run command. Valid options are '-i' for interactive OR '-d' for detached."
    end
    runtime_cmd = "run --rm #{inter_cmd}"
    Logger.info("Running the following docker command: #{runtime} #{runtime_cmd}")
    run_container(
      runtime, runtime_cmd
    )
  end

  defp run_container(runtime, cmd) do
    System.cmd(runtime, String.split(cmd, " "), into: IO.stream(:stdio, :line))
  end
end


