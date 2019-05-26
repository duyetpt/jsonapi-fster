require 'test_helper'

class ActAsSortingTest < ActiveSupport::TestCase
  before do
    Category.create!([
      {id: 1, name: :gym, code: :G},
      {id: 2, name: :yoga, code: :Y},
      {id: 3, name: :swim, code: :S},
      {id: 4, name: :swim, code: :A}
    ])
  end

  describe 'build json api order query' do
    it 'params is nil' do
      assert_equal '', Category.build_jsonapi_order_querys(nil)
    end

    it 'no params' do
      assert_equal ['created_at desc'], Category.build_jsonapi_order_querys
    end

    it 'category, sort by name' do
      assert_equal ['name asc'], Category.build_jsonapi_order_querys('name')
    end

    it 'category sort by name, code' do
      assert_equal ['name asc', 'code asc'], Category.build_jsonapi_order_querys('name,code')
    end

    it 'category sort by code, name' do
      assert_equal ['code asc', 'name asc'], Category.build_jsonapi_order_querys('code,name')
    end

    it 'category sort by name, -code' do
      assert_equal ['name asc', 'code desc'], Category.build_jsonapi_order_querys('name,-code')
    end
  end

  describe 'jsonapi order' do
    it 'order by id' do
      assert_equal [1, 2, 3, 4], Category.jsonapi_order('id').map(&:id)
    end

    it 'order by -id' do
      assert_equal [4, 3, 2, 1], Category.jsonapi_order('-id').map(&:id)
    end

    it 'order by name and, -code' do
      assert_equal [1, 3, 4, 2], Category.jsonapi_order('name,-code').map(&:id)
    end

    it 'order by name and, code' do
      assert_equal [1, 4, 3, 2], Category.jsonapi_order('name,code').map(&:id)
    end
  end
end
