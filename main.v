/*
BUG:
    draw_rectangle_selected not at the right place
    draw_tiles doesn't work with vertical motions

TODO:
    add layer for animals
    add layer for object
    problem with superposition with huge plants
    change draw functions for plants
    pane_x and pane_y for plant draw functions

DONE:
    change dim to dim_x dim_y
*/

import gg

const bg_color     = gg.white
const dim_x = 5
const dim_y = 5
const nb_panes_x = 2
const nb_panes_y = 2

enum Tiles {
    default = 0
    default2
}

struct Small_plants {}

struct Med_plants {}

struct Big_plants {}

struct Images {
    image gg.Image
    pos_x int
    pos_y int
    size_x f32
    size_y f32
}


struct Map {
mut:
    tiles [][]Tiles
    small_plants [][]Small_plants
    med_plants [][]Med_plants
    big_plants [][]Big_plants
    background []Images
    foreground []Images
    tile_size_x int
    tile_size_y int
    tiles_im []gg.Image
    small_plants_im []gg.Image
    med_plants_im []gg.Image
    big_plants_im []gg.Image
}

enum MapEditorPlacingModes {
    tiles
    small_plants
    medium_plants
    big_plants
    background_im
    foreground_im
}

struct MapEditor {
mut:
    placing MapEditorPlacingModes
    number_placing int
    pane_x int
    pane_y int
}



struct App {
mut:
    ctx    &gg.Context = unsafe { nil }
    map Map
    map_ed MapEditor
    window_width int
    window_height int
}


fn main() {
    mut app := &App{}
    app.ctx = gg.new_context(
        create_window: true
        fullscreen: true
        window_title: '- Application -'
        user_data: app
        bg_color: bg_color
        frame_fn: on_frame
        event_fn: on_event
        sample_count: 2
    )

    app.map.tiles_im << app.ctx.create_image('default_tile.png') or { panic(err) }
    app.map.tiles_im << app.ctx.create_image('default_tile2.png') or { panic(err) }

    app.map.tiles = [][]Tiles{len:dim_y * nb_panes_y, init:[]Tiles{len:dim_x * nb_panes_x, init:.default}}

    //lancement du programme/de la fenêtre
    app.ctx.run()
}

fn on_frame(mut app App) {
    app.window_width = gg.window_size().width
	app.window_height = gg.window_size().height
    app.map.tile_size_y = app.window_height / dim_y
    app.map.tile_size_x = (app.window_width * 3 / 4) / dim_x

    $if editor ? {
        app.map_editor()
    }
}

fn on_event(e &gg.Event, mut app App){
    $if editor ? {
        app.map_editor_on_event(e)
    } $else {
        match e.typ {
            .key_down {
                match e.key_code {
                    .escape {app.ctx.quit()}
                    else {}
                }
            }
            .mouse_down {
                match e.mouse_button{
                    .left{
                    }
                    else{}
            }}
            else {}
        }
    }
}

fn (app App) draw_grid() {
    for i in 1..dim_x {
        app.ctx.draw_line(i*app.map.tile_size_x, 0, i*app.map.tile_size_x, app.map.tile_size_y*dim_y, gg.black)
    }
    for i in 1..dim_y {
        app.ctx.draw_line(0, i*app.map.tile_size_y, app.map.tile_size_x*dim_x, i*app.map.tile_size_y, gg.black)
    }
}

fn (app App) draw_rectangle_selected() {
    pos_x := app.tile_x_to_px(app.m_tile_x())
    pos_y := app.tile_x_to_px(app.m_tile_y())
    app.ctx.draw_rect_filled(pos_x, pos_y, app.map.tile_size_x, app.map.tile_size_y, gg.Color{200, 200, 200, 70})
}

fn (app App) map_editor () {
    app.map_editor_on_frame()
    app.draw_map_editor()
}

fn (app App) map_editor_on_frame () {
}

fn (app App) draw_map_editor () {
    app.ctx.begin()
    app.draw_map()
    app.draw_map_editor_ui()
    app.ctx.end()
}

fn (mut app App) map_editor_on_event (e &gg.Event) {
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {app.ctx.quit()}
                .p {
                    for y in 0..app.map.tiles.len {
                        for x in 0..app.map.tiles[y].len {
                            print("${app.map.tiles[y][x]} ")
                        }
                        print("\n")
                    }
                    print("\n")
                }
                .right {
                    app.map_ed.placing = app.map_ed.placing.next()
                }
                .left {
                    app.map_ed.placing = app.map_ed.placing.previous()
                }
                .up {
                    app.map_ed.number_placing = app.map_ed.number_placing + 1
                }
                .down {
                    app.map_ed.number_placing = app.map_ed.number_placing - 1
                }
                .w {
                    app.map_ed.pane_y = max(app.map_ed.pane_y - 1, 0)
                }
                .s {
                    app.map_ed.pane_y = min(app.map_ed.pane_y + 1, nb_panes_y - 1)
                }
                .a {
                    app.map_ed.pane_x = max(app.map_ed.pane_x - 1, 0)
                }
                .d {
                    app.map_ed.pane_x = min(app.map_ed.pane_x + 1, nb_panes_x - 1)
                }
                else {}
            }
        }
        .mouse_down {
            match e.mouse_button{
                .left{
                    app.place()
                }
                else{}
        }}
        else {}
    }
}

fn (mut app App) place () {
    match app.map_ed.placing {
        .tiles{
            app.map.tiles[app.m_tile_y()][app.m_tile_x()] = Tiles.from(app.map_ed.number_placing) or {Tiles.default}
        }
        else{}
    }
}

fn (app App) m_tile_x () int {
    return (app.ctx.mouse_pos_x / app.map.tile_size_x)
}

fn (app App) m_tile_y () int {
    return (app.ctx.mouse_pos_y / app.map.tile_size_y)
}

fn (app App) tile_y_to_px (y int) int {
    return y * app.map.tile_size_y
}

fn (app App) tile_x_to_px (x int) int {
    return x * app.map.tile_size_x
}

fn (m MapEditorPlacingModes) next () MapEditorPlacingModes {
    return MapEditorPlacingModes.from(int(m) + 1) or {MapEditorPlacingModes.tiles}
}

fn (m MapEditorPlacingModes) previous () MapEditorPlacingModes {
    return MapEditorPlacingModes.from(int(m) - 1) or {MapEditorPlacingModes.tiles}
}

fn (app App) draw_map_editor_ui () {
    app.draw_grid()
    app.draw_rectangle_selected()
    app.ctx.draw_text(0, 0, "placing : ${app.map_ed.placing}, placing number : ${app.map_ed.number_placing}, pane coordinates : ${app.map_ed.pane_x}, ${app.map_ed.pane_y}")
}

fn (app App) draw_map () {
    /*struct Map {
    mut:
        tiles [][]Tiles
        small_plants [][]Small_plants
        med_plants [][]Med_plants
        big_plants [][]Big_plants
        background []Images
        foreground []Images
        tile_size_x int
        tile_size_y int
        tiles_im []gg.Image
        small_plants_im []gg.Image
        med_plants_im []gg.Image
        big_plants_im []gg.Image
    }
    */
    app.draw_tiles(app.map_ed.pane_x, app.map_ed.pane_y)
    app.draw_background()
    app.draw_small_plants(app.map_ed.pane_x, app.map_ed.pane_y) // order subject to change for the plants
    app.draw_med_plants(app.map_ed.pane_x, app.map_ed.pane_y) // order subject to change for the plants
    app.draw_big_plants(app.map_ed.pane_x, app.map_ed.pane_y) // order subject to change for the plants
    app.draw_player()
    app.draw_foreground()
    app.draw_ui()
}

fn (app App) draw_tiles (pane_x int, pane_y int) {
    for y in dim_y*pane_y..dim_y*(pane_x+1) {
        for x in dim_x*pane_x..dim_x*(pane_x+1) {
            app.ctx.draw_image(app.tile_x_to_px(x - dim_x*pane_x), app.tile_y_to_px(y - dim_y*pane_y), app.map.tile_size_x, app.map.tile_size_y, app.map.tiles_im[int(app.map.tiles[y][x])])
        }
    }
}

fn (app App) draw_background () {
    for i in app.map.background {
        app.ctx.draw_image(i.pos_x, i.pos_y, i.size_x, i.size_y, i.image)
    }
}

fn (app App) draw_foreground () {
    for i in app.map.background {
        app.ctx.draw_image(i.pos_x, i.pos_y, i.size_x, i.size_y, i.image)
    }
}

fn (app App) draw_small_plants (pane_x int, pane_y int) {
    for y in 0..app.map.small_plants.len {
        for x in 0..app.map.small_plants[y].len {
            app.ctx.draw_image(app.tile_x_to_px(x), app.tile_y_to_px(y), app.map.tile_size_x, app.map.tile_size_y, app.map.small_plants_im[int(app.map.tiles[y][x])])
        }
    }
}

fn (app App) draw_med_plants (pane_x int, pane_y int) {
    for y in 0..app.map.med_plants.len {
        for x in 0..app.map.med_plants[y].len {
            app.ctx.draw_image(app.tile_x_to_px(x), app.tile_y_to_px(y), app.map.tile_size_x, app.map.tile_size_y, app.map.med_plants_im[int(app.map.tiles[y][x])])
        }
    }
}

fn (app App) draw_big_plants (pane_x int, pane_y int) {
    for y in 0..app.map.big_plants.len {
        for x in 0..app.map.big_plants[y].len {
            app.ctx.draw_image(app.tile_x_to_px(x), app.tile_y_to_px(y), app.map.tile_size_x, app.map.tile_size_y, app.map.big_plants_im[int(app.map.tiles[y][x])])
        }
    }
}

fn (app App) draw_player () {
    return
}

fn (app App) draw_ui () {
    return
}

// fn (ctx &Context) draw_line(x f32, y f32, x2 f32, y2 f32, c Color)
// fn (ctx &Context) draw_rect_filled(x f32, y f32, s f32, c Color)
// fn (ctx &Context) draw_image(x f32, y f32, width f32, height f32, img_ &Image)
// fn (ctx &Context) draw_text(x int, y int, text_ string, cfg TextCfg)
