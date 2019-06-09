module Jsonapi
  module Fster
    class NoneRelationshipError < StandardError
      attr_reader :pair

      def initialize(pair)
        super
        @pair = pair
      end

      def message
        "#{pair[0]} do not has any relate with #{pair[1]}."
      end
    end
  end
end
