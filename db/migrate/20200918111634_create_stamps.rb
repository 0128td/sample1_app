class CreateStamps < ActiveRecord::Migration[5.2]
  def change
    create_table :stamps do |t|
      t.string :name
      t.datetime :start
      t.datetime :am_finish
      t.datetime :pm_start
      t.datetime :finish
      t.date :date
      t.text :memo

      t.timestamps
    end
  end
end
