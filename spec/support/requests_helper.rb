module Requests
  module Helpers
    def json
      json = JSON.parse(response.body)
      json = json.symbolize_keys if json.respond_to?(:symbolize_keys)
      json
    end
  end
end
