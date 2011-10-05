require "spec_helper"

describe Machined::Helpers::AssetTagHelpers do
  describe "#asset_path" do
    it "returns javascript paths" do
      within_construct do |c|
        c.file "assets/javascripts/main.js"
        c.file "pages/index.haml", "= asset_path(:js, 'main')"
        
        machined.pages["index.html"].to_s.should != %r(^/assets/main.js)
      end
    end
  end
end
