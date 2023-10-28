defmodule Mix.Tasks.Pot.Build do
  use Mix.Task
  require Logger

  def run([]) do
    Mix.Task.rerun("pot.build", [:no_name])
  end

  @shortdoc "Podman utilities for building releases"
  def run([pot_name]) do
    runtime = PotUtils.get_runtime()
    Logger.info("Using container runtime: #{runtime}")
    build_image(runtime, pot_name)
  end


  defp build_image(runtime, pot_name) do
    docker_file = PotUtils.get_docker_file_for_pot(pot_name)
    Logger.info("Building dockerfile: #{docker_file}")
    if !File.exists?(docker_file) do
      Mix.Task.run("pot.new",[])
    end
    Logger.info("Creating dockerfile: #{docker_file}")
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    manager(runtime, "build -f #{docker_file} --build-arg MIX_ENV=dev -t #{app_name} --label pot_#{app_name}=pot")
  end

  defp manager(runtime, cmd) do
    System.cmd(runtime, String.split(cmd, " "), into: IO.stream(:stdio, :line))
  end
end


