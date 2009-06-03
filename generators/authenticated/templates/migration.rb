class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.column :first,                     :string, :limit => 40
      t.column :last,                      :string, :limit => 40
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
<% if options[:include_activation] -%>
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime<% end %>
<% if options[:stateful] -%>
      t.column :state,                     :string, :null => :no, :default => 'passive'
      t.column :deleted_at,                :datetime<% end %>
    end
    add_index :<%= table_name %>, :email, :unique => true
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end
