require 'test_helper'
require 'generators/forest/block/block_generator'

module Forest
  class Forest::BlockGeneratorTest < Rails::Generators::TestCase
    tests Forest::BlockGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
