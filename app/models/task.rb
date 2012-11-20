# encoding: utf-8
class Task < ActiveRecord::Base
  attr_accessible :goal
  enum_attr :goal, %w(^maximizing absorption) do
    labels  maximizing: 'Рост',
            absorption: 'Поглощение'
  end
  
  has_many :evolutions
  
  def calculate_points_for(main_name, field_before, field_after)
    case self.goal
    when :maximizing
      maximizing_points_for main_name, field_before, field_after
    when :absorption
      absorption_points_for main_name, field_before, field_after
    end
  end
  
  private
  
  def maximizing_points_for(main_name, field_before, field_after)
    alive_cells_before = field_before.alive_cells[main_name] || []
    alive_cells_after = field_after.alive_cells[main_name] || []
    points = alive_cells_after.count +
             field_before.rows * field_before.cols / alive_cells_before.count.to_f
    
    all_parents = alive_cells_after.map(&:parents).flatten.uniq
    ids = alive_cells_before.map { |a_c_b|
      a_c_b.id if all_parents.include?(a_c_b.id)
    }.compact.sort
    
    { task_points: points.round(2), ids: ids }
  end
  
  def absorption_points_for(main_name, field_before, field_after)
    alive_cells_before = field_before.alive_cells[main_name] || []
    alive_cells_after = field_after.alive_cells[main_name] || []
    enemy_cells_before = field_before.alive_cells[Evolution::ENEMY_NAME] || []
    enemy_cells_after = field_after.alive_cells[Evolution::ENEMY_NAME] || []
    points = alive_cells_after.count.to_f / enemy_cells_after.count +
             enemy_cells_before.count.to_f / alive_cells_before.count +
             1.0 / alive_cells_before.count.to_f
    
    all_parents = alive_cells_after.map(&:parents).flatten.uniq
    ids = alive_cells_before.map { |a_c_b|
      a_c_b.id if all_parents.include?(a_c_b.id)
    }.compact.sort
    
    { task_points: points.round(2), ids: ids }
  end
end
