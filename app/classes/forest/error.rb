class Forest::Error < StandardError
  attr_reader :object

  def initialize(msg= 'Forest::Error', object = nil)
    @object = object
    super msg
  end
end

# begin
#   raise MyError.new("my message", "my thing")
# rescue => e
#   puts e.thing # "my thing"
# end
# end
