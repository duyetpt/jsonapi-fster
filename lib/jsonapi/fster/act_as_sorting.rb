module Jsonapi
  module Fster
    module ActAsSorting
      extend ActiveSupport::Concern

      class_methods do
        def jsonapi_order(query_tring)
          builder = Jsonapi::Fster::OrderClauseBuilder.new(query_tring, self)
          query = order(builder.build_sort_values)
          # need joins with table to can order
          # only support 1 level
          builder.joins_values.each {|value| query = query.joins(value.to_sym)}
          query
        end
      end
    end
  end
end
