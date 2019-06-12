module Jsonapi
  module Fster
    class OrderClauseBuilder
      def initialize(raw_clause, base_class)
        @raw_clause = raw_clause
        @base_class = base_class
      end

      def sort_items
        @sort_items ||= @raw_clause.split(',')
      end

      def jsonapi_asc_order_query(attr)
        "#{attr} asc"
      end

      # -created_at
      def jsonapi_desc_order_query(attr)
        "#{attr} desc"
      end

      def build_sort_values
        sort_items.map do |attr|
          if attr.start_with?('-')
            jsonapi_desc_order_query(attr.remove('-'))
          else
            jsonapi_asc_order_query(attr)
          end
        end.select {|query| query.present?}
      end

      def joins_values
        tables =
          sort_items.map {|item| item.remove('-').split('.')}
            .select {|item_parts| item_parts.size > 1}
            .map {|item_parts| item_parts[0]}
            .uniq
        @base_class.reflections.keys.select {|ass| tables.include? ass.pluralize}
      end
    end
  end
end
