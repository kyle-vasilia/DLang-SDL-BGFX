import std.stdio;
import bindbc.sdl;
import bindbc.bgfx;

import gl3n.math;
import gl3n.linalg;

struct Vertex {
    float x;
    float y;
    float z;
    Uint32 rgba;
}

static immutable Vertex[] quad = [
    {   0.5f,  0.5f, 0.0f,  rgba : 0xff0000ff},
    {   0.5f, -0.5f, 0.0f,  rgba : 0xff0000ff},
    {  -0.5f, -0.5f, 0.0f,  rgba : 0xff0000ff},
    {  -0.5f,  0.5f, 0.0f, rgba : 0xff0000ff}
];

static const Uint16[] index = [
    0, 1, 3,  
    1, 2, 3
];

bgfx_shader_handle_t loadShader(string name) {
    import core.stdc.stdio;
    import std.string : toStringz;
    
    //Use C-Style File I/O - issue with loading binary data with regular.
    FILE *file = fopen(toStringz(name), "rb");
    scope(exit) fclose(file);
    fseek(file, 0, SEEK_END);
    const auto size = ftell(file);
    fseek(file, 0, SEEK_SET);

    ubyte[] data = new ubyte[size+1];
    
    fread(&data[0], size, 1, file);
    data[size] = '\0'; //Null-terminate it
   
    const bgfx_memory_t *mem = bgfx_copy(&data[0],cast(uint)data.length);
   
    bgfx_shader_handle_t handle= bgfx_create_shader(mem);
    bgfx_set_shader_name(handle, toStringz(name), cast(int)name.length);
    return handle;

}

immutable static uint width = 900;
immutable static uint height = 600;
string shaderDir = "shader/";

void main() { 
    writeln(loadSDL() == sdlSupport);
    writeln(loadBgfx());

    SDL_Init(SDL_INIT_VIDEO);
    SDL_Window *win = SDL_CreateWindow("Title",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
        width, height, SDL_WINDOW_SHOWN);

    SDL_SysWMinfo wmi;
    SDL_VERSION(&wmi.version_);
    SDL_GetWindowWMInfo(win, &wmi);
    
    bgfx_platform_data_t pd;

    
    version(Windows) {
    pd.ndt = null;
    pd.nwh = wmi.info.win.window;
        shaderDir ~= "Windows";
    }
    version(linux) {
        pd.ndt = wmi.info.x11.display;
        pd.nwh = cast(uint*)wmi.info.x11.window;
        shaderDir ~= "Linux";
    }
   
    

    pd.context = null;
    pd.backBuffer = null;
    pd.backBufferDS = null;

    bgfx_set_platform_data(&pd);

    bgfx_init_t init;
    init.type = bgfx_renderer_type_t.BGFX_RENDERER_TYPE_OPENGL;
    init.vendorId = BGFX_PCI_ID_NONE;
    init.resolution.width = width;
    init.resolution.height = height;
    init.resolution.reset = BGFX_RESET_VSYNC;
    
    bgfx_init(&init);



 
    bgfx_vertex_layout_t vertexFmt;
    bgfx_vertex_layout_begin(&vertexFmt, bgfx_renderer_type_t.BGFX_RENDERER_TYPE_NOOP);
    bgfx_vertex_layout_add(&vertexFmt, bgfx_attrib_t.BGFX_ATTRIB_POSITION, 
        3, bgfx_attrib_type_t.BGFX_ATTRIB_TYPE_FLOAT, false, false);
    bgfx_vertex_layout_add(&vertexFmt, bgfx_attrib_t.BGFX_ATTRIB_COLOR0,
        4, bgfx_attrib_type_t.BGFX_ATTRIB_TYPE_UINT8, true, false);
    bgfx_vertex_layout_end(&vertexFmt);

    bgfx_vertex_buffer_handle_t vbo;
    bgfx_index_buffer_handle_t ibo;
    vbo = bgfx_create_vertex_buffer(
        bgfx_make_ref(quad.ptr, quad.length * Vertex.sizeof),
        &vertexFmt,
        0
    );

    ibo = bgfx_create_index_buffer(
        bgfx_make_ref(index.ptr, index.sizeof),
        0
    );



    bgfx_shader_handle_t vs = loadShader(shaderDir ~ "/basic_vs.bin");
    bgfx_shader_handle_t fs = loadShader(shaderDir ~"/basic_fs.bin");
    bgfx_program_handle_t program = bgfx_create_program(vs, fs, true);
    

    bgfx_reset(900, 600, BGFX_RESET_VSYNC, 
        bgfx_texture_format_t.BGFX_TEXTURE_FORMAT_RGBA32U);


    bgfx_set_debug(BGFX_DEBUG_TEXT | BGFX_DEBUG_STATS);

    bgfx_set_view_clear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH,
        0x303030ff, 1.0f, 0);
    bgfx_touch(0);

    bool running = true;
    SDL_Event e;
    while(running) {
        while(SDL_PollEvent(&e)) {
            switch(e.type) {
                case SDL_QUIT:
                    running = false; 
                    break;
                default:
                    break;
            }
        }

        bgfx_set_view_rect(0, 0, 0, width, height);
        bgfx_touch(0);
        
        bgfx_set_vertex_buffer(0, vbo, 0, 4);
        bgfx_set_index_buffer(ibo, 0, 6);
        
        ulong state = 0 
        | BGFX_STATE_WRITE_R 
        | BGFX_STATE_WRITE_G
        | BGFX_STATE_WRITE_B 
        | BGFX_STATE_WRITE_A;

        bgfx_set_state(state, 0);
        


        bgfx_submit(0, program, 0, BGFX_DISCARD_NONE);


        bgfx_frame(false);
    }
    bgfx_destroy_vertex_buffer(vbo);
    bgfx_destroy_index_buffer(ibo);
    bgfx_destroy_program(program);
    bgfx_shutdown();
    SDL_DestroyWindow(win);
    SDL_Quit();
}
