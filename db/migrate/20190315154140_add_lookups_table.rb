class AddLookupsTable < ActiveRecord::Migration[5.2]
  def change
    create_table "lookups" do |t|
      t.string :number
      t.string :country
      t.string :phone
    end
  end
end
