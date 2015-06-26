module Pages
  $:.unshift(Rails.root.join('features', 'pages'))

  require 'base'

  Dir['features/pages/*_page.rb'].each do |file|
    method_name = File.basename(file).split('.').first
    require method_name
    define_method method_name do
      page = instance_variable_get("@#{method_name}")
      return page if page
      instance_variable_set("@#{method_name}",  "Pages::#{method_name.camelize}".constantize.new)
    end

  end
end
Spinach::FeatureSteps.send(:include, Pages)
