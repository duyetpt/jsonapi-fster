module Jsonapi
  module Fster
    class JoinsClauseBuilder
      attr_reader :raw_query, :base_class

      def initialize(raw_query, base_class)
        @raw_query = raw_query
        @base_class = base_class
      end

      def build_pairs
        arr = @raw_query.split('.')
        return [] if arr.is_a? String

        (0..(arr.length - 2)).map do |index|
          [arr[index], arr[index + 1]]
        end
      end

      def build_joins_hash_pair!(pair)
        p1_class = pair[0].classify.constantize
        return if p1_class.column_names.include? pair[1]

        joins_hash =
          if p1_class.belongs_to_relationship?(pair[1]) ||
            p1_class.has_one_relationship?(pair[1]) ||
            p1_class.has_many_relationship?(pair[1])
            { pair[0].to_sym => pair[1].to_sym }
          elsif p1_class.has_many_through_relationship? pair[1]
            through_table = p1_class.reflections[pair[1].to_s].options[:through]
            { pair[0].to_sym => { through_table => pair[1].singularize.to_sym } }
          else
            raise NoneRelationshipError.new(pair)
          end
        joins_hash
      end

      # example
      # a: :b, b: :c, c: :d, d: {de: :e}
      # => d: { de: :e }
      # => c: { d: { de: :e } }
      # => b: { c: { d: { de: :e } } }
      # => a: { b: { c: { d: { de: :e } } } }
      def build_joins_hash_pairs!
        @pairs = build_pairs
        hash_pairs = @pairs.map {|pair| build_joins_hash_pair!(pair)}.select(&:present?)

        if @pairs.size == 1 && hash_pairs.empty?
          return @pairs[0][0].to_sym if @base_class.has_relationship? @pairs[0][0]
          raise NoneRelationshipError.new(@pairs[0])
        else
          length = hash_pairs.length
          hash_pairs.reverse.inject({}) do |hash, item|
            if hash.blank?
              hash = item
            else
              hash = { item.keys.first => hash }
            end
          end
        end
      end

      def build!
        # case columns, 1 level relationship and find by id
        if !@raw_query.include? '.'
          return @raw_query.to_sym if @base_class.has_relationship? @raw_query
          raise NoneRelationshipError.new([@base_class.name, @raw_query])
        else
          return build_joins_hash_pairs!
        end
      end
    end
  end
end
