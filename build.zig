const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const link_mode = b.option(std.builtin.LinkMode, "link-mode", "Linking mode for the libraries") orelse
        .static;
    const pic = b.option(bool, "pic", "Enable Position Independent Code option");

    const upstream = b.dependency("vorbis", .{});

    const dep_ogg = b.dependency("ogg", .{
        .target = target,
        .optimize = optimize,
    });
    const lib_ogg = dep_ogg.artifact("ogg");

    //
    // upstream vorbis' builds 3 different libraries: vorbis, vorbisenc and vorbisfile.
    // we do the same here now.
    //

    //
    // base vorbis
    //
    const lib_vorbis = b.addLibrary(.{
        .name = "vorbis",
        .linkage = link_mode,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib_vorbis.root_module.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            // VORBIS_SOURCES
            "mdct.c",
            "smallft.c",
            "block.c",
            "envelope.c",
            "window.c",
            "lsp.c",
            "lpc.c",
            "analysis.c",
            "synthesis.c",
            "psy.c",
            "info.c",
            "floor1.c",
            "floor0.c",
            "res0.c",
            "mapping0.c",
            "registry.c",
            "codebook.c",
            "sharedbook.c",
            "lookup.c",
            "bitrate.c",
            // VORBISFILE_SOURCES
            "vorbisfile.c",
            // VORBISENC_SOURCES
            "vorbisenc.c",
        },
    });
    lib_vorbis.root_module.linkLibrary(lib_ogg);

    lib_vorbis.root_module.addIncludePath(upstream.path("include"));
    lib_vorbis.root_module.addIncludePath(upstream.path("lib"));

    lib_vorbis.installHeader(upstream.path("include/vorbis/codec.h"), "vorbis/codec.h");

    //
    // vorbisenc
    //
    const lib_enc = b.addLibrary(.{
        .name = "vorbisenc",
        .linkage = link_mode,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib_enc.root_module.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            // VORBISENC_SOURCES
            "vorbisenc.c",
        },
    });
    lib_enc.root_module.linkLibrary(lib_ogg);
    lib_enc.root_module.linkLibrary(lib_vorbis);

    lib_enc.root_module.addIncludePath(upstream.path("include"));
    lib_enc.root_module.addIncludePath(upstream.path("lib"));

    lib_enc.installHeader(upstream.path("include/vorbis/codec.h"), "vorbis/codec.h");
    lib_enc.installHeader(upstream.path("include/vorbis/vorbisenc.h"), "vorbis/vorbisenc.h");

    //
    // vorbisfile
    //
    const lib_file = b.addLibrary(.{
        .name = "vorbisfile",
        .linkage = link_mode,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib_file.root_module.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            // VORBISFILE_SOURCES
            "vorbisfile.c",
        },
    });
    lib_file.root_module.linkLibrary(lib_ogg);
    lib_file.root_module.linkLibrary(lib_vorbis);

    lib_file.root_module.addIncludePath(upstream.path("include"));
    lib_file.root_module.addIncludePath(upstream.path("lib"));

    lib_file.installHeader(upstream.path("include/vorbis/codec.h"), "vorbis/codec.h");
    lib_file.installHeader(upstream.path("include/vorbis/vorbisfile.h"), "vorbis/vorbisfile.h");

    b.installArtifact(lib_vorbis);
    b.installArtifact(lib_enc);
    b.installArtifact(lib_file);
}
