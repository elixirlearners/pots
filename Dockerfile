FROM elixir:latest

ARG SET_MIX_ENV=dev
ENV MIX_ENV $SET_MIX_ENV
WORKDIR /app

COPY . /app
RUN rm -rf _build 

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Compile the project
RUN mix compile
RUN mix release 

CMD ["sh", "-c", "_build/${MIX_ENV}/rel/pots/bin/pots start"]
