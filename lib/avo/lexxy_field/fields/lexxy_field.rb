module Avo
  module LexxyField
    module Fields
      class LexxyField < Avo::Fields::BaseField
        attr_reader :always_show

        def initialize(id, **args, &block)
          super(id, **args, &block)

          hide_on :index

          @always_show = args[:always_show] || false
          @attachments_disabled = args[:attachments_disabled]
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
