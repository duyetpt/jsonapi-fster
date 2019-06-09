module Jsonapi
  module Fster
    class FilterCondition
      BETWEEN_OPERATOR = 'between'
      OPERATORS = [BETWEEN_OPERATOR]

      attr_reader :condition, :raw_value, :base_class
      attr_accessor :condition_items, :value_items, :condition_items_without_operators

      # condition is a string a.b.c
      # value is a string a,b,c
      def initialize(base_class, condition, value)
        @condition = condition
        @raw_value = value
        @base_class = base_class
      end

      def condition_items
        @condition_items ||= @condition.to_s.split('.')
      end

      def condition_items_without_operators
        @condition_items_without_operators ||=
          condition_items.reject {|item| OPERATORS.include?(item)}
      end

      # only support integer and datetime
      def is_between_operator?
        @condition_items[-1] == BETWEEN_OPERATOR
      end

      def value_items
        if @value_items.blank?
          values = @raw_value.split(',')
          @value_items =
            values.map do |value|
              value.match(/\d{4}-\d{2}-\d{2}/) ? DateTime.parse(value) : value
            end
        end
        @value_items
      end

      def where_value
        if is_between_operator?
          if value_items[0].is_a? DateTime
            (value_items[0]..value_items[1])
          else
            (value_items[0].to_i..value_items[1].to_i)
          end
        else
          value_items
        end
      end

      def where_hash
        column = condition_items_without_operators[-1]
        if condition_items_without_operators.size == 1
          if @base_class.column_names.include? column
            {column => where_value}
          else
            {column.pluralize => {id: where_value}}
          end
        else
          if condition_items_without_operators[-2].classify.constantize.column_names.include? column
            {condition_items_without_operators[-2].pluralize => {column => where_value}}
          else
            {column.pluralize => {id: where_value}}
          end
        end
      end

      def joins_hash
        column = condition_items_without_operators[-1]
        if condition_items_without_operators.size == 1 && @base_class.column_names.include?(column)
          nil
        else
          JoinsClauseBuilder.new(condition_items_without_operators, base_class).build!
        end
      end
    end
  end
end
