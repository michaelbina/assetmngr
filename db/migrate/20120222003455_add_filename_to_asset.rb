class AddFilenameToAsset < ActiveRecord::Migration
  def change
    add_column :assets, :filename, :string
  end
end
