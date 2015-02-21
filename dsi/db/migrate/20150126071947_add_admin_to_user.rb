class AddAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :admin, :string, limit: 1
  end
end
