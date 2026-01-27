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



struct App {
mut:
    gg    &gg.Context = unsafe { nil }
    map Map
    window_width int
    window_height int
}


fn main() {
    mut app := &App{}
    app.gg = gg.new_context(
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
    app.gg.run()
}

fn on_frame(mut app App) {
    app.window_width = gg.window_size().width
	app.window_height = gg.window_size().height
    app.map.tile_size = app.window_height / dim

    $if editor ? {

    }

    //Draw
    app.gg.begin()
    $if editor ? {
        app.draw_grid()
    }
    app.gg.end()
}

fn on_event(e &gg.Event, mut app App){
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {app.gg.quit()}
                else {}
            }
        }
        .mouse_down {
            match e.mouse_button{
                .left{
                    app.draw_square_selected()
                }
                else{}
        }}
        else {}
    }
}

fn (app App) draw_grid() {
    for i in 1..dim {
        app.gg.draw_line(i*app.map.tile_size, 0, i*app.map.tile_size, app.window_height, gg.black)
        app.gg.draw_line(0, i*app.map.tile_size, app.map.tile_size*dim, i*app.map.tile_size, gg.black)
    }
}

fn (app App) draw_square_selected() {
    pos_x := (app.gg.mouse_pos_x / app.map.tile_size) * app.map.tile_size
    pos_y := (app.gg.mouse_pos_y / app.map.tile_size) * app.map.tile_size
    app.gg.draw_square_filled(pos_x, pos_y, app.map.tile_size, gg.gray)
}

// fn (ctx &Context) draw_line(x f32, y f32, x2 f32, y2 f32, c Color)
// fn (ctx &Context) draw_square_filled(x f32, y f32, s f32, c Color)
