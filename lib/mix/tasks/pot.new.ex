defmodule Mix.Tasks.Pot.New do
  use Mix.Task

  @shortdoc "Podman utility for creating a new Dockerfile"
  def run(_args) do
    {dir, _resp} = System.cmd("pwd", [])
    app_name = Application.get_application(__MODULE__) |> Atom.to_string
    case File.open("#{String.trim(dir)}/Dockerfile", [:write]) do
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

