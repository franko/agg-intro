.. highlight:: c++

Rendering Buffer
================

Here we are:

Here some code::

   #include <stdio.h>
   #include <string.h>
   
   #include "agg_rendering_buffer.h"
   #include "agg_rasterizer_scanline_aa.h"
   #include "agg_pixfmt_rgb.h"
   #include "agg_scanline_p.h"
   #include "agg_renderer_scanline.h"
   #include "agg_color_rgba.h"
   #include "agg_array.h"
   #include "util/agg_color_conv_rgb8.h"
   
   #include "agg_path_storage.h"
   #include "agg_ellipse.h"
   
   const bool app_flip_y = true;
   
   bool save_image_file (agg::rendering_buffer& rbuf, const char *fn)
   {
     FILE* fd = fopen(fn, "wb");
     if(fd == 0) return false;
               
     unsigned w = rbuf.width();
     unsigned h = rbuf.height();
               
     fprintf(fd, "P6\n%d %d\n255\n", w, h);
                   
     unsigned y; 
     agg::pod_array<unsigned char> row_buf(w * 3);
     unsigned char *tmp_buf = row_buf.data();
   
     for(y = 0; y < rbuf.height(); y++)
       {
         const unsigned char* src = rbuf.row_ptr(app_flip_y ? h - 1 - y : y);
         agg::color_conv_row(tmp_buf, src, w, agg::color_conv_bgr24_to_rgb24());
         fwrite(tmp_buf, 1, w * 3, fd);
       }
   
     fclose(fd);
     return true;
   }
   
   int
   main()
   {
     typedef agg::pixfmt_bgr24 pixel_type;
     
     const unsigned w = 60, h = 50;
     
     unsigned row_size = pixel_type::pix_width * w;
     unsigned buf_size = row_size * h;
     agg::pod_array<unsigned char> img_buf(buf_size);
     
     agg::rendering_buffer rbuf(img_buf.data(), w, h, app_flip_y ? -row_size : row_size);
     pixel_type pixf(rbuf);
     
     typedef agg::renderer_base<pixel_type> renderer_base;
     typedef agg::renderer_scanline_aa_solid<renderer_base> renderer_solid;
   
     renderer_base rb(pixf);
     renderer_solid rs(rb);
     
     agg::rasterizer_scanline_aa<> ras;
     agg::scanline_p8 sl;
   
     agg::rgba8 white(255, 255, 255);
     rb.clear(white);
   
     agg::rgba8 color(160, 0, 0);
   
     agg::ellipse shape(30.0, 25.0, 12.0, 12.0);
     
     ras.add_path(shape);
     rs.color(color);
     agg::render_scanlines(ras, sl, rs);
     
     save_image_file(rbuf, "output.ppm");
     
     return 0;
   }
   
and here we continue.
