life_cycles_to_object = (life_cycles) ->
    new_life_cycles = (JSON.parse life_cycle for life_cycle in life_cycles)

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
    life_cycle = $.life_cycles[$.t]
    $("#field-table td").css "background-color", "white"
    for i of life_cycle
        for j of life_cycle[i]
            draw_field_cell life_cycle[i][j], i, j

get_new_life = () ->
    $.ajax
        type: "POST"
        data:
            position: [0, 0]
        url: "new_life"
        success: (life_cycles) ->
            $.life_cycles = life_cycles_to_object(life_cycles)
            $.t = 0
            draw_field_table()
            clearInterval($.interval)

start_new_life = () ->
    if $.life_cycles && $.life_cycles[$.t]
        draw_field_table()
        $.t += 1

$("#get-new-colony").live "click", get_new_life
$("#start-new-life").live "click", () ->
    $.interval = setInterval(start_new_life, 300)
