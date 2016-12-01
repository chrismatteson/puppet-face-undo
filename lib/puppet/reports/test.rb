require 'puppet'
require 'json'
require 'yaml'
Puppet::Reports.register_report(:test) do

desc <<-DESC
A new report processor.
DESC

  def process
    Puppet.notice "Puppet Test #{self.kind} run on #{self.host} ended with status #{self.status}"
    Puppet.notice "Report statuses #{self.resource_statuses.values.find_all { |a| a.changed }.to_yaml}"
    output_json = JSON.dump(YAML::load(self.resource_statuses.values.find_all { |a| a.changed }.to_yaml))
    Puppet.notice "#{output_json}"
    output_file = File.open('/tmp/test.json', 'w+')
    output_file.write(output_json)
    output_file.close
  end
end
