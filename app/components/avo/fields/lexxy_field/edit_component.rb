# frozen_string_literal: true

class Avo::Fields::LexxyField::EditComponent < Avo::Fields::EditComponent
  def editor_tag
    if helpers.respond_to?(:lexxy_rich_textarea_tag)
      # Rails 8.0/8.1: the lexxy gem prepends its own tag helper.
      helpers.lexxy_rich_textarea_tag field_name, @field.value, editor_options
    else
      # Rails 8.2+: Action Text renders through the editor adapter, which the
      # lexxy gem registers as the default editor.
      helpers.rich_textarea_tag field_name, @field.value, editor_options
    end
  end

  private

  def field_name
    @form.field_name(@field.id)
  end

  def editor_options
    {
      id: @form.field_id(@field.id),
      class: class_names("lexxy-content", @field.get_html(:classes, view: view, element: :input)),
      placeholder: @field.placeholder,
      disabled: disabled?,
      data: @field.get_html(:data, view: view, element: :input),
      style: @field.get_html(:style, view: view, element: :input)
    }.tap do |options|
      options[:attachments] = "false" if @field.attachments_disabled
    end
  end
end
