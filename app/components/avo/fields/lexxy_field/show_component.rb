# frozen_string_literal: true

class Avo::Fields::LexxyField::ShowComponent < Avo::Fields::ShowComponent
  # Lexxy content can carry tags the default sanitizer strips (video, audio,
  # tables), so sanitize with Action Text's allowlist, which the lexxy gem
  # extends with those tags.
  def sanitized_value
    if defined?(ActionText::ContentHelper)
      helpers.sanitize rendered_value,
        tags: ActionText::ContentHelper.allowed_tags,
        attributes: ActionText::ContentHelper.allowed_attributes
    else
      helpers.sanitize rendered_value
    end
  end

  private

  # Rich text bodies render their attachments through Active Storage partials,
  # which generate blob/representation URLs. Inside Avo those partials get the
  # engine's router, which can't resolve them ("Can't resolve image into
  # URL"), so swap in a main-app renderer for the render.
  def rendered_value
    value = @field.value

    return value.to_s unless defined?(ActionText::RichText) && value.is_a?(ActionText::RichText)

    original_renderer = ActionText::Content.renderer
    request = helpers.request
    # ApplicationController (not ActionController::Base) because only
    # app-namespaced controllers get the main app's url helpers mixed in.
    renderer_class = defined?(::ApplicationController) ? ::ApplicationController : ActionController::Base
    ActionText::Content.renderer = renderer_class.renderer.new(
      http_host: request.host_with_port,
      https: request.ssl?
    )

    value.to_s
  ensure
    ActionText::Content.renderer = original_renderer if original_renderer
  end
end
