require "machined/version"

module Machined
  autoload :CLI,                    "machined/cli"
  autoload :Context,                "machined/context"
  autoload :Environment,            "machined/environment"
  autoload :Server,                 "machined/server"
  autoload :Sprocket,               "machined/sprocket"
  autoload :StaticCompiler,         "machined/static_compiler"
  autoload :Utils,                  "machined/utils"
  
  module Helpers
    autoload :LocalsHelpers,        "machined/helpers/locals_helpers"
    autoload :OutputHelpers,        "machined/helpers/output_helpers"
    autoload :RenderHelpers,        "machined/helpers/render_helpers"
  end
  
  module Processors
    autoload :FrontMatterProcessor, "machined/processors/front_matter_processor"
    autoload :LayoutProcessor,      "machined/processors/layout_processor"
  end
end
