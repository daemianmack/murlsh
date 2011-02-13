class Init < ActiveRecord::Migration

  def self.up
    create_table :urls do |t|
      # t.integer :id
      t.integer :content_length
      t.string :content_type
      t.string :email
      t.string :name
      t.timestamp :time
      t.string :thumbnail_url
      t.string :title
      t.string :url
      t.string :via
    end

    add_index :urls, :time
  end

end
