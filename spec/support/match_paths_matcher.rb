# Determines if the given `Array` of paths
# matches the expected `Array` of paths. For consistency,
# each path is converted to a string for comparison. Also,
# the expected paths can be joined with a root path, using
# the `with_root` method.
RSpec::Matchers.define :match_paths do |expected|
  match do |actual|
    expected.map!(&:to_s)
    actual.map!(&:to_s)
    expected.map! { |path| File.join(@root, path) } if @root
    
    actual == expected
  end
  
  chain :with_root do |root|
    @root = root.to_s
  end
  
  diffable
end
