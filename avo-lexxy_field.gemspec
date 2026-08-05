$:.push File.expand_path("lib", __dir__)

require "avo/lexxy_field/version"

Gem::Specification.new do |spec|
  spec.name = "avo-lexxy_field"
  spec.version = Avo::LexxyField::VERSION
  spec.summary = "Lexxy rich text field for Avo."
  spec.description = "Adds a lexxy field to Avo, powered by Basecamp's Lexxy editor for Action Text."
  spec.authors = ["Adrian Marin"]
  spec.email = "adrian@adrianthedev.com"
  spec.license = "MIT"

  spec.homepage = "https://github.com/avo-hq/avo-lexxy_field"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,lib}/**/*", "README.md", "avo-lexxy_field.gemspec"]
  end
  spec.files.reject! { |file_name| file_name.include?("app/javascript") }

  spec.add_dependency "avo", ">= 4.0"
  # Lexxy requires Rails >= 8.0.2, so this field does too.
  spec.add_dependency "lexxy", ">= 0.9"
end
