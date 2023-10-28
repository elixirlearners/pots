defmodule PotUtils do
  require Logger

  def get_runtime do
    get_podman()
  end

  defp get_podman do
    try do
      System.cmd("podman", ["-v"])
      "podman"
    catch
      _ -> get_docker()
    end
  end

  defp get_docker do
    try do
      System.cmd("docker", ["-v"])
      "docker"
    rescue
      _ -> raise "No container manager found. Please install docker or podman."
    end
  end

  def get_docker_file_for_pot(pot_name) do
    case pot_name do
      :no_name -> "Dockerfile.pot"
      _ -> "Docker.#{pot_name}.pot"
    end
  end

  def get_all_docker_files do
    {:ok, files} = File.ls
    files |> Enum.filter(&(String.starts_with?(&1, "Docker") && String.ends_with?(&1, ".pot")))
  end

  def remove_image(img) do
    runtime = get_runtime()
    id = img["Id"]
    System.cmd(runtime, ["image", "rm", "#{id}"])
  end

  def stop_container(container) do
    runtime = get_runtime()
    id = container["Id"]
    System.cmd(runtime, ["container", "stop", "#{id}"])
  end


  def get_docker_containers do
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    runtime = get_runtime()
    {output, _} = System.cmd(runtime, ["container", "ls", "--filter", "label=pot_#{app_name}", "--format", "{{json}}"])
    if output != "" do
      Jason.decode!(output)
    else
      %{}
    end
  end

  def print_containers do
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    runtime = get_runtime()
    {output, _} = System.cmd(runtime, ["container", "ls", "--filter", "label=pot_#{app_name}"])
    IO.puts "Containers"
    IO.puts output
  end

  def get_docker_images do
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    runtime = get_runtime()
    {output, _} = System.cmd(runtime, ["images", "--filter", "label=pot_#{app_name}", "--format", "{{json}}"])
    if output != "" do
      Jason.decode!(output)
    else
      %{}
    end
  end

  def print_images do
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    runtime = get_runtime()
    {output, _} = System.cmd(runtime, ["images", "--filter", "label=pot_#{app_name}"])
    IO.puts "Images"
    IO.puts output
  end
end
