class AddShortNameToAtmKtb < ActiveRecord::Migration
  def change
    add_column :atm_ktb, :short_name, :string
  end
end
