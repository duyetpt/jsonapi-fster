require 'test_helper'

class OrderClauseBuilderTest < ActiveSupport::TestCase
  describe '#build sort values' do
    it 'sort by id' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('id', Session)
      assert_equal ['id asc'], builder.build_sort_values
    end

    it 'sort by id,-duration' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('id,-duration', Session)
      assert_equal ['id asc', 'duration desc'], builder.build_sort_values
    end

    it 'sort by courses.name,-id' do
      builder = Jsonapi::Fster::OrderClauseBuilder.new('courses.name,-id', Session)
      assert_equal ['courses.name asc', 'id desc'], builder.build_sort_values
    end

    it 'sort by ids, column is not exist' do
      ex =
        assert_raise ActiveRecord::StatementInvalid do
          builder = Jsonapi::Fster::OrderClauseBuilder.new('ids', Session)
          builder.build_sort_values
        end
      assert_equal 'Not exist column ids', ex.message
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
