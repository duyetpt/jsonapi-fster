require 'test_helper'

class ActAsFsterTest < ActiveSupport::TestCase
  before do
    Session.include Jsonapi::Fster::ActAsFster
  end

  describe ".where_jsonapi" do
    it 'filter session by course id' do
      params = {
        filters: {
          course_id: "1"
        }
      }
      expect = "SELECT \"sessions\".* FROM \"sessions\" WHERE \"sessions\".\"course_id\" = 1"
      assert_equal expect, Session.where_jsonapi(params).to_sql
    end

    it 'filter and sorting session by start_at desc' do
      params = {
        filters: {
          course_id: "1"
        },
        sort: '-start_at'
      }
      expect = "SELECT \"sessions\".* FROM \"sessions\" WHERE \"sessions\".\"course_id\" = 1 ORDER BY start_at desc"
      assert_equal expect, Session.where_jsonapi(params).to_sql
    end

    describe 'paging' do
      setup do
        # reset default values of will_pages
        Session.per_page = 30
        WillPaginate.per_page = 30
      end

      it 'filter and sorting session by start_at desc and get page 1' do
        params = {
          filters: {
            course_id: "1"
          },
          sort: '-start_at',
          page: 1
        }
        expect = "SELECT  \"sessions\".* FROM \"sessions\" WHERE \"sessions\".\"course_id\" = 1 ORDER BY start_at desc LIMIT 30 OFFSET 0"
        assert_equal expect, Session.where_jsonapi(params).to_sql
      end

      it 'set per_page for session is 20' do
        Session.per_page = 20
        params = {
          filters: {
            course_id: "1"
          },
          sort: '-start_at',
          page: 1
        }
        expect = "SELECT  \"sessions\".* FROM \"sessions\" WHERE \"sessions\".\"course_id\" = 1 ORDER BY start_at desc LIMIT 20 OFFSET 0"
        assert_equal expect, Session.where_jsonapi(params).to_sql
      end

      it 'filter and sorting session by start_at desc and get page 1, per page is 20' do
        params = {
          filters: {
            course_id: "1"
          },
          sort: '-start_at',
          page: 1,
          per_page: 20
        }
        expect = "SELECT  \"sessions\".* FROM \"sessions\" WHERE \"sessions\".\"course_id\" = 1 ORDER BY start_at desc LIMIT 20 OFFSET 0"
        assert_equal expect, Session.where_jsonapi(params).to_sql
      end
    end
  end
end
