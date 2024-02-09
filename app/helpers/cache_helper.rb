module CacheHelper
  def cache_key_for(collection)
    count = collection.try(:count) || 1
    if collection.is_a? Array
      return if collection.blank?
      max_updated_at = collection.reject(&:blank?).max_by(&:updated_at).updated_at.try(:to_i)
      "#{collection.first.model_name.plural}/all-#{count}-#{max_updated_at}"
    elsif collection.try :updated_at
      "#{collection.model_name.plural}/all-#{count}-#{collection.updated_at.try(:to_i)}"
    else
      max_updated_at = collection.maximum(:updated_at).try(:to_i)
      "#{collection.model_name.plural}/all-#{count}-#{max_updated_at}"
    end
  end

  def cache_digest_for(stringable)
    Digest::MD5.hexdigest(stringable.to_s)
  end

  def application_cache_key
    @_application_cache_key ||= Setting.application_cache_key
  end
end
