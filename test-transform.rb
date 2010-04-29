require 'yaml'
require 'transform-results'

results = YAML.load_file( 'example-hash.yml' )
TransformResults.transform(results, $stdout)