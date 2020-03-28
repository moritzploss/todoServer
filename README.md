![Todo](https://github.com/moritzploss/todoServer/workflows/Todo/badge.svg) ![Todo Interface](https://github.com/moritzploss/todoServer/workflows/Todo%20Interface/badge.svg)

# Todo Server

This repo contains an implementation of a stateful and highly concurrent Todo 
list server built with `Elixir`, `OTP`, and `Phoenix`. The aim of the project
was to deepen my understanding of supervision strategies in `OTP` and to explore
`Phoenix`. The resulting app can serve as a simple backend for a Todo list
application.

In particular, the RESTful API allows for CRUD operations on resources of
type `user`, `list` and `entry`. The endpoints are structured as follows:

    localhost:4000/api/v1/users/<user_id>/lists/<list_id>/entries/<entry_id>

For example, create a new Todo list for a user with ID `test123` via a
POST request to the following endpoint, including the `name` of the list in the
request body:

    localhost:4000/api/v1/users/test123/lists/

One user can have multiple Todo lists. For each list, state is being persisted
inside a separate `GenServer` process. In case of a crash, state is recovered
via an `ets` store. The supervision strategy works as follows:

```
Todo.UserManager     ->   Todo.ListManager            ->   Todo.ListServer
-------------------       --------------------------       ------------------------------
- DynamicSupervisor       - DynamicSupervisor              - GenServer
- 1 process               - 1 process for each user        - 1 process for each user list
                          - Registered by user ID in       - Registered by list ID in
                            Registry.TodoUsers               Registry.TodoLists
```

This strategy could be improved in the future as restarting crashed
`ListManager` processes isn't trivial (list IDs are randomly generated at
runtime, and don't persist if a `ListManager` crashes).

## Getting Started

### Basic Setup

The following assumes that you have a working installation of `Elixir`
(including `mix`) and `Node.js` (including `npm`).

### Todo

This directory contains all logic related to creating, modifying and supervising
Todo lists.

To get started, install the dependencies:

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
