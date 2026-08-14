module Avo
  module LexxyField
    module Fields
      class LexxyField < Avo::Fields::BaseField
        # Avo >= 4.2 lets the editor viewport be resized with a persisted height.
        resizable_editor target: "lexxy-editor > .lexxy-editor__content" if respond_to?(:resizable_editor)

        # Lexxy's per-editor options, which it reads off the element as
        # dasherized attributes and JSON-parses. `attachments` is omitted on
        # purpose — `attachments_disabled` below owns it. See
        # https://lexxy.dev/docs/ for what each one takes.
        EDITOR_OPTIONS = %i[
          preset
          markdown
          rich_text
          multi_line
          headings
          toolbar
          highlight
          permitted_attachment_types
        ].freeze

        attr_reader :always_show

        def initialize(id, **args, &block)
          super(id, **args, &block)

          hide_on :index

          @always_show = args[:always_show] || false
          @attachments_disabled = args[:attachments_disabled]
          @editor_options = args.slice(*EDITOR_OPTIONS)
        end

        # The editor options as element attributes. Anything that isn't already
        # a string goes over as JSON, which is what Lexxy parses it back from.
        def editor_attributes
          @editor_options.to_h do |name, value|
            [name.to_s.dasherize, value.is_a?(String) || value.is_a?(Symbol) ? value.to_s : value.to_json]
          end
        end

        # Identify if field is bonded to a rich text model attribute
        def is_action_text?
          return false if !defined?(ActionText::RichText) || record.nil? || !record.respond_to?(id)

          record.send(id).is_a?(ActionText::RichText)
        end

        def attachments_disabled
          # Return the value of attachments_disabled if explicitly provided
          return @attachments_disabled unless @attachments_disabled.nil?

          # Lexxy uploads through Active Storage direct uploads and relies on
          # Action Text to attach the blobs to the record on save. On plain
          # columns the uploads would remain orphaned blobs, so disable them.
          !is_action_text?
        end

        def view_component_namespace
          "Avo::Fields::LexxyField"
        end

        def component_for_view(view)
          view = Avo::ViewInquirer.new(view)

          if view.edit? && (is_readonly? || is_disabled?)
            Avo::Fields::LexxyField::ShowComponent
          else
            super
          end
        end
      end
    end
  end
end
