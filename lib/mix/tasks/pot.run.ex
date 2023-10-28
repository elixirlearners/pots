defmodule Mix.Tasks.Pot.Run do
  use Mix.Task
  require Logger

  @shortdoc "Podman utilities for building releases"
  def run(args) do
    runtime = get_runtime()
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    Logger.info("Using container runtime: #{Atom.to_string(runtime)}")

    manager(
      runtime, "run --rm -i #{app_name} /app/_build/#{args}/rel/#{app_name}/bin/#{app_name} start"
    )
  end

  defp get_runtime do
    get_podman()
  end

  defp get_podman do
    try do
      System.cmd("podman", ["-v"])
      :podman
    catch
      _ -> get_docker()
    end
  end

  defp get_docker do
    try do
      System.cmd("docker", ["-v"])
      :docker
    rescue
      _ -> raise "No container manager found. Please install docker or podman."
    end
  end

  defp manager(runtime, cmd) do
    System.cmd(Atom.to_string(runtime), String.split(cmd, " "), into: IO.stream(:stdio, :line))
  end
end


