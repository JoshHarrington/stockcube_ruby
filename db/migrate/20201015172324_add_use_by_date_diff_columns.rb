class AddUseByDateDiffColumns < ActiveRecord::Migration[5.1]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:ingredients, :use_by_date_diff)
      add_column :ingredients, :use_by_date_diff, :integer, null: false, default: 14
    end
  end
end
