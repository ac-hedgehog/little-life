evolution_step_to_object = (evolution_step) ->
    JSON.parse life_cycle for life_cycle in life_cycles

generage_color_for = (cell) ->
    r = Number(287 - 32 * (cell.a + 1)).toString(16)
    g = Number(32 * (cell.b + 1) - 1).toString(16)
    b = Number(32 * (cell.b - cell.a + 2) - 1).toString(16)
    "##{r}#{g}#{b}"

draw_field_cell = (cell, i, j) ->
    if cell.kind == 'alive'
        color = generage_color_for cell
        $("#field-table td[data-cell='#{i} #{j}']").css "background-color", color

draw_field_table = () ->
    life_cycle = $.evolution_step[$.p_n][$.t]
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
            $.evolution_step = evolution_step_to_object(evolution_step)
            $.p_n = 0
            $.t = 0
            draw_field_table()
            clearInterval($.interval)

start_population_life = () ->
    if $.evolution_step && $.evolution_step[$.p_n] && $.evolution_step[$.p_n][$.t]
        draw_field_table()
        $.t += 1

start_evolution_step = () ->
    if $.evolution_step && $.evolution_step[$.p_n]
            start_population_step()
            $.p_n += 1
    else
        clearInterval($.interval)

$("#get-new-colony").live "click", get_new_evolution_step
$("#start-new-life").live "click", () ->
    $.interval = setInterval(start_evolution_step, 300)
