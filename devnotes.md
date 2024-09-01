# Dev Notes

### God Rooms

In "god rooms" there is a special effect with lines drawn to connect the rotating gemstones to the god. This is CPU intensive and will require patching to mitigate fps loss.

In `gml_Object_obj_god_gem_slot_controller_Draw_0`:

```gml
var angleIncrement, i, angle, x2, y2;

if (!surface_exists(global.smallDrawingSurface))
{
    global.smallDrawingSurface = surface_create(384, 216);
    drawSurfaceSmall = global.smallDrawingSurface;
}

if (surface_exists(drawSurfaceSmall))
{
    surface_set_target(drawSurfaceSmall);
    draw_clear_alpha(c_white, 0);
    angleIncrement = angleInc;
    
    for (i = 0; i < gemCount; i++)
    {
        with (gemArray[i])
        {
            angle = angle_clamp(point_direction(x, y, focalPointX, focalPointY) - angleIncrement);
            x2 = focalPointX;
            y2 = focalPointY;
            draw_set_color(lineColor);
            draw_line_curved_width(x, y, x2, y2, angle, false, 8, 3);
            draw_line_curved_width(x, y, x2, y2, angle, true, 8, 3);
        }
    }
    
    surface_reset_target();
    draw_surface(drawSurfaceSmall, 0, 0);
}
```

The `for` loop in this script draws lines with angles every frame, which is taxing. Implementing a frameskip option mitigates the issue:

```gml
var framesToSkip, angleIncrement, i, angle;

framesToSkip = 20;

if (!variable_global_exists("frameCounter"))
    global.frameCounter = 0;

if (!variable_global_exists("DrawLines"))
    global.DrawLines = true;

global.frameCounter++;

if (global.frameCounter >= framesToSkip && global.DrawLines)
{
    global.frameCounter = 0;
    
    if (!surface_exists(global.smallDrawingSurface))
        global.smallDrawingSurface = surface_create(384, 216);
    
    if (surface_exists(global.smallDrawingSurface))
    {
        surface_set_target(global.smallDrawingSurface);
        draw_clear_alpha(c_white, 0);
        angleIncrement = angleInc;
        
        for (i = 0; i < gemCount; i++)
        {
            with (gemArray[i])
            {
                angle = angle_clamp(point_direction(x, y, focalPointX, focalPointY) - angleIncrement);
                draw_set_color(lineColor);
                draw_line_curved_width(x, y, focalPointX, focalPointY, angle, false, 8, 3);
                draw_line_curved_width(x, y, focalPointX, focalPointY, angle, true, 8, 3);
            }
        }
        
        surface_reset_target();
    }
}

if (surface_exists(global.smallDrawingSurface))
    draw_surface(global.smallDrawingSurface, 0, 0);
```

The loop only executes every 20 frames and only if DrawLines is true, allowing the loop to be turned off completely if necessary and switching the low fps out in favor of a split-second stutter every 20 frames.