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
    life_cycle = $.evolution_step[$.pop_num][$.t]
    $("#field-table td").css "background-color", "white"
    for i of life_cycle
        for j of life_cycle[i]
            draw_field_cell life_cycle[i][j], i, j

get_new_evolution_step = () ->
    $.ajax
        type: "POST"
        data:
            position: [0, 0]
        url: "new_life"
        success: (evolution_step) ->
            $.evolution_step = evolution_step
            $.pop_num = 0
            $.t = 0
            draw_field_table()
            clearTimeout($.timeout)

start_population_life = () ->
    if $.evolution_step && $.evolution_step[$.pop_num] && $.evolution_step[$.pop_num][$.t]
        draw_field_table()
        $.t += 1
        $.timeout = setTimeout(start_population_life, 300)
    else
        clearTimeout($.timeout)
        start_evolution_step()

start_evolution_step = () ->
    if $.evolution_step && $.evolution_step[$.pop_num]
        start_population_life()
        $.pop_num += 1
    else
        clearTimeout($.timeout)

$("#get-new-colony").live "click", get_new_evolution_step
$("#start-new-life").live "click", start_evolution_step
