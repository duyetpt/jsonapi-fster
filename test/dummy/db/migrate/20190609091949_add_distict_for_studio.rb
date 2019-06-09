class AddDistictForStudio < ActiveRecord::Migration[5.2]
  def change
    add_column :studios, :district_id, :integer
  end
end
