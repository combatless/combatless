defmodule CombatlessWeb.Router do
  use CombatlessWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug CombatlessWeb.Auth.SiteUserSession
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug CombatlessWeb.Auth.Narnode, allow: [:admin]
  end

  pipeline :mod do
    plug CombatlessWeb.Auth.Narnode, allow: [:admin, :mod]
  end

  pipeline :user do
    plug CombatlessWeb.Auth.Narnode, allow: [:admin, :mod, :user]
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
    get "/namechange", NameChangeController, :request
    post "/namechange", NameChangeController, :create_request
    get "/hiscores", HiscoreController, :index
    get "/current", CurrentTopController, :index
  end

  scope "/auth", CombatlessWeb.Auth do
    pipe_through :browser

    delete "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/api", CombatlessWeb do
    pipe_through :api

    get "/ehp/:id", GraphController, :ehp
  end

  scope "/mod", CombatlessWeb.Admin, as: :mod do
    pipe_through [:browser, :mod]

    resources "/name_changes", NameChangeController, except: [:delete]
  end

  scope "/admin", CombatlessWeb.Admin do
    pipe_through [:browser, :admin]

    get "/", PageController, :index

    resources "/datapoints", DatapointController
    resources "/site_users", SiteUserController
  end
end
