class AddStartAtForSession < ActiveRecord::Migration[5.2]
  def change
    add_column :sessions, :start_at, :datetime
  end
end
