import gg

const bg_color     = gg.blue
const dim = 20

enum Tiles {
    default
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
    placing MapEditorPlacingModes
}



struct App {
mut:
    ctx    &gg.Context = unsafe { nil }
    map Map
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
    pos_x := (app.ctx.mouse_pos_x / app.map.tile_size) * app.map.tile_size
    pos_y := (app.ctx.mouse_pos_y / app.map.tile_size) * app.map.tile_size
    app.ctx.draw_square_filled(pos_x, pos_y, app.map.tile_size, gg.gray)
}

fn (app App) map_editor () {
    app.map_editor_on_frame()
    app.draw_map_editor()
}

fn (app App) map_editor_on_frame () {
}

fn (app App) draw_map_editor () {
    app.ctx.begin()
    app.draw_grid()
    app.draw_square_selected()
    app.ctx.end()
}

fn (app App) map_editor_on_event (e &gg.Event) {
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

// fn (ctx &Context) draw_line(x f32, y f32, x2 f32, y2 f32, c Color)
// fn (ctx &Context) draw_square_filled(x f32, y f32, s f32, c Color)
