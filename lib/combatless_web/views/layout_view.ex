defmodule CombatlessWeb.LayoutView do
  use CombatlessWeb, :view

  def active_class(conn, path) do
    current_path = Path.join(["/" | conn.path_info])
    if path == current_path, do: "active"
  end

  def nav_item(conn, text, path, opts \\ []) do
    class =
      [opts[:class], "nav-item", active_class(conn, path)]
      |> Enum.filter(& &1)
      |> Enum.join(" ")

    opts = Keyword.put(opts, :class, class)
    link = link(text, to: path, class: "nav-link")
    content_tag(:li, link, opts)
  end

  def get_search_bar_tags() do
    form_tag "/accounts", method: "get", class: "input-group search" do
      [
        tag(
          :input,
          type: "search",
          name: "name",
          class: "input-group-field",
          required: true,
          maxlength: 12,
          placeholder: "username..."
        ),
        content_tag(:div, class: "input-group-button") do
          tag(:input, class: "button", type: "submit", value: "search")
        end
      ]
    end
  end
end
