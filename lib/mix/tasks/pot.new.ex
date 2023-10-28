defmodule Mix.Tasks.Pot.New do
  use Mix.Task

  @shortdoc "Podman utility for creating a new Dockerfile"

  @impl Mix.Task
  def run ([]) do
    Mix.Task.rerun("pot.new", [:no_name])
  end

  @impl Mix.Task
  def run([pot_name]) do
    {dir, _resp} = System.cmd("pwd", [])
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    docker_file = PotUtils.get_docker_file_for_pot(pot_name)
    case File.open("#{String.trim(dir)}/#{docker_file}", [:write]) do
      {:ok, file} -> IO.binwrite(file, """
        FROM elixir:latest

        ARG SET_MIX_ENV=dev
        ENV MIX_ENV $SET_MIX_ENV
        WORKDIR /app

        COPY . /app
        RUN rm -rf _build 

        RUN mix local.hex --force && \\
            mix local.rebar --force && \\
            mix deps.get

        # Compile the project
        RUN mix compile
        RUN mix release 

        CMD ["sh", "-c", "_build/${MIX_ENV}/rel/#{app_name}/bin/#{app_name} start"]
        """)
      _ -> raise "Unable to create docker file"
    end
  end
end

