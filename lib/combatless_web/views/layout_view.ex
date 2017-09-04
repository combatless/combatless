defmodule CombatlessWeb.LayoutView do
  use CombatlessWeb, :view

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
