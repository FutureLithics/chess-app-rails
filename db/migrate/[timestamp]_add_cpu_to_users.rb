class AddCpuToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :cpu, :boolean, default: false
    
    # Update existing CPU users
    reversible do |dir|
      dir.up do
        User.where(role: 'cpu').update_all(cpu: true)
      end
    end
  end
end 