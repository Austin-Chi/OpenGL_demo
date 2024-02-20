#pragma once

#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>


// Use __builtin_debugtrap() for ARM64 architecture on macOS
#if defined(__APPLE__) && defined(__arm64__)
    #define DEBUG_BREAK __builtin_debugtrap()
#else
    // Fallback to a generic approach (you can customize this based on your needs)
    #define DEBUG_BREAK std::cerr << "Debugger breakpoint: " << __FILE__ << ":" << __LINE__ << std::endl; std::terminate();
#endif

#define ASSERT(x) if (!(x)) DEBUG_BREAK
#define GLCall(x) GLClearError();\
    x;\
    ASSERT(GLLogCall(#x, __FILE__, __LINE__))

void GLClearError();
bool GLLogCall(const char* function, const char* file, int line);