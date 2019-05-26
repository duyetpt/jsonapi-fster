module Jsonapi
  module Fster
    module ActAsSorting
      extend ActiveSupport::Concern

      class_methods do
        # created_at
        def jsonapi_asc_order_query(attr)
          if column_names.include? attr
            "#{attr} asc"
          else
            ""
          end
        end

        # -created_at
        def jsonapi_desc_order_query(attr)
          if column_names.include? attr
            "#{attr} desc"
          else
            ""
          end
        end

        def build_jsonapi_order_querys(query_tring = '-created_at')
          return '' if query_tring.blank?

          sort_attrs = query_tring.split(',').map(&:strip)
          sort_attrs.map do |attr|
            if attr.start_with?('-')
              jsonapi_desc_order_query(attr.remove('-'))
            else
              jsonapi_asc_order_query(attr)
            end
          end.select {|query| query.present?}
        end

        def jsonapi_order(query_tring)
          order(build_jsonapi_order_querys(query_tring))
        end
      end
    end
  end
end
