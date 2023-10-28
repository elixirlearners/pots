defmodule Mix.Tasks.Pot.Clean do
  use Mix.Task
  require Logger

  @shortdoc "Cleanup files and containers created using pots"

  @impl Mix.Task
  def run ([]) do
    Mix.Task.rerun("pot.clean", [:all])
  end

  @impl Mix.Task
  def run(args) do
    Enum.each(args, &process_arg/1) 
  end

  def process_arg(arg) do
    case arg do
      :all -> run_all()
      "--files" -> remove_docker_files() 
      "--images" -> 
        stop_docker_containers()
        remove_docker_images()
      "--containers" -> stop_docker_containers()
    end
  end

  def run_all() do 
    remove_docker_files()
    stop_docker_containers()
    remove_docker_images()
  end

  def stop_docker_containers do
    PotUtils.get_docker_containers()
    |> Enum.each(fn con -> 
      Logger.info("Stopping container: #{List.first(con["Names"])}")
      PotUtils.stop_container(con)
    end)
  end

  def remove_docker_images do
    PotUtils.get_docker_images
    |> Enum.each(fn img -> 
      Logger.info("Removing image: #{List.first(img["Names"])}")
      PotUtils.remove_image(img)
    end)
  end

  def remove_docker_files() do
    {:ok, cwd} = File.cwd
    PotUtils.get_all_docker_files()
    |> Enum.each(fn file -> 
      Logger.info("Removing dockerfile at: #{cwd}/#{file}")
      File.rm("#{cwd}/#{file}")
    end)
  end
end
