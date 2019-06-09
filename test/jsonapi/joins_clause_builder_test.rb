require 'test_helper'

class JoinsClauseBuilderTest < ActiveSupport::TestCase
  describe '#build pairs' do
    it 'a.b' do
      builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('a.b', nil)
      assert_equal [['a', 'b']], builder.build_pairs
    end

    it 'a.b.c.d' do
      builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('a.b.c.d', nil)
      assert_equal [['a', 'b'], ['b', 'c'], ['c', 'd']], builder.build_pairs
    end
  end

  describe "#build joins hash pair" do
    before do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('session.id', nil)
    end

    it 'a column' do
      arr = ['session', 'id']
      assert_nil @builder.build_joins_hash_pair!(arr)
    end

    it 'belongs_to relationship' do
      arr = ['session', 'course']
      expect = {session: :course}
      assert_equal expect, @builder.build_joins_hash_pair!(arr)
    end

    it 'has_one relationship' do
      arr = ['session', 'instructor']
      expect = {session: :instructor}
      assert_equal expect, @builder.build_joins_hash_pair!(arr)
    end

    it 'has_many relationship' do
      arr = ['course', 'amenities']
      expect = {course: :amenities}
      assert_equal expect, @builder.build_joins_hash_pair!(arr)
    end

    it 'has_many_through relationship' do
      arr = ['course', 'categories']
      expect = {course: {categories_courses: :category}}
      assert_equal expect, @builder.build_joins_hash_pair!(arr)
    end

    it 'raise exception, none relationship' do
      arr = ['session', 'category']
      assert_raise Jsonapi::Fster::NoneRelationshipError do
        @builder.build_joins_hash_pair!(arr)
      end
    end
  end

  describe "#build" do
    # column
    it 'id' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('id', Session)
      assert_raise Jsonapi::Fster::NoneRelationshipError do
        assert_nil @builder.build!
      end
    end

    it 'raise exception when columns is not exist' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('ids', Session)
      assert_raise Jsonapi::Fster::NoneRelationshipError do
        @builder.build!
      end
    end

    it 'raise exception when not relate' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('courses.name', Session)
      assert_raise Jsonapi::Fster::NoneRelationshipError do
        @builder.build!
      end
    end

    # belongs_to
    it 'belongs to course' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('course', Session)
      expect = :course
      assert_equal expect, @builder.build!
    end

    # has_many
    it '1 level, has many sessions' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('sessions', Course)
      expect = :sessions
      assert_equal expect, @builder.build!
    end

    # has_many
    it '1 level, has many sessions, condition is duration' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('sessions.duration', Course)
      expect = :sessions
      assert_equal expect, @builder.build!
    end

    # 2 level, has_many through
    it '1 level, has many through categories, find by id' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('course.categories', Session)
      expect = {course: {categories_courses: :category}}
      assert_equal expect, @builder.build!
    end

    # 3 level
    it '2 level, sessions.intructor.name' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('sessions.instructor.name', Course)
      expect = {sessions: :instructor}
      assert_equal expect, @builder.build!
    end

    # 3 level, has_many through
    it '1 level, has many through categories, find by code' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('course.categories.code', Session)
      expect = {course: {categories_courses: :category}}
      assert_equal expect, @builder.build!
    end

    # 4 level
    it '1 level, has many through categories, find by code' do
      @builder = ::Jsonapi::Fster::JoinsClauseBuilder.new('course.studio.district.code', Session)
      expect = {course: {studio: :district}}
      assert_equal expect, @builder.build!
    end
  end
end
