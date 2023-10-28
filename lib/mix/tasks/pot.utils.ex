defmodule PotUtils do
  @moduledoc """
  Utils for running Pot tasks. Most of the logic of Pot tasks are contained here.
  """
  require Logger

  @doc """
  Get the current container run time to use. The return values can
  be the strings of "docker", "podman", or "nerdctl". Currently
  does not allow for choosing your runtime, this is to be added later.
  """
  def get_runtime do
    get_nerdctl()
  end

  @doc """
  Get the application name. Thils is either the value of `:app` in the
  application configuration or the return value of `Application.get_all_env(__MODULE__)`
  """
  def app_name do
    config = Mix.Project.config()

    if Keyword.has_key?(config, :app) do
      config[:app] |> Atom.to_string()
    else
      Application.get_application(__MODULE__)
    end
  end

  @doc """
  Trys to run the program `nerdctl`. If it errors, it will move
  on to try the next runtime `podman`.
  """
  def get_nerdctl do
    try do
      System.cmd("nerdctl", ["-v"])
      "nerdctl"
    catch
      _ -> get_podman()
    end
  end

  @doc """
  Trys to run the program `podman`. If it errors, it will move
  on to try the next runtime `docker`.
  """
  def get_podman do
    try do
      System.cmd("podman", ["-v"])
      "podman"
    catch
      _ -> get_docker()
    end
  end

  @doc """
  Trys to run the program `docker`. If it errors, it will raise
  and error because no suitable container runtime can be found.
  """
  def get_docker do
    try do
      System.cmd("docker", ["-v"])
      "docker"
    rescue
      _ ->
        raise """
        Pots requires a container runtime to function. The currently
        supported container run times are as follows. Please install one;
        - docker (https://docs.docker.com/engine/install/)
        - podman (https://podman.io/docs/installation)
        - nerdctl (https://github.com/containerd/nerdctl)
        """
    end
  end

  @doc """
  Gets the name of the Dockerfile. If `:no_name` is passed in then it
  simply returns `Dockerfile.pot`. If any other string is passed to it, it will
  return `Docerfile.<string>.pot`.

  ## Example
    iex> PotUtils.get_docker_file_for_pot(:no_name)
    Dockerfile.pot
    iex> PotUtils.get_docker_file_for_pot("my_project")
    Dockerfile.my_project.pot
  """
  def get_docker_file_for_pot(pot_name) do
    case pot_name do
      :no_name -> "Dockerfile.pot"
      _ -> "Docker.#{pot_name}.pot"
    end
  end

  @doc """
  Returns a list of `Dockerfiles` for Pot. It looks for files that start
  with `Docker` and end with `.pot`.
  """
  def get_all_docker_files do
    {:ok, files} = File.ls()
    files |> Enum.filter(&(String.starts_with?(&1, "Docker") && String.ends_with?(&1, ".pot")))
  end

  @doc """
  Remove all container images created by Pot. This will only touch images labled appropriately
  by pot. This runs the command `<container-runtime> image rm <img-id>`
  """
  def remove_image(img) do
    id = img["Id"]
    runtime_cmd("image rm #{id}")
  end

  @doc """
  Stop all running containers created by Pot. This should
  also remove them as all containers are started with the
  options `--rm` which means to remove them once stopped.
  Uses the command in the format of `<container-runtime> stop <container-id`
  """
  def stop_container(container) do
    id = container["Id"]
    runtime_cmd("container stop #{id}")
  end

  @doc """
  Returns a list of all docker containers, filtered by the label of
  `pot_<app-name>` in JSON format. If none are returned, it returns
  an empty list. Uses the command in the format of
  `<container-runtime> container ls --filter lable=pot_<app-name> --format {{json}}`
  """
  def get_docker_containers do
    {output, _} = runtime_cmd("container ls --filter label=pot_#{app_name()} --format {{json}}")

    if output != "" do
      Jason.decode!(output)
    else
      []
    end
  end

  @doc """
  Similar to `PotUtils.get_docker_containers/0`, it filters all containers on the label of
  `pot_<app-name>` and simply prints the output of the command. Uses the command
  in the format of
  `<container-runtime> container ls --filter lable=pot_<app-name>`
  """
  def print_containers do
    {output, _} = runtime_cmd("container ls --filter label=pot_#{app_name()}")
    IO.puts("Containers")
    IO.puts(output)
  end

  @doc """
  Returns a list of all docker images, filtered by the label of
  `pot_<app-name>` in JSON format. If none are returned, it returns
  an empty list. Uses the command in the format of
  `<container-runtime> images --filter lable=pot_<app-name> --format {{json}}`
  """
  def get_docker_images do
    {output, _} = runtime_cmd("images --filter label=pot_#{app_name()} --format {{json}}")

    if output != "" do
      Jason.decode!(output)
    else
      []
    end
  end

  @doc """
  Similar to `PotUtils.get_docker_images/0`, it filters all images on the label of
  `pot_<app-name>` and simply prints the output of the command. Uses the command
  in the format of
  `<container-runtime> images --filter lable=pot_<app-name>`
  """
  def print_images do
    {output, _} = runtime_cmd("images --filter label=pot_#{app_name()}")
    IO.puts("Images")
    IO.puts(output)
  end

  @doc """
  Takes in the command to be run using the runtime returned from `PotUtils.get_runtime/0`.
  Splits the `cmd` up and passes it to `System.cmd`.
  """
  def runtime_cmd(cmd) do
    System.cmd(get_runtime(), String.split(cmd, " "), into: IO.stream(:stdio, :line))
  end
end
