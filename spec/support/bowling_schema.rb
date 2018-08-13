RSpec::Matchers.define :match_response_bowling_schema do |schema|
   match do |response|
      schema_path = YAML.load(File.open("spec/schema/api/#{schema}.yml"))
     JSON::Validator.validate!(schema_path, response.body)
   end
end
