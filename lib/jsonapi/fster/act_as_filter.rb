module Jsonapi
  module Fster
    module ActAsFilter
      extend ActiveSupport::Concern

      class_methods do
        def has_many_relationship?(attr)
          reflections[attr].is_a? ActiveRecord::Reflection::HasManyReflection
        end

        def has_one_relationship?(attr)
          reflections[attr].is_a? ActiveRecord::Reflection::HasOneReflection
        end

        def belongs_to_relationship?(attr)
          reflections[attr].is_a? ActiveRecord::Reflection::BelongsToReflection
        end

        def has_many_through_relationship? attr
          reflections[attr].is_a?(ActiveRecord::Reflection::ThroughReflection) &&
          reflections[attr].__send__(:delegate_reflection).is_a?(ActiveRecord::Reflection::HasManyReflection)
        end

        def has_relationship? attr
          reflections[attr].present?
        end

        # version 0.1 only support 2 level. Example: course.course_translations.local = vi, course.name
        def jsonapi_filter params, joins_clause = 'joins'
          query = all

          params.each do |key, value|
            filter_condition = Jsonapi::Fster::FilterCondition.new(self, key, value)
            query = query.where(filter_condition.where_hash)

            joins_hash = filter_condition.joins_hash
            query = query.public_send(joins_clause, joins_hash) if joins_hash.present?
          end

          query
        end
      end
    end
  end
end
