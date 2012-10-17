fill_info_block = (zero) ->
    if (zero)
        $("#colony-number .content").text(0)
        $("#evolution-step .content").text(0)
    else
        $("#colony-number .content").text($.colony_num + 1)
        $("#evolution-step .content").text($.step + 1)

generage_color_for = (cell) ->
    r = Number(287 - 32 * (cell.a + 1)).toString(16)
    g = Number(32 * (cell.b + 1) - 1).toString(16)
    b = Number(32 * (cell.b - cell.a + 2) - 1).toString(16)
    "##{r}#{g}#{b}"

draw_field_cell = (cell, i, j) ->
    if cell.kind == 'alive'
        color = generage_color_for cell
        $("#field-table td[data-cell='#{i} #{j}']").css "background-color", color
    if cell.kind == 'checkpoint'
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
            $.step = 0
            $.colony_num = 0
            $.t = 0
            draw_field_table()
            clearTimeout($.timeout)
            fill_info_block(true)

start_population_life = () ->
    if $.evolution[$.step][$.colony_num][$.t]
        draw_field_table()
        fill_info_block(false)
        $.t += 1
        $.timeout = setTimeout(start_population_life, 300)
    else
        $.t = 0
        $.colony_num += 1
        start_evolution_step()

start_evolution_step = () ->
    if $.evolution[$.step][$.colony_num]
        start_population_life()
    else
        $.colony_num = 0
        $.step += 1
        start_evolution()

start_evolution = () ->
    if $.evolution && $.evolution[$.step]
        start_evolution_step()
    else
        $.step = 0
        draw_field_table()
        clearTimeout($.timeout)
        fill_info_block(true)

$("#get-new-colony").live "click", get_new_evolution
$("#start-new-life").live "click", start_evolution
