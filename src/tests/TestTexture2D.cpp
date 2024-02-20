#include "TestTexture2D.h"

#include "glad/glad.h"
#include "Debugger.h"
#include "Renderer.h"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "imgui/imgui.h"

#include <memory>

namespace test
{
    TestTexture2D::TestTexture2D()
        : m_Proj(glm::ortho(0.f, 4.0f, 0.f, 3.0f, -1.0f, 1.0f)), m_View(glm::translate(glm::mat4(1.0f), glm::vec3(0, 0, 0))), m_TranslationA(0.5f, 0.5f, 0.0f), m_TranslationB(1.0f, 0.5f, 0.0f), m_Light_pos(0.0f, 0.0f, 0.0f)
    {
        // set up vertex data (and buffer(s)) and configure vertex attributes
        // ------------------------------------------------------------------
        // float vertices[] = {
        //     -0.5f, -0.5f, 0.0f, 0.0f,  // Top Right
        //      0.5f, -0.5f, 1.0f, 0.0f, // Bottom Right
        //      0.5f,  0.5f, 1.0f, 1.0f, // Bottom Left
        //     -0.5f,  0.5f, 0.0f, 1.0f   // Top Left 
        // };
        float vertices[] = {
            -0.8f, -0.45f, -0.8f, -0.45f,  // Top Right
             0.8f, -0.45f,  0.8f, -0.45f, // Bottom Right
             0.8f,  0.45f,  0.8f,  0.45f, // Bottom Left
            -0.8f,  0.45f, -0.8f,  0.45f   // Top Left 
        };
        unsigned int indices[] = {  // Note that we start from 0!
            0, 1, 3,  // First Triangle
            1, 2, 3   // Second Triangle
        };

        GLCall(glEnable(GL_BLEND));
        GLCall(glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA));


        m_VAO = std::make_unique<VertexArray>();

        m_IndexBuffer = std::make_unique<IndexBuffer>(indices, 6);
        m_VertexBuffer = std::make_unique<VertexBuffer>(vertices, 4 * 4 * sizeof(float));
        VertexBufferLayout layout;
        layout.Push<float>(2);
        layout.Push<float>(2);
        m_VAO->AddBuffer(*m_VertexBuffer, layout);


        // build and compile our shader program
        // ------------------------------------

        // Shader shader("res/shaders/Basic.shader");
        m_Shader = std::make_unique<Shader>("res/shaders/RT.shader");
        m_Shader->Bind();
        m_Shader->SetUniform4f("u_Color", 0.8f, 0.3f, 0.8f, 1.0f);


        // float r = 0.0f;
        // float increment = 0.05f;

        m_Texture = std::make_unique<Texture>("res/textures/image002mag.jpeg");
        // m_Texture->Bind();
        m_Shader->SetUniform1i("u_Texture", 0);

        m_VAO->Unbind();
        m_Shader->Unbind();
        m_IndexBuffer->Unbind();
        m_IndexBuffer->Unbind();
        // Renderer renderer;
        // GLCall(glBindBuffer(GL_ARRAY_BUFFER, 0)); // Note that this is allowed, the call to glVertexAttribPointer registered VBO as the currently bound vertex buffer object so afterwards we can safely unbind

        // GLCall(glBindVertexArray(0)); // Unbind VAO (it's always a good thing to unbind any buffer/array to prevent strange bugs), remember: do NOT unbind the EBO, keep it bound to this VAO

        // Uncommenting this call will result in wireframe polygons.
        //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);


    }

    TestTexture2D::~TestTexture2D()
    {
    }

    void TestTexture2D::OnUpdate(float deltaTime)
    {
    }

    void TestTexture2D::OnRender()
    {
        GLCall(glClearColor(0.0f, 0.0f, 0.0f, 1.0f));
        GLCall(glClear(GL_COLOR_BUFFER_BIT));

        Renderer renderer;
        m_Texture->Bind();

        {
            glm::mat4 model = glm::translate(glm::mat4(1.0f), m_TranslationA);
            glm::mat4 mvp = m_Proj * m_View * model;
            m_Shader->Bind();
            m_Shader->SetUniformMat4f("u_MVP", mvp);
            m_Shader->SetUniform3f("u_LightPos", m_Light_pos.x, m_Light_pos.y, m_Light_pos.z);
            renderer.Draw(*m_VAO, *m_IndexBuffer, *m_Shader);
        }
        {
            glm::mat4 model = glm::translate(glm::mat4(1.0f), m_TranslationB);
            glm::mat4 mvp = m_Proj * m_View * model;
            m_Shader->Bind();
            m_Shader->SetUniformMat4f("u_MVP", mvp);
            renderer.Draw(*m_VAO, *m_IndexBuffer, *m_Shader);
        }
    }

    void TestTexture2D::OnImGuiRender()
    {
        ImGuiIO& io = ImGui::GetIO(); (void)io;
        io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
        io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls

        ImGui::Begin("Hello, world!");
        ImGui::SliderFloat3("Translation A", &m_TranslationA.x, 0.0f, 3.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
        ImGui::SliderFloat3("Translation B", &m_TranslationB.x, 0.0f, 3.0f);
        ImGui::SliderFloat3("Light Position", &m_Light_pos.x, -0.1f, 0.1f);
        ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);
        ImGui::End();
    }
}