#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

#include "Renderer.h"
#include "VertexBuffer.h"
#include "IndexBuffer.h"
#include "VertexArray.h"
#include "Shader.h"
#include "Texture.h"
#include "Debugger.h"

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

#include "tests/TestClearColor.h"
#include "tests/TestTexture2D.h"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow *window);

// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;
const char* glsl_version = "#version 330 core";

int main()
{
    // glfw: initialize and configure
    // ------------------------------
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
    
    // glfw window creation
    // --------------------
    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "LearnOpenGL", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // glfwSwapInterval(1);

    // glad: load all OpenGL function pointers
    // ---------------------------------------
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    std::cout << glGetString(GL_VERSION) << std::endl;
    {

 
    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    // float vertices[] = {
    //     -0.5f, -0.5f, 0.0f, 0.0f,  // Top Right
    //      0.5f, -0.5f, 1.0f, 0.0f, // Bottom Right
    //      0.5f,  0.5f, 1.0f, 1.0f, // Bottom Left
    //     -0.5f,  0.5f, 0.0f, 1.0f   // Top Left 
    // };
    // unsigned int indices[] = {  // Note that we start from 0!
    //     0, 1, 3,  // First Triangle
    //     1, 2, 3   // Second Triangle
    // };

    GLCall(glEnable(GL_BLEND));
    GLCall(glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA));

    // VertexArray va;
    // VertexBuffer vb(vertices, 4 * 4 * sizeof(float));

    // VertexBufferLayout layout;
    // layout.Push<float>(2);
    // layout.Push<float>(2);
    // va.AddBuffer(vb, layout);

    // IndexBuffer ib(indices, 6);

    // glm::mat4 proj = glm::ortho(0.f, 4.0f, 0.f, 3.0f, -1.0f, 1.0f);
    // glm::mat4 view = glm::translate(glm::mat4(1.0f), glm::vec3(0, 0, 0));

    // // build and compile our shader program
    // // ------------------------------------

    // Shader shader("res/shaders/Basic.shader");
    // shader.Bind();
    // shader.SetUniform4f("u_Color", 0.8f, 0.3f, 0.8f, 1.0f);


    // // float r = 0.0f;
    // // float increment = 0.05f;

    // Texture texture("res/textures/image002mag.jpeg");
    // texture.Bind();
    // shader.SetUniform1i("u_Texture", 0);

    // va.Unbind();
    // shader.Unbind();
    // vb.Unbind();
    // ib.Unbind();
    Renderer renderer;
    // GLCall(glBindBuffer(GL_ARRAY_BUFFER, 0)); // Note that this is allowed, the call to glVertexAttribPointer registered VBO as the currently bound vertex buffer object so afterwards we can safely unbind

    // GLCall(glBindVertexArray(0)); // Unbind VAO (it's always a good thing to unbind any buffer/array to prevent strange bugs), remember: do NOT unbind the EBO, keep it bound to this VAO

    // Uncommenting this call will result in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);


    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls


    // Setup Dear ImGui style
    ImGui::StyleColorsDark();
    //ImGui::StyleColorsLight();

    // Setup Platform/Renderer backends
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init(glsl_version);

    // glm::vec3 translationA(0.5, 0.5, 0);
    // glm::vec3 translationB(1.0, 0.5, 0);

    test::Test* currentTest = nullptr;
    test::TestMenu* testMenu = new test::TestMenu(currentTest);
    currentTest = testMenu;
    testMenu->RegisterTest<test::TestClearColor>("Clear Color");
    testMenu->RegisterTest<test::TestTexture2D>("Texture 2D");

    // Game loop
    while (!glfwWindowShouldClose(window))
    {
        // Check if any events have been activiated (key pressed, mouse moved etc.) and call corresponding response functions
        glfwPollEvents();

        // Render
        // Clear the colorbuffer
        GLCall(glClearColor(0.2f, 0.3f, 0.3f, 1.0f));
        renderer.Clear();

        // Start the Dear ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        if(currentTest)
        {
            currentTest->OnUpdate(0.0f);
            currentTest->OnRender();
            ImGui::Begin("Test");
            if(currentTest != testMenu && ImGui::Button("<-"))
            {
                delete currentTest;
                currentTest = testMenu;
            }
            currentTest->OnImGuiRender();
            ImGui::End();
        }

        // shader.Bind();
        // // shader.SetUniform4f("u_Color", r, 0.3f, 0.8f, 1.0f);

        // {
        //     glm::mat4 model = glm::translate(glm::mat4(1.0f), translationA);
        //     glm::mat4 mvp = proj * view * model;
        //     shader.SetUniformMat4f("u_MVP", mvp);
        //     renderer.Draw(va, ib, shader);
        // }

        // // va.Bind();
        // // ib.Bind();
        // {
        //     glm::mat4 model = glm::translate(glm::mat4(1.0f), translationB);
        //     glm::mat4 mvp = proj * view * model;
        //     shader.SetUniformMat4f("u_MVP", mvp);
        //     renderer.Draw(va, ib, shader);
        // }
        // //glDrawArrays(GL_TRIANGLES, 0, 6);
        // // GLCall(glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0));
        // // GLCall(glBindVertexArray(0));

        // if (r > 1.0f)
        //     increment = -0.05f;
        // else if (r < 0.0f)
        //     increment = 0.05f;

        // r += increment;

        // // 2. Show a simple window that we create ourselves. We use a Begin/End pair to create a named window.
        // {
        //     ImGui::Begin("Hello, world!");
        //     ImGui::SliderFloat3("Translation A", &translationA.x, 0.0f, 3.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
        //     ImGui::SliderFloat3("Translation B", &translationB.x, 0.0f, 3.0f);
        //     ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);
        //     ImGui::End();
        // }

        // Rendering
        ImGui::Render();
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        // Swap the screen buffers
        glfwSwapBuffers(window);
    }
    delete currentTest;
    if(currentTest != testMenu)
        delete testMenu;
    // Properly de-allocate all resources once they've outlived their purpose
    // GLCall(glDeleteVertexArrays(1, &VAO));

    // optional: de-allocate all resources once they've outlived their purpose:
    // ------------------------------------------------------------------------
    // glDeleteVertexArrays(1, &VAO);
    // glDeleteBuffers(1, &VBO);
    // glDeleteProgram(shader);
    }

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    // glfw: terminate, clearing all previously allocated GLFW resources.
    // ------------------------------------------------------------------
    glfwTerminate();
    return 0;
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow *window)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

// glfw: whenever the window size changed (by OS or user resize) this callback function executes
// ---------------------------------------------------------------------------------------------
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    // make sure the viewport matches the new window dimensions; note that width and 
    // height will be significantly larger than specified on retina displays.
    GLCall(glViewport(0, 0, width, height));
}