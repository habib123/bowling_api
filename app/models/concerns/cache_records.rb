module CacheRecords
  extend ActiveSupport::Concern

  def delete_from_cache
    Rails.cache.delete([self.class.name, self.id])
  end

  module ClassMethods
    def cached_id id
      Rails.cache.fetch([name, id]) { self.find id }
    end
  end
end
