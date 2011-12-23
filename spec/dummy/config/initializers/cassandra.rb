require 'yaml'
config = YAML.load_file(Rails.root.join("config", "cassandra.yml"))
$cassandra = CassandraObject::Base.establish_connection(config[Rails.env].symbolize_keys)
