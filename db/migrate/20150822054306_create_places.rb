class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :category
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :tel
      t.string :url

      t.timestamps null: false
    end
  end
end
