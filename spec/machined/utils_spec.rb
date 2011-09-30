require "spec_helper"

describe Machined::Utils do
  describe ".avialable_templates" do
    it "returns the available Tilt templates" do
      Machined::Utils.instance_variable_set "@available_templates", nil
      available_templates = Machined::Utils.available_templates
      available_templates[".markdown"].should be(Tilt::RDiscountTemplate)
      available_templates[".md"].should be(Tilt::RDiscountTemplate)
      available_templates[".haml"].should be(Tilt::HamlTemplate)
      available_templates[".erb"].should be(Tilt::ERBTemplate)
    end
  end
  
  describe ".existent_directories" do
    it "returns directories that exist in the given path" do
      within_construct do |c|
        c.directory "dir1"
        c.directory "dir2"
        c.directory "dir3"
        
        Machined::Utils.existent_directories(c).should match_paths(%w(dir1 dir2 dir3)).with_root(c)
      end
    end
    
    it "returns an empty array when the path is not a directory" do
      within_construct do |c|
        Machined::Utils.existent_directories(c.join("blank")).should == []
      end
    end
  end
  
  describe ".join" do
    it "joins the root with the path" do
      within_construct do |c|
        assets = c.directory "assets"
        Machined::Utils.join(c, "assets").should == assets
      end
    end
    
    it "returns the path if it is absolute" do
      within_construct do |c|
        root   = c.directory "app"
        assets = c.directory "assets"
        Machined::Utils.join(root, assets).should == assets
      end
    end
  end
end
