require 'test_helper'

class OrderClauseBuilderTest < ActiveSupport::TestCase
  describe '#build sort values' do
    it 'sort by id' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('id', Session)
      assert_equal ['id asc'], builder.build_sort_values
    end

    it 'sort by id,-name' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('id,-name', Session)
      assert_equal ['id asc', 'name desc'], builder.build_sort_values
    end

    it 'sort by courses.id,-name' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('courses.id,-name', Session)
      assert_equal ['courses.id asc', 'name desc'], builder.build_sort_values
    end
  end

  describe '#joins values' do
    it 'sort by id' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('id', Session)
      assert_equal [], builder.joins_values
    end

    it 'sort by id,-name' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('id,-name', Session)
      assert_equal [], builder.joins_values
    end

    it 'sort by courses.id,name' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('courses.id,name', Session)
      assert_equal ['course'], builder.joins_values
    end

    it 'sort by courses.id,courses.name' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('courses.id,courses.name', Session)
      assert_equal ['course'], builder.joins_values
    end

    it 'list courses, sort by amenities.id,studio.id' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('studios.id,amenities.id', Course)
      assert_equal ['amenities', 'studio'], builder.joins_values.sort
    end
  end
end
