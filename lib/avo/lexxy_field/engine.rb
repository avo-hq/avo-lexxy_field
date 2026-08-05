require_relative "fields/lexxy_field"

module Avo
  module LexxyField
    class Engine < Rails::Engine
      isolate_namespace Avo::LexxyField

      initializer "avo-lexxy_field.init" do |app|
        ActiveSupport.on_load(:avo_boot) do
          Avo.plugin_manager.register "avo-lexxy_field"

          Avo.plugin_manager.register_field :lexxy, Avo::LexxyField::Fields::LexxyField

          Avo.asset_manager.add_stylesheet "avo-lexxy_field/application"
          Avo.asset_manager.add_javascript "avo-lexxy_field/application"
        end

        if app.config.respond_to?(:assets) && defined?(Sprockets)
          app.config.assets.precompile += %w[avo-lexxy_field_manifest.js]
        end
      end
    end
  end
end
