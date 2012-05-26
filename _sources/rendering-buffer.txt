.. Copyright (c) 2011 Francesco Abbate
   
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.

.. highlight:: c++

Rendering Buffer
================

The class :cpp:class:`agg::rendering_buffer` is used to store un image in pixel format with given width and height. The rendering buffer hold a pointer to an :cpp:type:`unsigned char` buffer used to store the image. The rendering buffer does not allocate the memory buffer and is not responsable for its deallocation.

From the logical point of view the rendering buffer is composed of lines and each line it is associated conventionally to the y coordinate. This latter can span the values from ``0`` to ``width - 1`` to identify all the lines of the buffer. The other coordinate identify the columns along the horizontal axe x but we will see that with a rendering buffer you cannot address a particular column or pixel, you can only adress lines.

The rendering buffer does not have any information about how the pixels are stored in each line and it is therefore unable to address a specific pixel. If you need to adress at pixel level you should use a pixel format object.

Usage of Rendering Buffer
-------------------------

We present here a simple example that shows how to create a rendering buffer, how to add pixel format information and how to draw a rectangle using elementary pixel-level operations.

Here the code to to create a rendering buffer and build on top of it a pixel format object::

   const unsigned w = 60, h = 50;
   
   unsigned row_size = pixel_type::pix_width * w;
   unsigned buf_size = row_size * h;
   agg::pod_array<unsigned char> img_buf(buf_size);

   int stride = (app_flip_y ? -row_size : row_size);
   agg::rendering_buffer rbuf(img_buf.data(), w, h, stride);
   agg::pixfmt_bgr24 pixf(rbuf);

In the first part we allocate the memory for the rendering buffer. To know how much memory we allocate we multiply the width and the height of the buffer by the pixel width :cpp:member:`pixel_type::pix_width`. This latter paremeter tell us how much space is needed to store a single pixel.

In this example we have used the automatic array :cpp:class:`agg::pod_array<unsigned char>` to allocate the space but we could have simply used a ``new unsigned char[]`` allocation, the only difference would have been that in this latter case we need to explicitely ``delete []`` the buffer when we have finished.

The rendering buffer is allocated using the following constructor::

   // definition of rendering_buffer
   // typedef row_accessor<int8u> rendering_buffer;
   rendering_buffer(int8u *buffer, unsigned width, unsigned height, int stride);

Incidentally you can note that the rendering_buffer is defined as a specialization of the :cpp:class:`row_accessor` type. The constructor arguments are quite self exaplanatory, the first argument is just the pointer to the memory that we have allocated and the other arguments are the width, height and another argument, the stride. This latter deserve some more explications because it plays an important role about how the row lines are packed.

The stride is actually the offset, expressed in bytes, between the beginning of two consecutive lines in the buffer. To better understand its meaning we can imagine to have a unsigned char pointer ``p`` that point to the beginning of a line in the buffer. In this case we can obtain the pointer to the following line by taking ``p + stride``.

One subtle point about the stride is that is can be either positive or negative. When the stride is negative the logical line of the buffer at y = 0 is stored at the end of the buffer. If the stride is positive then the logical line at y = 0 is stored at the very beginning of the buffer. From the logical point of view the two possibility are equally fine but having the buffer stored in different way can be convenient when you need to pass the buffer to other libraries that can require a specific order for the lines.

The better way to retrive the pointer to a particular line of the buffer is to use the ``row_ptr`` method. It does have the following signature::

  int8u* row_ptr(int y);

This method will work correctly when the stride is positive or negative and if the more safe way to get the address of a particular line of the buffer.

You can see in the code snippet that the following line after the creation of the rendering_buffer is the definition of the pixel_format. The declaration of this latter is trivial and it just takes a reference to the rendering_buffer.

Now we can go back to our code snippet and look at the last line where we instantiate an object of type :cpp:type:`agg::pixfmt_bgr24`. This latter is what we call a "pixel format" object. It does have all the methods that a rendering_buffer has so it is basically a rendering buffer but in addition it does know about how pixel are packed and is therefore capable of addressing each pixel individually.

In the example above we have used the pixel format ``pixfmt_bgr24``. This latter is a quite common choice and is also the default format on MS Windows platform. Other popular format on modern computer are pixfmt_rgb24 and pixfmt_rgba32. The ``pixfmt_bgr24`` is defined as follow::

   typedef pixfmt_alpha_blend_rgb<blender_rgb<rgba8, order_bgr>, rendering_buffer> pixfmt_bgr24;

We said before that a pixel format is able to adress each pixel. To illustrate that we can look at two methods of ``pixfmt_alpha_blend_rgb``::

   void copy_pixel(int x, int y, const color_type& c);
   void blend_pixel(int x, int y, const color_type& c, int8u cover);

These methods, respectively, write a pixel and blend a pixel to a given location. We note that the ``color_type`` here is just :cpp:type:`agg::rgba8` and not something like :cpp:type:`agg::bgr8` as you could have guessed. The rationale of this choice is that you generally work with colors using either agg::rgba or agg::rgba8 format and they get converted to the good format on the fly depending on the type of the pixel format of the rendering buffer. This turns out to be a very convenient feature that is made easy by C++ template mechanisms.

Drawing Something into the Rendering Buffer
-------------------------------------------

The AGG Library is not designed to draw directly into the rendering buffer but there is nothing wrong into the idea of drawing directly using primitives that works directly at pixel level. Of course you know at this point that to address the pixel into a rendering buffer you need to use a pixel format object that wrap the rendering buffer by providing methods for writing pixels at specific locations.

Let us give a look at some of the methods we can use to draw some pixels. We look into the class :cpp:class:`pixfmt_alpha_blend_rgb` and we note the following methods that looks useful::

 void copy_hline(int x, int y, unsigned len, const color_type& c);
 void copy_vline(int x, int y, unsigned len, const color_type& c);
 void copy_pixel(int x, int y, const color_type& c);

These methods are very easy to understand, they write some pixels with the given color, nothing else. The first one writes horizontal lines with a given length, the second vertical lines and the last one just one pixel.

You may wondering what is actually the type :cpp:type:`color_type`. If you remember the type :cpp:type:`pixfmt_bgr24` is defined as ``pixfmt_alpha_blend_rgb<blender_rgb<rgba8, order_bgr>, rendering_buffer>`` and if you dig into the header file you will see that :cpp:type:`color_type` in this case will be actually a simple :cpp:type:`agg::rgba8`.

Since the methods are very primitive we just write a very simple geometric figure, a rectangle drawn with red color. I'm sure that at this point you know how to do that, it is very simple::
  
  agg::rgba8 red(160, 0, 0);

  // we define a rectangle
  agg::rect_i r(20, 20, 40, 38);
 
  unsigned dx = r.x2 - r.x1;
  unsigned dy = r.y2 - r.y1;

  // we draw the four side of the rectangle
  pixf.copy_hline(r.x1, r.y1, dx, red);
  pixf.copy_hline(r.x1, r.y2, dx, red);
  pixf.copy_vline(r.x1, r.y1, dy, red);
  pixf.copy_vline(r.x2, r.y1, dy, red);

We have taken the opportunity to illustrate an useful structure defined in the ``agg_basics.h`` header file, :cpp:type:`agg::rect_i`. This latter is a very simple structure that identify a rectangle by storing the two edges. These have coordinates (x1, y1) and (x2, y2). The type :cpp:type:`agg::rect_i` is actually defined as ``agg::rect_base<int>`` and so you can guess that it can be used also for vertex of type :cpp:type:`double` if needed.

We don't need to spend more time on this very simple example and we make just a final remark. If you attempt to write in a pixel format rendering buffer the coordinates that you provide are not checked and you can cause a memory fault if you write outside of the boundary of the buffer.

You may wonder if there is an AGG class that can perform an automatic check of the coordinates and clip the drawing operation to stay inside the rendering buffer. This structure actually exist and it is the :cpp:class:`renderer_base`. Its instantiation is trivial as it just get a reference to a pixel format, so we could declare it as follow::

  agg::renderer_base<agg::pixfmt_bgr24> rb(pixf);

The renderer_base will allow basically the same kind of operation allowed by a pixel format but in addition it will check for out of boundary pixel and will exclude them from the drawing operations so that writing is always safe.

You have also certainly remarked that the renderer_base takes a type parameter which is the type of the pixel format, in this case :cpp:type:`agg::pixfmt_bgr24`.

Summary
-------

In this chapter we have seen what are the basic structure to store the image like a rendering buffer and a pixel format. We have seen also how different type of pixel format can play and how to use template parameters to define our custom types.

You may wonder where are the more advanced methods to draw more complex geometrical shapes like poygons, lines etc. We will see in the next chapter that this is normally accomplished using VertexSource objects and a rasterizer object that take the VertexSource and draw for us into the rendering buffer. This will be hopefully more clear in the next chapters.

