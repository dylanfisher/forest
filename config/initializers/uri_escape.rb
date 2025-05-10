# Backport URI.escape for compatibility with third-party gems
unless URI.respond_to?(:escape)
  URI.singleton_class.send(:define_method, :escape) do |str|
    if str.include?('?') # If it's a query string, escape it
      URI.encode_www_form_component(str)
    else
      str # Return the string as is for non-query URLs
    end
  end
end
