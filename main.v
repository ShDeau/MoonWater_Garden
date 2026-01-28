import gg

const bg_color     = gg.white
const dim = 20

enum Tiles {
    default = 0
}

struct Small_plants {}

struct Med_plants {}

struct Big_plants {}

struct Images {
    image gg.Image
    pos_x int
    pos_y int
}


struct Map {
mut:
    tiles [][]Tiles
    small_plants [][]Small_plants
    med_plants [][]Med_plants
    big_plants [][]Big_plants
    background []Images
    foreground []Images
    tile_size int
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

    app.map.tiles = [][]Tiles{len:20, init:[]Tiles{len:20, init:.default}}

    //lancement du programme/de la fenêtre
    app.ctx.run()
}

fn on_frame(mut app App) {
    app.window_width = gg.window_size().width
	app.window_height = gg.window_size().height
    app.map.tile_size = app.window_height / dim

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
    for i in 1..dim {
        app.ctx.draw_line(i*app.map.tile_size, 0, i*app.map.tile_size, app.window_height, gg.black)
        app.ctx.draw_line(0, i*app.map.tile_size, app.map.tile_size*dim, i*app.map.tile_size, gg.black)
    }
}

fn (app App) draw_square_selected() {
    pos_x := app.tile_x_to_px(app.m_tile_x())
    pos_y := app.tile_x_to_px(app.m_tile_y())
    app.ctx.draw_square_filled(pos_x, pos_y, app.map.tile_size, gg.Color{200, 200, 200, 70})
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
    return (app.ctx.mouse_pos_x / app.map.tile_size)
}

fn (app App) m_tile_y () int {
    return (app.ctx.mouse_pos_y / app.map.tile_size)
}

fn (app App) tile_y_to_px (y int) int {
    return y * app.map.tile_size
}

fn (app App) tile_x_to_px (x int) int {
    return x * app.map.tile_size
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
        tile_size int
        tiles_im []gg.Image
        small_plants_im []gg.Image
        med_plants_im []gg.Image
        big_plants_im []gg.Image
    }
    */
    for y in 0..app.map.tiles.len {
        for x in 0..app.map.tiles[y].len {
            app.ctx.draw_image(app.tile_x_to_px(x), app.tile_y_to_px(y), app.map.tile_size, app.map.tile_size, app.map.tiles_im[int(app.map.tiles[y][x])])
        }
    }
}

fn (m MapEditorPlacingModes) next () MapEditorPlacingModes {
    return MapEditorPlacingModes.from(int(m) + 1) or {MapEditorPlacingModes.tiles}
}

fn (app App) draw_map_editor_ui () {
    app.draw_grid()
    app.draw_square_selected()
    app.ctx.draw_text(0, 0, "placing : ${app.map_ed.placing}, placing number : ${app.map_ed.number_placing}")
}

// fn (ctx &Context) draw_line(x f32, y f32, x2 f32, y2 f32, c Color)
// fn (ctx &Context) draw_square_filled(x f32, y f32, s f32, c Color)
// fn (ctx &Context) draw_image(x f32, y f32, width f32, height f32, img_ &Image)
// fn (ctx &Context) draw_text(x int, y int, text_ string, cfg TextCfg)
