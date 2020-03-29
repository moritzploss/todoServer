![Todo](https://github.com/moritzploss/todoServer/workflows/Todo/badge.svg) ![Todo Interface](https://github.com/moritzploss/todoServer/workflows/Todo%20Interface/badge.svg)

# Todo Server

This repo contains an implementation of a stateful and highly concurrent Todo 
list server built with `Elixir`, `OTP`, `Phoenix` and `ets`. The aim of the project
was to deepen my understanding of supervision strategies in `OTP` and resource
management in `Phoenix`.

The server can be used as a backend for a Todo list application. In particular,
the RESTful API allows for CRUD operations on resources of type *user*, *list*
and *entry*. The endpoints are structured as follows:

    localhost:4000/api/v1/users/<user_id>/lists/<list_id>/entries/<entry_id>

For an overview of endpoints, install the dependencies (see below) and run:

    cd todo_interface && mix phx.routes

## Supervision Strategy

One user can have multiple Todo lists. For each list, state is held in memory
and persisted inside a separate *ListServer* process. To manage these
*ListServer* processes, a *ListManager* process is started for each user. In
case a *ListServer* or *ListManager* process crashes, state is recovered via an
`ets` store. Here's what it looks like:

```
Todo.UserManager     ->   Todo.ListManager            ->   Todo.ListServer
-------------------       --------------------------       ------------------------------
- DynamicSupervisor       - DynamicSupervisor              - GenServer
- 1 process               - 1 process for each user        - 1 process for each user list
                          - Registered by user ID in       - Registered by list ID in
                            Registry.TodoUsers               Registry.TodoLists
```

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

## Useful Links

- Credo Style Guide: https://github.com/rrrene/elixir-style-guide