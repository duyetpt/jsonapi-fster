class CreateAmenities < ActiveRecord::Migration[5.2]
  def change
    create_table :amenities do |t|
      t.string :name
      t.string :code
      t.integer :course_id

      t.timestamps
    end
  end
end
