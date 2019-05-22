class AddStudioIdForCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :studio_id, :integer, index: true
  end
end
