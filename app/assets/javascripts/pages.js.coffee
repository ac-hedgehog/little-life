life_cycles_to_object = (life_cycles) ->
    new_life_cycles = (JSON.parse life_cycle for life_cycle in life_cycles)

draw_field_cell = (cell, i, j) ->
    if cell.kind == 'alive'
        r = Number(255 - (32 * (cell.a + 1) - 1)).toString(16)
        g = Number(32 * (cell.b + 1) - 1).toString(16)
        b = Number(16 * (cell.a + cell.b + 2) - 1).toString(16)
        color = "##{r}#{g}#{b}"
        $("#field-table td[data-cell='#{i} #{j}']").css "background-color", color

draw_field_table = (n) ->
    life_cycle = $.life_cycles[n].cells
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
            draw_field_table(0)

$("#get-new-colony").live "click", get_new_life
