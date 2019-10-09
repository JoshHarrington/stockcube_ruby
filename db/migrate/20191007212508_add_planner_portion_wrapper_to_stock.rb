class AddPlannerPortionWrapperToStock < ActiveRecord::Migration[5.1]
  def change
    add_reference :stocks, :planner_portion_wrapper, index: true
  end
end
