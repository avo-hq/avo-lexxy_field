require "zeitwerk"
require "avo"
require "lexxy"
require "avo/lexxy_field/version"
require "avo/lexxy_field/engine"

loader = Zeitwerk::Loader.for_gem_extension(Avo)
loader.setup

module Avo
  module LexxyField
  end
end
