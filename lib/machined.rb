require 'machined/version'

module Machined
  autoload :CLI,                    'machined/cli'
  autoload :Context,                'machined/context'
  autoload :Environment,            'machined/environment'
  autoload :Index,                  'machined/index'
  autoload :Initializable,          'machined/initializable'
  autoload :Server,                 'machined/server'
  autoload :Sprocket,               'machined/sprocket'
  autoload :StaticCompiler,         'machined/static_compiler'
  autoload :Utils,                  'machined/utils'
  autoload :Watcher,                'machined/watcher'
  
  module Helpers
    autoload :AssetTagHelpers,      'machined/helpers/asset_tag_helpers'
    autoload :LocalsHelpers,        'machined/helpers/locals_helpers'
    autoload :OutputHelpers,        'machined/helpers/output_helpers'
    autoload :PageHelpers,          'machined/helpers/page_helpers'
    autoload :RenderHelpers,        'machined/helpers/render_helpers'
  end
  
  module Middleware
    autoload :Static,               'machined/middleware/static'
  end
  
  module Processors
    autoload :FrontMatterProcessor, 'machined/processors/front_matter_processor'
    autoload :LayoutProcessor,      'machined/processors/layout_processor'
  end
end
