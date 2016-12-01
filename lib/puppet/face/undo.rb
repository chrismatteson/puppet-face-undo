require 'puppet/face'
require 'json'
require 'yaml'

Puppet::Face.define(:undo, '0.0.1') do

  copyright 'Chris Matteson', 2016
  license 'Apache 2 license; see COPYING'

  action :report do
    summary 'Creates and applies a catalog which reverses reversible changes in a specific report on the local system'

    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    arguments '<report>'

    when_invoked do |report|
      puppetdb = PuppetDB::Connection.new options[:host], options[:port], !options[:no_ssl]
      parser = PuppetDB::Parser.new
      if options[:facts] != ''
        facts = options[:facts].split(',')
        factquery = parser.facts_query(query, facts)
      else
        facts = [:all]
        factquery = parser.parse(query, :facts)
      end
      parser.facts_hash(puppetdb.query(:facts, factquery, :extract => [:certname, :name, :value]), facts)
    end
  end
end
