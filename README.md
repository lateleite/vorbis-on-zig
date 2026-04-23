# Vorbis on Zig

This repository wraps the upstream Vorbis codec library source code with Zig's build system.

Zig 0.15.2 is required.

## Installing as a `build.zig.zon` package

Run in your Zig project:
```sh
zig fetch --save-exact=vorbis git+https://github.com/lateleite/vorbis-on-zig.git
```

Then in your `build.zig` file:
```zig
pub fn build(b: *std.Build) !void {
    // ...

    // Add a reference to the package you've just fetched...
    const dep_vorbis = b.dependency("vorbis", .{
        .target = target,
        .optimize = optimize,
        // force linking mode (default is static)
        // .@"link-mode" = .dynamic,
        // force enable or disable Position Independent Code (PIC) 
        // .pic = true,
    });
    const lib_vorbis = dep_vorbis.artifact("vorbis");

    // ...then link the library to your module
    your_module.linkLibrary(lib_vorbis);

    // ...
}
```

After that, you may use Vorbis' header files in your module.

## License

All (build) code here is released to public domain or under the BSD Zero Clause license, choose whichever you prefer.

You may find Vorbis' license at [https://github.com/xiph/vorbis/blob/8de7001691d9177e30ff16a98b37b1e6fd15f7af/COPYING](https://github.com/xiph/vorbis/blob/8de7001691d9177e30ff16a98b37b1e6fd15f7af/COPYING).
