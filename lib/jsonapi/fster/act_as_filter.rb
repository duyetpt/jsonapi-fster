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
        def where_jsonapi_filter params, joins_clause = 'joins'
          query = all
          params.each do |key, value|
            key = key.to_s
            value = value.to_s.split(',')
            if column_names.include? key
              query = query.where(key => value)
            else
              joins_hash = JoinsClauseBuilder.new(key, self).build!
              query = query.joins(joins_hash)

              conditions = key.split('.')
              if joins_hash.is_a?(Symbol) && conditions.size == 1
                query = query.where(key.pluralize => {id: value})
              else
                if conditions[-2].classify.constantize.column_names.include? conditions[-1]
                  query = query.where(conditions[-2].pluralize => {conditions[-1] => value})
                else
                  query = query.where(conditions[-1].pluralize => {id: value})
                end
              end
            end
          end

          query
        end
      end
    end
  end
end
