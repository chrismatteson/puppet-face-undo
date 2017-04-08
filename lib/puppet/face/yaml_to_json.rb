require 'json'
require 'yaml'

input_filename = ARGV[0]
output_filename = input_filename.sub(/(yml|yaml)$/, 'json')

input_file = File.open(input_filename, 'r')
input_yml = input_file.read
input_file.close

output_json = JSON.dump(YAML::load(input_yml))

output_file = File.open(output_filename, 'w+')
output_file.write(output_json)
output_file.close
