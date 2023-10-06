const std = @import("std");
const LazyPath = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cimgui = b.addStaticLibrary(.{
        .name = "cimgui",
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(cimgui);
    cimgui.addIncludePath(.{ .path = "." });
    cimgui.addIncludePath(.{ .path = "imgui" });
    // cimgui.installHeadersDirectory("imgui", ".");
    // cimgui.installHeadersDirectory("generator/output", ".");
    cimgui.linkLibCpp();

    const imgui_flags = &[_][]const u8{
        "-DIMGUI_IMPL_OPENGL_ES2",
        "-DIMGUI_IMPL_API=extern \"C\" ",
    };

    const imgui_src = &[_][]const u8{
        "cimgui.cpp",
        "imgui/imgui.cpp",
        "imgui/imgui_demo.cpp",
        "imgui/imgui_draw.cpp",
        "imgui/imgui_tables.cpp",
        "imgui/imgui_widgets.cpp",
    };

    const SDL2 = b.dependency("SDL2", .{
        .target = target,
        .optimize = optimize,
    });

    cimgui.addCSourceFiles(imgui_src, imgui_flags);

    if (b.option(bool, "sdl", "use sdl backend") orelse true) {
        cimgui.addCSourceFile(.{ .file = .{ .path = "imgui/backends/imgui_impl_sdl2.cpp" }, .flags = imgui_flags });
        if (false) {
            cimgui.linkLibrary(SDL2.artifact("SDL2"));
            cimgui.addIncludePath(.{
                .path = LazyPath.getPath(.{ .path = "include" }, SDL2.builder),
            });
        } else {
            cimgui.linkSystemLibrary("SDL2");
            cimgui.linkSystemLibrary("GLESv2");
        }
    }
    if (b.option(bool, "opengl", "use opengl backend") orelse true) {
        cimgui.addCSourceFile(.{ .file = .{ .path = "imgui/backends/imgui_impl_opengl3.cpp" }, .flags = imgui_flags });
    }

    // examples
    if (b.option(bool, "examples", "Build examples") orelse true) {
        const sdl_exe = b.addExecutable(.{
            .name = "sdl2_opengl3",
            .target = target,
            .optimize = optimize,
        });

        sdl_exe.linkLibCpp();
        sdl_exe.addIncludePath(.{ .path = "./imgui" });
        sdl_exe.addIncludePath(.{ .path = "./imgui/backends" });
        sdl_exe.linkLibrary(cimgui);

        sdl_exe.linkSystemLibrary("SDL2");
        sdl_exe.linkSystemLibrary("GLESv2");
        sdl_exe.addCSourceFiles(&[_][]const u8{
            "imgui/examples/example_sdl2_opengl3/main.cpp",
        }, imgui_flags);
        b.installArtifact(sdl_exe);
    }
}
