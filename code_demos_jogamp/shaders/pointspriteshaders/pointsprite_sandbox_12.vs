varying vec4 frag_color;

uniform float time;
/**
 **   __ __|_  ___________________________________________________________________________  ___|__ __
 **  //    /\                                           _                                  /\    \\  
 ** //____/  \__     __ _____ _____ _____ _____ _____  | |     __ _____ _____ __        __/  \____\\ 
 **  \    \  / /  __|  |     |   __|  _  |     |  _  | | |  __|  |     |   __|  |      /\ \  /    /  
 **   \____\/_/  |  |  |  |  |  |  |     | | | |   __| | | |  |  |  |  |  |  |  |__   "  \_\/____/   
 **  /\    \     |_____|_____|_____|__|__|_|_|_|__|    | | |_____|_____|_____|_____|  _  /    /\     
 ** /  \____\                       http://jogamp.org  |_|                              /____/  \    
 ** \  /   "' _________________________________________________________________________ `"   \  /    
 **  \/____.                                                                             .____\/     
 **
 ** Procedural point sprite vertex shader generating some interesting patterns color- and
 ** depth wise. Most of these shaders are taken from Mr.Doobs "GLSL Sandbox" wich can be found
 ** here: http://glsl.heroku.com/ (credits+links are given if possible). Some minor adjustments
 ** have been made to integrate them here as pointsprite shaders. The rest of the procedural 
 ** shaders are from my "Monkey Mathica" series of procedural texture shaders.
 **
 **/

uniform vec2 resolution;
uniform sampler2D texture;

vec4 getSample2D(vec2 position) {
    float divider = position.y*25;
    float modulox = mod(position.x,1.0/divider)*divider; 
    vec4 fragment;
    float red = abs(sin(position.x*position.y+time/5.0));
    float green = abs(sin(position.x*position.y+time/4.0));
    float blue = abs(sin(position.x*position.y+time/3.0));
    vec4 fragmentcolor = vec4(red,green,blue,1.0)*10;
    if (modulox>0.5) {
        fragment = vec4(modulox,modulox,modulox,1.0)/fragmentcolor;
    } else {
        fragment = vec4(1.0-modulox,1.0-modulox,1.0-modulox,1.0)/fragmentcolor;    
    }
    return fragment;
}

vec4 getVortex(vec2 position) {
    vec2 uv;
    float a = atan(position.y,position.x);
    float r = sqrt(dot(position,position));
    uv.x = cos(0.06*time) + cos(cos(0.02*time)+a)/r;
    uv.y = cos(0.03*time) + sin(cos(0.01*time)+a)/r;
    vec3 col = getSample2D(uv*1.0).rgb;
    return vec4(col*r*r,1.0);
}

void main(void) {
    gl_TexCoord[0] = gl_MultiTexCoord0;

    frag_color = getVortex(-1.0+2.0*gl_TexCoord[0].st);
    /*
    float supersamplingfactor = 0.125;
    float n = 0.0;
    vec4 current_frag_color = vec4(0.0,0.0,0.0,1.0);    
    for (float x = 0.0; x < 1.0; x += float(supersamplingfactor)) {
        for (float y = 0.0; y < 1.0; y += float(supersamplingfactor)) {
            vec2 fragmentcoord = ((-1.0+2.0*gl_TexCoord[0].st)*resolution.xy)+vec2(x, y); 
            current_frag_color += getVortex(fragmentcoord/resolution.xy);
            n += 1.0;
        }
    }
    frag_color = current_frag_color/n;
    */

    float gray = dot(frag_color.rgb, vec3(0.299, 0.587, 0.114)); 
    vec4 raw_vertex = gl_Vertex;
    raw_vertex.z -= min(gray*10.0,10.0);        
    gl_Position = gl_ModelViewProjectionMatrix*raw_vertex;
    gl_PointSize = max(30.0-(gl_Position.z*0.125),4.0);
}