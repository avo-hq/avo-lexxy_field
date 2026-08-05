# frozen_string_literal: true

class Avo::Fields::LexxyField::ShowComponent < Avo::Fields::ShowComponent
  # Lexxy content can carry tags the default sanitizer strips (video, audio,
  # tables), so sanitize with Action Text's allowlist, which the lexxy gem
  # extends with those tags.
  def sanitized_value
    if defined?(ActionText::ContentHelper)
      helpers.sanitize @field.value.to_s,
        tags: ActionText::ContentHelper.allowed_tags,
        attributes: ActionText::ContentHelper.allowed_attributes
    else
      helpers.sanitize @field.value.to_s
    end
  end
end
