require 'puppet/indirector/face'
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

    when_invoked do |report|
      input_yaml = YAML::load(report).resource_statuses.values.find_all { |a| a.changed }
      Puppet.notice "#{input_yaml}"
      output_json = []
      input_yaml.each do |resource|
        Puppet.notice "hello #{resource}"
        resource_json = {}
        resource_json["title"] = resource.title
        resource_json["file"] = resource.file
        resource_json["line"] = resource.line
        resource_json["tags"] = JSON.parse(resource.tags.to_json)
        resource_json["type"] = resource.resource_type
        events_json = JSON.parse(resource.events.to_json)
        Puppet.notice "#{events_json}"
        parameters_json = {}
        events_json.each do |event|
          parameters_json["#{event['property']}"] = event['previous_value']
        end
        resource_json["parameters"] = parameters_json
        Puppet.notice "#{resource_json}"
        output_json.push(resource_json)
      end
      Puppet.notice "#{output_json}"
      output_file = File.open('/tmp/test.json', 'w+')
      output_file.write('{"catalog_format":1,"catalog_uuid":"00000000-0000-0000-0000-000000000000","classes":[],"code_id":null,"edges":[],"environment":"production","name":"master.inf.puppet.vm","resources":')
      output_file.close
      output_file = File.open('/tmp/test.json', 'a')
      output_file.write(output_json.to_json)
      output_file.write(',"tags":[],"version":"1234567890123456789012345678901234567890"}')
      output_file.close
    end
  end
end
