module Jsonapi
  module Fster
    class FilterCondition
      BETWEEN_OPERATOR = 'between'
      OPERATORS = [BETWEEN_OPERATOR]

      attr_reader :condition, :raw_value, :base_class
      attr_accessor :condition_items, :value_items, :condition_items_without_operators, :condition_class, :condition_column

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
        @condition_items_without_operators ||= condition_items.reject {|item| OPERATORS.include?(item)}
      end

      # only support integer and datetime
      def is_between_operator?
        @condition_items[-1] == BETWEEN_OPERATOR
      end

      def value_items
        if @value_items.blank?
          values =
            if @raw_value.is_a? String
              @raw_value.split(',')
            elsif @raw_value.is_a? Array
              @raw_value
            else
              [@raw_value]
            end

          type = condition_class.columns_hash[condition_column].type
          @value_items =
            case type
            when :integer
              values.map(&:to_i)
            when :datetime
              values.map {|value| DateTime.parse(value)}
            else
              values
            end
        end

        @value_items
      end

      def where_value
        is_between_operator? ? (value_items[0]..value_items[1]) : value_items
      end

      def condition_class
        column = condition_items_without_operators[-1]
        @condition_class ||=
          if condition_items_without_operators.size == 1
            if @base_class.column_names.include?(column)
              @base_class
            else
              look_up_class! column
            end
          else
            association_name = condition_items_without_operators[-2]
            pre_class = look_up_class! association_name
            pre_class.column_names.include?(column) ? pre_class : look_up_class!(column)
          end
      end

      def condition_column
        column = condition_items_without_operators[-1]
        @condition_column ||= column.pluralize == condition_class.table_name ? 'id' : column
      end

      def where_hash
        unless condition_class.column_names.include? condition_column
          raise ActiveRecord::StatementInvalid.new("Column #{condition_column} is not exists on table #{condition_class.table_name}")
        end

        {condition_class.table_name => {condition_column => where_value}}
      end

      def joins_hash
        column = condition_items_without_operators[-1]
        if condition_items_without_operators.size == 1 && @base_class.column_names.include?(column)
          nil
        else
          JoinsClauseBuilder.new(condition_items_without_operators, base_class).build!
        end
      end

      private

      def look_up_class!(column)
        table_name = column.pluralize
        if ActiveRecord::Base.connection.tables.include? table_name
          column.classify.constantize
        else
          raise ActiveRecord::StatementInvalid.new("Not exist table #{table_name}")
        end
      end
    end
  end
end
