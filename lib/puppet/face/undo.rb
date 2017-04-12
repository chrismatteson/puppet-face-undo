require 'puppet'
require 'puppet/indirector/face'
require 'puppet/configurer'
require 'json'
require 'yaml'

Puppet::Face.define(:undo, '0.0.1') do

  copyright 'Chris Matteson', 2016
  license 'Apache 2 license; see COPYING'

  action :report do
    summary 'Creates and applies a catalog which reverses reversible changes in a specific report on the local system'
    arguments "<report>"

    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    when_invoked do |report, options|
      input = Puppet::FileSystem.read(report, :encoding => 'utf-8')
      input_yaml = YAML::load(input).resource_statuses.values.find_all { |a| a.changed }
      output_json = []
      input_yaml.each do |resource|
        resource_json = {}
        resource_json["title"] = resource.title
        resource_json["file"] = resource.file
        resource_json["line"] = resource.line
        resource_json["tags"] = JSON.parse(resource.tags.to_json)
        resource_json["type"] = resource.resource_type
        events_json = JSON.parse(resource.events.to_json)
        parameters_json = {}
        events_json.each do |event|
          parameters_json["#{event['property']}"] = event['previous_value']
        end
        resource_json["parameters"] = parameters_json
        output_json.push(resource_json)
      end
      catalog = '{"catalog_format":1,"catalog_uuid":"00000000-0000-0000-0000-000000000000","classes":[],"code_id":null,"edges":[],"environment":"production","name":"master.inf.puppet.vm","resources":'
      catalog << output_json.to_json
      catalog << ',"tags":[],"version":"1234567890123456789012345678901234567890"}'
      Puppet.notice "#{catalog}"
      output_file = File.open('/tmp/test.json', 'w+')
      output_file.write(catalog)
      output_file.close
      env = Puppet.lookup(:environments).get(Puppet[:environment])
      Puppet.override(:current_environment => env, :loaders => Puppet::Pops::Loaders.new(env)) do
        begin
          catalog = Puppet::Resource::Catalog.convert_from(Puppet::Resource::Catalog.default_format,catalog)
          catalog = Puppet::Resource::Catalog.pson_create(catalog) unless catalog.is_a?(Puppet::Resource::Catalog)
        rescue => detail
          raise Puppet::Error, "Could not deserialize catalog from pson: #{detail}", detail.backtrace
        end
        configurer = Puppet::Configurer.new
        configurer.run(:catalog => catalog.to_ral, :pluginsync => false)
      end
    end
  end
end
