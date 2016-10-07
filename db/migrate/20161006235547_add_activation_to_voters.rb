class AddActivationToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :activation_digest, :string
    add_column :voters, :activated, :boolean, default: false
    add_column :voters, :activated_at, :datetime
  end
end
