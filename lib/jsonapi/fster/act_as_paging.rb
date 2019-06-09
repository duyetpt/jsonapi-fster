module Jsonapi
  module Fster
    module ActAsPaging
      extend ActiveSupport::Concern

      class_methods do
        def jsonapi_paginate(params = {})
          if params[:page] && respond_to?(:paginate)
            per_page = params[:per_page] || self.try(:per_page) || WillPaginate.per_page
            paginate(page: params[:page], per_page: per_page)
          else
            self
          end
        end
      end
    end
  end
end
