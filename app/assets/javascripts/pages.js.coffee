fill_info_block = (zero) ->
    if (zero)
        $("#time-moment .content").text(0)
        $("#colony-number .content").text(0)
        $("#evolution-step .content").text(0)
    else
        $("#time-moment .content").text($.t)
        $("#colony-number .content").text($.colony_num + 1)
        $("#evolution-step .content").text($.step + 1)

generage_color_for = (cell) ->
    r = Number(287 - 32 * (cell.a + 1)).toString(16)
    g = Number(32 * (cell.b + 1) - 1).toString(16)
    b = Number(32 * (cell.b - cell.a + 2) - 1).toString(16)
    "##{r}#{g}#{b}"

draw_field_cell = (cell, i, j) ->
    if cell.alive == true
        color = generage_color_for cell
        $("#field-table td[data-cell='#{i} #{j}']").css "background-color", color
    if cell.checkpoint == 'finish'
        $("#field-table td[data-cell='#{i} #{j}']").css "background-color", "yellow"

draw_field_table = () ->
    life_cycle = $.evolution[$.step][$.colony_num][$.t]
    $("#field-table td").css "background-color", "white"
    for i of life_cycle
        for j of life_cycle[i]
            draw_field_cell life_cycle[i][j], i, j

get_new_evolution = () ->
    $.ajax
        type: "POST"
        data:
            position: [0, 0]
        url: "new_life"
        success: (evolution) ->
            $.evolution = evolution
            stop_evolution()

play_population_life = () ->
    if $.evolution[$.step][$.colony_num][$.t]
        draw_field_table()
        fill_info_block(false)
        $.t += 1
        $.timeout = setTimeout(play_population_life, 300)
    else
        $.t = 0
        $.colony_num += 1
        play_evolution_step()

play_evolution_step = () ->
    if $.evolution[$.step][$.colony_num]
        play_population_life()
    else
        $.colony_num = 0
        $.step += 1
        play_evolution()

play_evolution = () ->
    if $.evolution && $.evolution[$.step]
        play_evolution_step()
    else
        stop_evolution()

pause_evolution = () ->
    clearTimeout($.timeout)

stop_evolution = () ->
    $.step = 0
    $.colony_num = 0
    $.t = 0
    draw_field_table()
    clearTimeout($.timeout)
    fill_info_block(true)

$("#get-new-evolution").live "click", get_new_evolution
$("#play-evolution").live "click", play_evolution
$("#pause-evolution").live "click", pause_evolution
$("#stop-evolution").live "click", stop_evolution
