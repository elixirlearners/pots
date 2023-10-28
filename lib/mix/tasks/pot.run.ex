defmodule Mix.Tasks.Pot.Run do
  use Mix.Task
  require Logger

  @shortdoc "Will run the container created by Pot"
  @impl Mix.Task
  def run([]) do
    Mix.Task.rerun("pot.run", ["-d"])
  end

  @shortdoc "Will run the container created by Pot"
  @impl Mix.Task
  def run([interactive]) do
    if PotUtils.get_docker_images == [] do
      Mix.Task.run("pot.build", [])
    end
    runtime = PotUtils.get_runtime()
    app_name = PotUtils.app_name()
    Logger.info("Running docker container for #{app_name}")
    Logger.info("Using container runtime: #{runtime}")
    inter_cmd = case interactive do
      "-i" -> "-i /app/_build/dev/rel/#{app_name}/bin/#{app_name} start"
      "-d" -> "-d #{app_name}"
      _ -> raise "Invalid run command. Valid options are '-i' for interactive OR '-d' for detached."
    end
    runtime_cmd = "run --rm #{inter_cmd}"
    Logger.info("Running the following docker command: #{runtime} #{runtime_cmd}")
    PotUtils.runtime_cmd(runtime_cmd)
  end
end


