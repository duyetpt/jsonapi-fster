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

        def has_many_through_relation? attr
          reflections[attr].is_a?(ActiveRecord::Reflection::ThroughReflection) &&
          reflections[attr].__send__(:delegate_reflection).is_a?(ActiveRecord::Reflection::HasManyReflection)
        end

        # version 0.1 only support 2 level. Example: course.course_translations.local = vi, course.name
        def where_jsonapi_filter params
          query = all
          params.each do |key, value|
            key = key.to_s
            value = value.to_s.split(',')
            if column_names.include? key
              # name
              query = query.where(key => value)
            else
              if belongs_to_relationship? key
                # course
                query = query.where("#{key}_id" => value)
              elsif has_one_relationship? key
                # course
                query = query.joins(key.to_sym).where(key.pluralize => {id: value})
              elsif has_many_relationship? key
                # courses
                query = query.joins(key.to_sym).where(key => {id: value})
              else
                attrs = key.split('.')
                model1 = attrs[0]
                attr = attrs.last
                model1_class = model1.classify.constantize
                if attrs.size == 2
                  if model1_class.column_names.include? attr
                    # course.name
                    query = query.joins(model1.to_sym).where(model1.pluralize => {attr => value})
                  elsif model1_class.belongs_to_relationship? attr
                    # course.amenity
                    query = query.joins(model1.to_sym).where(model1.pluralize => {"#{attr}_id" => value})
                  elsif model1_class.has_one_relationship? attr
                    # course.amenity
                    query = query.joins(model1.to_sym => attr.to_sym).where(attr.pluralize => {id: value})
                  elsif model1_class.has_many_relationship? attr
                    # course.amenities
                    query = query.joins(model1.to_sym => attr.to_sym).where(attr => {id: value})
                  elsif model1_class.has_many_through_relation? attr
                    # course.categories through categories_courses
                    through_table = model1_class.reflections[attr].options[:through]
                    query = query.joins(model1.to_sym => through_table).where(through_table => {"#{attr.singularize}_id": value})
                  end
                elsif attrs.size == 3
                  model2 = attrs[1]
                  query = query.joins(model1.to_sym => model2.to_sym)
                  if model1_class.belongs_to_relationship?(model2) || model1_class.has_one_relationship?(model2)
                    # course.amenity.name = 'ab'
                    query = query.joins(model1.to_sym => model2.to_sym).where(model2.pluralize => {attr => value})
                  elsif model1_class.has_many_relationship?(model2) || model1_class.has_many_through_relation?(model2)
                    # course.amenities.code = 'ab'
                    query = query.where(model2 => {attr => value})
                  end
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
