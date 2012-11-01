class Task < ActiveRecord::Base
  enum_attr :goal, %w(^maximizing)
  
  def calculate_points_for(colony_before, colony_after)
    case self.goal
    when :maximizing
      maximizing_points_for colony_before, colony_after
    end
  end
  
  private
  
  def maximizing_points_for(colony_before, colony_after)
    alive_cells_before = colony_before.alive_cells
    alive_cells_after = colony_after.alive_cells
    points = alive_cells_after.count + colony_before.rows * colony_before.cols / alive_cells_before.count.to_f
    
    all_parents = alive_cells_after.map(&:parents).flatten.uniq
    ids = alive_cells_before.map { |a_c_b|
      a_c_b.id if all_parents.include?(a_c_b.id)
    }.compact.sort
    
    { task_points: points.round(2), ids: ids }
  end
end
