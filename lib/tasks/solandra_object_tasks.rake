require 'net/http'
namespace :so do
  desc 'Create the Solandra core using the SO schema'
  task :create_solr => :environment do
    schema_file = File.read(File.join(File.dirname(__FILE__),"..","..","config","schema.xml"))
    sunspot_config = YAML.load_file(Rails.root.join("config","sunspot.yml"))[Rails.env]["solr"]
    Net::HTTP.start(sunspot_config["hostname"], sunspot_config["port"]) do |http|
      path = sunspot_config["path"].split(/\//).insert(2, "schema").join("/")
      http.post(path, schema_file)
    end
  end
  
  desc 'Reindex all Cassandra data into Solandra'
  task :reindex => :environment do
    Sunspot.remove_all!
    Rails.root.join("app","models").entries.grep(/\.rb$/).each do |e|
      e.to_s.split(/\./).first.camelize.constantize.reindex
    end
  end
end