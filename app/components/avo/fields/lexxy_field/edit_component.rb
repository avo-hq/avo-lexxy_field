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

  # A picked blob lands in the content as an attachment, so a field with
  # attachments disabled has nowhere to put it.
  def media_library?
    !@field.attachments_disabled && Avo::MediaLibrary.configuration.visible?
  end

  def media_library_path
    helpers.avo.attach_media_path(
      controller_selector: unique_selector,
      controller_name: "lexxy-field"
    )
  end

  def unique_id
    @unique_id ||= "lexxy_#{@field.id}_#{SecureRandom.hex(4)}"
  end

  def unique_selector = "[data-unique-selector=#{unique_id}]"

  private

  def field_name
    @form.field_name(@field.id)
  end

  def editor_options
    @field.editor_attributes.symbolize_keys.merge(
      id: @form.field_id(@field.id),
      class: class_names("lexxy-content", @field.get_html(:classes, view: view, element: :input)),
      placeholder: @field.placeholder,
      disabled: disabled?,
      data: @field.get_html(:data, view: view, element: :input),
      style: @field.get_html(:style, view: view, element: :input)
    ).tap do |options|
      options[:attachments] = "false" if @field.attachments_disabled
    end
  end
end
