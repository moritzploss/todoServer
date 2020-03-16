![Todo Engine](https://github.com/moritzploss/todoServer/workflows/Todo%20Engine/badge.svg)

# Todo Server

This repo contains an implementation of a stateful and highly concurrent Todo 
list server built with `Elixir`, `OTP`, and `Phoenix`.

## Getting Started

### Basic Setup

The following assumes that you have a working installation of `Elixir`
(including `mix`) and `Node.js` (including `npm`).

### Todo Engine

This directory contains all logic related to creating and modifying Todo lists.
Lists are implemented as `GenServer` processes and supervised by a
`DynamicSupervisor`.

To get statred, install the dependencies:

    mix deps.get

Then compile the project:

    mix compile

### Todo Interface

This directory contains the `Phoenix` server. To get started, globally install
the `Phoenix` archive:

    mix archive.install hex phx_new 1.4.15

Install the dependencies:

    mix deps.get
    cd assets && npm install

Create a database and SSL certficate:

    docker pull postgres:12.2
    docker run \
        -e POSTGRES_PASSWORD=postgres \
        -e POSTGRES_DB=todo_interface_dev \
        -p 5432:5432 \
        -d postgres

Optionally, create an SSL certificate:

    mix phx.gen.cert

Then start the `Phoenix` app on `localhost:4000`:

    mix phx.server

Run the app inside `IEx`:

    iex -S mix phx.server

### Useful `mix` Commands

Run the tests:

    mix test --cover

Run the formatter:

    mix format

Run the linter:

    mix credo --strict --all

Visualize the dependency tree:

    mix deps.tree

## Working with `Ecto`

Create new table migration config:

    mix ecto.gen.migration <table-name>

Run migration:

    mix ecto.migrate

Rollback migration:

    mix ecto.rollback

## Useful Links

- Credo Style Guide: https://github.com/rrrene/elixir-style-guide
- Ecto *Getting Started* Guide: https://hexdocs.pm/ecto/getting-started.html
