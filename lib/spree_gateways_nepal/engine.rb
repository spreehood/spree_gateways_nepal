# lib/spree_gateways_nepal/engine.rb
require 'spree/core'
require 'spree_gateway'

module SpreeGatewaysNepal
  class Engine < Rails::Engine
    isolate_namespace Spree
    engine_name 'spree_gateways_nepal'

    config.autoload_paths += %W(#{config.root}/lib)

    # initializer "spree.gateway.payment_methods", after: "spree.register.payment_methods" do |app|
    #   app.config.spree.payment_methods << Spree::Gateway::Khalti
    # end

    config.after_initialize do |app|
      require_dependency 'spree/gateway/khalti'
      app.config.spree.payment_methods << Spree::Gateway::Khalti
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
