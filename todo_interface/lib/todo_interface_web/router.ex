defmodule TodoInterfaceWeb.Router do
  use TodoInterfaceWeb, :router

  @crud [:index, :show, :create, :update, :delete]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TodoInterfaceWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/users/:user_id/lists/new", TodoInterfaceWeb do
    pipe_through :browser

    get "/", ListController, :new
  end

  scope "/api/v1", TodoInterfaceWeb do
    pipe_through :api

    resources "/users", UserController, only: @crud do
      resources "/lists", ListController, only: @crud do
        resources "/entries", EntryController, only: @crud
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TodoInterfaceWeb do
  #   pipe_through :api
  # end
end
