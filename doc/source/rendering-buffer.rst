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
