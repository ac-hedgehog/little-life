#= require jquery.form
$.app = {}
$.app.evolutions = {}
$.app.evolutions.setup_new = (evolution) ->
    $.evolution = evolution
    new_evolution()
    
    $("#life-table table").live "click", choose_all_evolution
    $("#evolution-block .table-wrapper table").live "click", choose_life_cycles

    $("#play-evolution").live "click", play_evolution
    $("#pause-evolution").live "click", pause_evolution
    $("#stop-evolution").live "click", stop_evolution
$.app.evolutions.setup_create = $.app.evolutions.setup_new

fill_info_block = () ->
    $("#life-cycle").text($.t)

generage_color_for = (cell) ->
    r = Number(287 - 32 * (cell.a + 1)).toString(16)
    g = Number(32 * (cell.b + 1) - 1).toString(16)
    b = Number(32 * (cell.b - cell.a + 2) - 1).toString(16)
    "##{r}#{g}#{b}"

draw_field_cell = ($table_wrapper, cell, i, j) ->
    if cell.alive == true
        color = generage_color_for cell
    if cell.checkpoint == 'finish'
        color = "yellow"
    $table_wrapper.find("table td[data-i='#{i}'][data-j='#{j}']").css("background-color", color)

draw_table = ($table_wrapper, cells) ->
    $table_wrapper.find('table td').css "background-color", "white"
    for i of cells
        for j of cells[i]
            draw_field_cell $table_wrapper, cells[i][j], i, j

draw_life_cycle = () ->
    draw_table $("#life-table"), $.evolution[$.step][$.colony_num]['life_cycles'][$.t]

draw_population = () ->
    if $.evolution
        for step of $.evolution
            max_points = 0
            for colony_num of $.evolution[step]
                person = $.evolution[step][colony_num]
                $colony_block = $("#evolution-#{step}-step #colony-#{colony_num}-block")
                draw_table $colony_block, person['colony']['cells']
                
                task_points = parseInt(person['task_points'])
                max_points = task_points if task_points > max_points
                $colony_block.find(".task-points").text(task_points)
                $colony_block.find(".task-ids").text(person['ids'])
            # Выделяем поле "Набрано очков" у лучшей колонии текущей популяции
            for colony_num of $.evolution[step]
                if parseInt($.evolution[step][colony_num]['task_points']) == max_points
                    $("#evolution-#{step}-step #colony-#{colony_num}-block")
                        .find(".task-points").parent().css("color", "red")

play_population_life = () ->
    if $.evolution[$.step][$.colony_num]['life_cycles'][$.t]
        draw_life_cycle()
        fill_info_block(false)
        $.t += 1
        $.timeout = setTimeout(play_population_life, 300)
    else
        $.t = 0
        if $.show_all
            $.colony_num += 1
            play_evolution_step()
        else
            clearTimeout($.timeout)

play_evolution_step = () ->
    if $.evolution[$.step][$.colony_num]
        play_population_life()
    else
        $.colony_num = 0
        $.step += 1
        play_evolution()

play_evolution = () ->
    if $.evolution && $.evolution[$.step]
        draw_population()
        play_evolution_step()
    else
        stop_evolution()

pause_evolution = () ->
    clearTimeout($.timeout)

set_zeros = () ->
    $.step = 0
    $.colony_num = 0
    $.t = 0

new_evolution = () ->
    $.show_all = true
    set_zeros()
    draw_life_cycle()
    draw_population()
    fill_info_block()
    clearTimeout($.timeout)

stop_evolution = () ->
    new_evolution()

choose_all_evolution = () ->
    $.show_all = true
    stop_evolution()

choose_life_cycles = () ->
    $.show_all = false
    $colony_data = $(@).closest(".table-wrapper").data()
    $.step = $colony_data.step
    $.colony_num = $colony_data.colony_number
    $.t = 0
    draw_life_cycle()
