require 'test_helper'

class ActAsFilterTest < ActiveSupport::TestCase
  before do
    Category.create!([
      {id: 1, name: :gym, code: :G},
      {id: 2, name: :yoga, code: :Y},
      {id: 3, name: :swim, code: :S}
    ])

    Studio.create!([
      {id: 1, name: 'Wefit'},
      {id: 2, name: 'Thanos'}
    ])

    Course.create!([
      {id: 1, code: 'C1', name: 'Morning gym', studio_id: 2},
      {id: 2, code: 'C2', name: 'Afternoon gym', studio_id: 1},
      {id: 3, code: 'C3', name: 'Night Yoga', studio_id: 1},
      {id: 4, code: 'C4', name: 'Morning swim', studio_id: 2},
      {id: 5, code: 'C5', name: 'Afternoon swim', studio_id: 2}
    ])

    CategoriesCourse.create!([
      {category_id: 1, course_id: 1},
      {category_id: 1, course_id: 2},
      {category_id: 2, course_id: 3},
      {category_id: 3, course_id: 4},
      {category_id: 3, course_id: 5}
    ])

    Department.create!([
      {id: 1, floor: 1, no: 'b101', course_id: 1},
      {id: 2, floor: 1, no: 'b102', course_id: 2},
      {id: 3, floor: 3, no: 'b301', course_id: 3},
      {id: 4, floor: 2, no: 'b201', course_id: 4},
      {id: 5, floor: 2, no: 'b201', course_id: 5}
    ])

    Amenity.create!([
      {id: 1, name: 'a1', course_id: 1},
      {id: 2, name: 'a2', course_id: 2},
      {id: 3, name: 'a3', course_id: 2},
      {id: 4, name: 'a4', course_id: 3}
    ])

    Session.create!([
      {id: 1, course_id: 1, duration: 60, week_day: 1, start_at: Time.zone.local(2019, 1, 1, 10)},
      {id: 2, course_id: 1, duration: 90, week_day: 3, start_at: Time.zone.local(2019, 1, 1, 15)},
      {id: 3, course_id: 2, duration: 60, week_day: 2, start_at: Time.zone.local(2019, 1, 3, 10)},
      {id: 4, course_id: 3, duration: 60, week_day: 2, start_at: Time.zone.local(2019, 1, 2, 15)},
      {id: 5, course_id: 3, duration: 60, week_day: 3, start_at: Time.zone.local(2019, 1, 2, 18)},
      {id: 6, course_id: 4, duration: 45, week_day: 5, start_at: Time.zone.local(2019, 1, 10, 10)},
      {id: 7, course_id: 4, duration: 45, week_day: 6, start_at: Time.zone.local(2019, 1, 15, 10)},
      {id: 8, course_id: 4, duration: 45, week_day: 0, start_at: Time.zone.local(2019, 2, 1, 10)},
      {id: 9, course_id: 5, duration: 90, week_day: 4, start_at: Time.zone.local(2019, 2, 10, 10)},
    ])

    Instructor.create!([
      {id: 1, name: 'jonh', session_id: 1},
      {id: 2, name: 'michel', session_id: 3},
      {id: 3, name: 'jonh', session_id: 4},
      {id: 4, name: 'michel', session_id: 5},
      {id: 5, name: 'alice', session_id: 6},
      {id: 6, name: 'alice', session_id: 7},
      {id: 7, name: 'jame', session_id: 8},
      {id: 8, name: 'michel', session_id: 9}
    ])
  end

  describe 'jsonapi filter' do
    describe '1 level' do
      it 'session in weekday is 3' do
        sessions = Session.where_jsonapi_filter week_day: '3'
        assert_equal [2, 5], sessions.map(&:id).sort
      end

      it 'session in weekday is 3,5' do
        sessions = Session.where_jsonapi_filter week_day: '3,5'
        assert_equal [2, 5, 6], sessions.map(&:id).sort
      end

      # belongs_to
      it 'sesions of course 1,2' do
        sessions = Session.where_jsonapi_filter course: '1,2'
        assert_equal [1, 2, 3], sessions.map(&:id).sort
      end

      it 'sesions of course 1,2 use left_outer_joins' do
        sessions = Session.where_jsonapi_filter( {'course' => '1,2'}, 'left_outer_joins')
        assert_equal [1, 2, 3], sessions.map(&:id).sort
      end

      # has_one
      it 'session teach by teacher 1, 2, 3' do
        sessions = Session.where_jsonapi_filter instructor: '1,2,3'
        assert_equal [1, 3, 4], sessions.map(&:id).sort
      end

      it 'session teach by teacher 1, 2, 3, use left_outer_joins' do
        sessions = Session.where_jsonapi_filter({'instructor': '1,2,3'}, 'left_outer_joins')
        assert_equal [1, 3, 4], sessions.map(&:id).sort
      end

      # has_many
      it 'course of sessions 1, 2, 3, 8' do
        courses = Course.where_jsonapi_filter(sessions: '1,2,3,8').distinct
        assert_equal [1, 2, 4], courses.map(&:id).sort
      end

      it 'course of sessions 1, 2, 3, 8, use left_outer_joins' do
        courses = Course.where_jsonapi_filter({'sessions': '1,2,3,8'}, 'left_outer_joins')
        assert_equal [1, 1, 2, 4], courses.map(&:id).sort
      end
    end

    describe '2 levels' do
      # course.name
      it 'sessions has course name is Morning gym, Morning yoga' do
        sessions = Session.where_jsonapi_filter('course.name': 'Morning gym,Morning yoga')
        assert_equal [1, 2], sessions.map(&:id).sort
      end

      # course.categories (many through)
      it 'sessions has categoy is yoga, swim' do
        sessions = Session.where_jsonapi_filter('course.categories': '2,3')
        assert_equal [4, 5, 6, 7, 8, 9], sessions.map(&:id).sort
      end

      # course.amenities (many)
      it 'sessions has amenity a2,a3' do
        sessions = Session.where_jsonapi_filter('course.amenities': '2,3').distinct
        assert_equal [3], sessions.map(&:id).sort
      end

      it 'sessions has amenity a2,a3, use left_outer_joins' do
        sessions = Session.where_jsonapi_filter({'course.amenities': '2,3'}, 'left_outer_joins').distinct
        assert_equal [3], sessions.map(&:id).sort
      end

      # course.department (has_one)
      it 'sessions in department 1,3' do
        sessions = Session.where_jsonapi_filter('course.department': '1,3').distinct
        assert_equal [1, 2, 4, 5], sessions.map(&:id).sort
      end

      # course.studio
      it 'sessions in studio 2' do
        sessions = Session.where_jsonapi_filter('course.studio': '2').distinct
        assert_equal [1, 2, 6, 7, 8, 9], sessions.map(&:id).sort
      end
    end

    describe '3 levels' do
      # course.studio.name
      it 'sessions in studio Thanos' do
        sessions = Session.where_jsonapi_filter('course.studio.name': 'Thanos').distinct
        assert_equal [1, 2, 6, 7, 8, 9], sessions.map(&:id).sort
      end

      # course.categories.code
      it 'sessions in categories gym, swim' do
        sessions = Session.where_jsonapi_filter('course.categories.code': 'G,S').distinct
        assert_equal [1, 2, 3, 6, 7, 8, 9], sessions.map(&:id).sort
      end

      # course.amenities.name
      it 'sessions has amenities a1, a2' do
        sessions = Session.where_jsonapi_filter('course.amenities.name': 'a1,a2').distinct
        assert_equal [1, 2, 3], sessions.map(&:id).sort
      end
    end

    it 'session id between 1-5' do
      result = Session.where_jsonapi_filter('id.between': '1,5').to_a
      assert_equal 5, result.size
      assert_equal [1, 2, 3, 4, 5], result.map(&:id).sort
    end

    it 'session start_at between 10-1 to 20-1' do
      start_at = Time.zone.local(2019, 1, 10).to_s
      end_at = Time.zone.local(2019, 1, 20, 23).to_s
      result = Session.where_jsonapi_filter('start_at.between': "#{start_at},#{end_at}").to_a
      assert_equal 2, result.size
      assert_equal [6, 7], result.map(&:id).sort
    end

    it 'session start_at between 14h 1-1 to 15h 4-1' do
      start_at = Time.zone.local(2019, 1, 1, 14).to_s
      end_at = Time.zone.local(2019, 1, 4, 15).to_s
      result = Session.where_jsonapi_filter('start_at.between': "#{start_at},#{end_at}").to_a
      assert_equal 4, result.size
      assert_equal [2, 3, 4, 5], result.map(&:id).sort
    end
  end
end
