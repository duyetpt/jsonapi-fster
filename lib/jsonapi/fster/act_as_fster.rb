module Jsonapi
  module Fster
    module ActAsFster
      extend ActiveSupport::Concern
      include Jsonapi::Fster::ActAsSorting
      include Jsonapi::Fster::ActAsFilter
      include Jsonapi::Fster::ActAsPaging

      class_methods do
        def where_jsonapi(params = {})
          query = all

          if params[:filters]
            query = query.jsonapi_filter(params[:filters])
          end

          if params[:sort]
            query = query.jsonapi_order(params[:sort])
          end

          if params[:page] && respond_to?(:paginate)
            query = query.jsonapi_paginate(params)
          end

          query
        end
      end
    end
  end
end
