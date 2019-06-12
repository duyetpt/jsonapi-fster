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
