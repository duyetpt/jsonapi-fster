class CreateSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :sessions do |t|
      t.integer :course_id
      t.integer :duration
      t.integer :week_day

      t.timestamps
    end
  end
end
