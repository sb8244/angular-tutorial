class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.text :title
      t.text :content
      t.boolean :cool

      t.timestamps
    end
  end
end
