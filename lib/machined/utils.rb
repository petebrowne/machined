require 'pathname'
require 'sprockets'
require 'tilt'

module Machined
  module Utils
    # Returns a hash of the Tilt templates
    # that are registered and available to use, where
    # the key is the extension the template's registered for.
    def self.available_templates
      @available_templates ||= {}.tap do |templates|
        Tilt.mappings.each_key do |ext|
          begin
            templates[Sprockets::Utils.normalize_extension(ext)] = Tilt[ext]
          rescue LoadError, NameError
            # safely ignore...
          end
        end
      end
    end

    # Returns an `Array` of the child directories that
    # exist within the given +path+. If the path itself
    # does not exist, an emtpy array is returned.
    def self.existent_directories(path)
      pathname = Pathname.new path
      pathname.directory? or return []
      pathname.children.select &:directory?
    end
  end
end
