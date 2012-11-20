# coding: utf-8
class Field < Template
  has_and_belongs_to_many :colonies
  
  LIFE_CYCLES_RANGE = (10..25)
  
  def push_colonies(colonies)
    return unless colonies
    colonies.each do |colony|
      top, left = colony[:top] || 0, colony[:left] || 0
      if (top + colony[:colony].rows > self.rows) ||
         (left + colony[:colony].cols > self.cols)
        raise Exception.new "Bad position for #{colony[:colony].name}"
      end
      set_colony colony[:colony], top, left
    end
  end
  
  def get_life(life_cycles_number)
    life_cycles = [self.cells]
    lcn = life_cycles_number.in?(LIFE_CYCLES_RANGE)? life_cycles_number : LIFE_CYCLES_RANGE.min
    lcn.times { life_cycles.push next_life_cycle }
    life_cycles
  end
  
  def alive_cells
    alive_cells = {}
    self.cells.map { |row| row.map { |cell|
      if cell.alive?
        alive_cells[cell.name] ||= []
        alive_cells[cell.name].push cell.clone
      end
    } }
    alive_cells
  end
  
  private
  
  def create_cell(cell)
    FieldCell.new cell
  end
  
  def find_a_neighbors(i, j)
    neighbors = [set_cell(i, j)] * 8
    neighbors[0] = self.cells[i - 1][j - 1] unless i == 0 || j == 0
    neighbors[1] = self.cells[i - 1][j]     unless i == 0
    neighbors[2] = self.cells[i - 1][j + 1] unless i == 0 || j == self.cols - 1
    neighbors[3] = self.cells[i][j + 1]     unless j == self.cols - 1
    neighbors[4] = self.cells[i + 1][j + 1] unless i == self.rows - 1 || j == self.cols - 1
    neighbors[5] = self.cells[i + 1][j]     unless i == self.rows - 1
    neighbors[6] = self.cells[i + 1][j - 1] unless i == self.rows - 1 || j == 0
    neighbors[7] = self.cells[i][j - 1]     unless j == 0
    neighbors
  end
  
  def separate_neighbors(neighbors)
    # Разделяем клетки по колониям, получаем из массива живых клеток хеш вида:
    # ключ - имя колонии, значение - массив клеток этой колонии
    neighbors.inject({}){ |separated_neighbors, neighbor|
      separated_neighbors[neighbor.name] ||= []
      separated_neighbors[neighbor.name].push neighbor
      separated_neighbors
    }
  end
  
  def the_best_neighbors_among(neighbors)
    # Из хеша клеток, разделённых по колониям, создаём хеш показателей
    # мизантропии, вида: ключ - показатель мизантропии, значение - массив
    # имён колоний, имеющих этот показатель мизантропии для своих клеток
    misanthropy_levels = neighbors.inject({}){ |levels, colony_neighbors|
      misanthropy_level = colony_neighbors.last.map(&:misanthropy).sum
      levels[misanthropy_level] ||= []
      levels[misanthropy_level].push colony_neighbors.first
      levels
    }
    # Вычисляем наилучший показатель мизантропии из имеющихся
    bml = misanthropy_levels.keys.first
    misanthropy_levels.keys.each do |level|
      bml = level if (level - ColonyCell.best_misanthropy_level).abs <
                     (bml - ColonyCell.best_misanthropy_level).abs
    end
    # Если этот показатель в пределах допустимого и его имеет только одна
    # колония - то её клетки и будут считаться наилучшими соседями
    if ColonyCell.allowable_range_of_fertility.include?(bml) &&
       misanthropy_levels[bml].count == 1
      neighbors[misanthropy_levels[bml].first]
    else
      []
    end
  end
  
  def the_best_separated_neighbors_for(cell, neighbors)
    neighbors.inject({}){ |bsn, colony_neighbors|
      if (cell.survival_range).include?(colony_neighbors.last.count)
        bsn[colony_neighbors.first] = colony_neighbors.last
      end
      bsn
    }
  end
  
  # Возвращает имя наиболее "крутой" с точки зрения "жизненной позиции"
  # (по абсолютной величине) колонии, если такая одна, и nil если их несколько
  def whose_cell?(neighbors)
    return neighbors.keys.first if neighbors.size == 1
    life_positions = neighbors.inject({}){ |positions, colony_neighbors|
      lps = colony_neighbors.last.map(&:life_position)
      life_position = lps.sum / lps.size
      positions[life_position] ||= []
      positions[life_position].push colony_neighbors.first
      positions
    }
    blp = life_positions.keys.first
    life_positions.keys.each do |position|
      blp = position if position.abs > blp
    end
    life_positions[blp].count == 1 ? life_positions[blp].first : nil
  end
  
  def processing_of_alive_cell(i, j)
    # Получаем ВСЕХ соседей клетки
    neighbors = find_a_neighbors(i, j)
    # Выбираем живых соседей клетки
    alive_neighbors = neighbors.map{ |n| n.clone if n.alive? }.compact
    return set_cell(i, j) if alive_neighbors.empty?
    # Разделяем живых соседей клетки по колониям, выделяем тех, в окружении
    # которых клетка сможет выжить. Получаем хеш вида:
    # ключ - имя колонии, значение - массив клеток этой колонии
    separated_neighbors = the_best_separated_neighbors_for(
      self.cells[i][j].clone, separate_neighbors(alive_neighbors)
    )
    return set_cell(i, j) if separated_neighbors.empty?
    # Узнаём имя колонии, у которой наивысший по абсолютной величине показатель
    # "жизненной позиции", т.е. максимально выраженное дружелюбие/агрессивность
    best_neighbor_name = whose_cell? separated_neighbors
    # Если такая колония строго одна - получили её имя и тогда...
    if best_neighbor_name
      new_cell = self.cells[i][j].clone
      # Если имя наиболее "удобной" для выживания колонии не совпадает с
      # именем колонии, которой до сих пор принадлежала клетка (т.е. лучшая
      # колония - "вражеская" колония), то...
      unless new_cell.name == best_neighbor_name
        lps = separated_neighbors[best_neighbor_name].map(&:life_position)
        life_position = lps.sum / lps.size
        # Если "жизненная позиция" вражеской колонии более агрессивна, чем у
        # клетки, то клетка погибает, а если наоборот - клетка присоединяется
        # к этой "вражеской" колонии
        if life_position < new_cell.life_position
          new_cell = set_cell(i, j)
        else
          new_cell.name = best_neighbor_name
        end
      end
      new_cell
    else
      set_cell(i, j)
    end
  end
  
  def processing_of_dead_cell(i, j)
    # Получаем ВСЕХ соседей клетки
    neighbors = find_a_neighbors(i, j)
    # Выбираем живых соседей клетки
    alive_neighbors = neighbors.map{ |n| n.clone if n.alive? }.compact
    return self.cells[i][j] if alive_neighbors.empty?
    # Разделяем живых соседей клетки по колониям, получаем хеш вида:
    # { 'Имя колонии 1' => [<клетка-сосед-1>, <клетка-сосед-3>],
    #   'Имя колонии 2' => [<клетка-сосед-2>] }
    separated_neighbors = separate_neighbors alive_neighbors
    # Находим "лучших соседей" для новой клетки, если они есть, т.е. из колоний
    # кандидатов в качестве "родителя" выбирается та, у которой наилучший
    # показатель мизантропии. Если он плох у всех или одинаково хорош у
    # нескольких колоний, то пустая клетка пока так и останется мёртвой
    best_neighbors = the_best_neighbors_among separated_neighbors
    # Итак, если в итоге имеем массив из клеток одной колонии, подходящих по
    # уровню мизантропии, то соответственно создаём новую клетку этой колонии
    if best_neighbors.any?
      a = best_neighbors.map(&:a).sum / best_neighbors.map(&:a).size
      b = best_neighbors.map(&:b).sum / best_neighbors.map(&:b).size
      name = best_neighbors.first.name
      parents = best_neighbors.map(&:parents).flatten.uniq
      ColonyCell.new name: name, alive: true, parents: parents, a: a, b: b
    else
      self.cells[i][j]
    end
  end
  
  def next_life_cycle
    cells = self.cells.map { |row| row.map { |cell| cell.clone } }
    self.rows.times do |i|
      self.cols.times do |j|
        if self.cells[i][j].alive?
          cells[i][j] = processing_of_alive_cell(i, j)
        else
          cells[i][j] = processing_of_dead_cell(i, j)
        end
      end
    end
    @cells = cells
    self.cells
  end
  
  def set_colony(colony, top, left)
    colony.rows.times do |i|
      colony.cols.times do |j|
        raise Exception.new "Bad position" unless self.cells[i + top][j + left].dead?
        self.cells[i + top][j + left] = colony.cells[i][j] if colony.cells[i][j].alive?
      end
    end
  end
end
