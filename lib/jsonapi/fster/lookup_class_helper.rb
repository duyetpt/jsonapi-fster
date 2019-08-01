module Jsonapi
  module Fster
    module LookupClassHelper
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
