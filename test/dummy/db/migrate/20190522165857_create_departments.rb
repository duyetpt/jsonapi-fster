class CreateDepartments < ActiveRecord::Migration[5.2]
  def change
    create_table :departments do |t|
      t.integer :floor
      t.string :no
      t.integer :course_id

      t.timestamps
    end
  end
end
