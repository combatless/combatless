defmodule CombatlessWeb.InputHelpers do
  use Phoenix.HTML

  def input(form, field, opts \\ []) do
    type = opts[:using] || Phoenix.HTML.Form.input_type(form, field)
    validations = Phoenix.HTML.Form.input_validations(form, field)

    wrapper_opts = [class: "form-group #{state_class(form, field)}"]
    label_opts = [class: "form-control-label"]
    input_opts = Keyword.merge(validations, [class: "form-control #{state_class_input(form, field)}"])

    content_tag :div, wrapper_opts do
      label = label(form, field, humanize(field), label_opts)
      input = input(type, form, field, input_opts)
      error = CombatlessWeb.ErrorHelpers.error_tag(form, field, "form-control-feedback")
      [label, input, error || ""]
    end
  end

  defp state_class(form, field) do
    cond do
      !form.source.action -> ""
      form.errors[field] -> "has-danger"
      true -> "has-success"
    end
  end

  defp state_class_input(form, field) do
    cond do
      !form.source.action -> ""
      form.errors[field] -> "form-control-danger"
      true -> "form-control-success"
    end
  end

  # Implement clauses below for custom inputs.
  # defp input(:datepicker, form, field, input_opts) do
  #   raise "not yet implemented"
  # end

  defp input(type, form, field, input_opts) do
    apply(Phoenix.HTML.Form, type, [form, field, input_opts])
  end
end
