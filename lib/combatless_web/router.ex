defmodule CombatlessWeb.Router do
  use CombatlessWeb, :router

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

  scope "/", CombatlessWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/accounts", ProfileController, except: [:new, :show, :create, :update]
    get "/accounts/:name", ProfileController, :show
    get "/accounts/:name/create", ProfileController, :create
    get "/accounts/:name/update", ProfileController, :update
    get "/accounts/:name/:period", ProfileController, :show
    resources "/datapoints", DatapointController
  end

  scope "/admin", CombatlessWeb do

  end

  # Other scopes may use custom stacks.
  # scope "/api", CombatlessWeb do
  #   pipe_through :api
  # end
end
