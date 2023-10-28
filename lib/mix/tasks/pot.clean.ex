defmodule Mix.Tasks.Pot.Clean do
  use Mix.Task
  require Logger

  @shortdoc "Cleanup files and containers created using Pots. Options [--files | --images | --containers]. No option defaults to all, excluding files"
  @impl Mix.Task
  def run([]) do
    Mix.Task.rerun("pot.clean", [:all])
  end

  @shortdoc "Cleanup files and containers created using Pots. Options [--files | --images | --containers]. No option defaults to all, excluding files"
  @impl Mix.Task
  def run(args) do
    Enum.each(args, &process_arg/1)
  end

  @doc """
  Breaks out the process arguments and runs different cleanup.
  tasks depending on whats been passed in.
  - `--files`: It will remove all Docker files generated by Pots.
  - `--images`: It will remove all container images created by Pots.
  - `--containers`: It will remove all containers created by Pots.
  """
  def process_arg(arg) do
    case arg do
      :all ->
        run_all()

      "--files" ->
        remove_docker_files()

      "--images" ->
        stop_docker_containers()
        remove_docker_images()

      "--containers" ->
        stop_docker_containers()
    end
  end

  @doc """
  This will run all cleanup functions. Note: it will stop all
  containers before attempting to remove the images. Excludes
  running `remove_docker_files/0` since it may contain
  changes the user wants to keep.
  - `remove_docker_files/0`
  - `stop_docker_containers/0`
  - `remove_docker_images/0`
  """
  def run_all() do
    stop_docker_containers()
    remove_docker_images()
  end

  @doc """
  Stop all running containers created by Pots. This will
  only affect containers with the label `pot_<app-name>`
  """
  def stop_docker_containers do
    PotUtils.get_docker_containers()
    |> Enum.each(fn con ->
      case Map.keys(con) do
        "Names" ->
          Logger.info("Removing container: #{List.first(con["Names"])}")
        "Id" -> 
          Logger.info("Removing container: #{List.first(con["Id"])}")
        _ -> 
          Logger.info("Removing container...")
      end
      PotUtils.stop_container(con)
    end)
  end

  @doc """
  Remove all container images created by Pots. This will
  only affect images with the label `pot_<app-name>`
  """
  def remove_docker_images do
    PotUtils.get_docker_images()
    |> Enum.each(fn img ->
      case Map.keys(img) do
        "Names" -> 
          Logger.info("Removing image: #{List.first(img["Names"])}")
        "Id" ->
          Logger.info("Removing image: #{List.first(img["Id"])}")
        _ ->
          Logger.info("Removing image..")
      end
      PotUtils.remove_image(img)
    end)
  end

  @doc """
  Remove all docker files created by Pots. This will
  only affect files that start with `Docker` and end
  with `.pot`
  """
  def remove_docker_files() do
    {:ok, cwd} = File.cwd()

    PotUtils.get_all_docker_files()
    |> Enum.each(fn file ->
      Logger.info("Removing dockerfile at: #{cwd}/#{file}")
      File.rm("#{cwd}/#{file}")
    end)
  end
end
