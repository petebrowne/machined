require "pathname"

module Machined
  module Utils
    # Returns an `Array` of the child directories that
    # exist within the given +path+. If the path itself
    # does not exist, an emtpy array is returned.
    def self.existent_directories(path)
      pathname = Pathname.new path
      pathname.directory? or return []
      pathname.children.select &:directory?
    end
    
    # Joins the +root+ path with +path+. If +path+
    # is absolute, it is returned without joining.
    def self.join(root, path)
      pathname = Pathname.new path
      pathname.absolute? and return pathname
      Pathname.new(root).join pathname
    end
  end
end
