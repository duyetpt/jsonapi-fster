class CreateCategoriesCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :categories_courses do |t|
      t.integer :category_id
      t.integer :course_id

      t.timestamps
    end
  end
end
