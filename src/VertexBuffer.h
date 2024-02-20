#pragma once

struct Vec2
{
    float x, y;
};//since float array are not assignable like {0.0, ...} we need to create a struct to hold the data

struct Vec3
{
    float x, y, z;
};

struct Vec4
{
    float x, y, z, w;
};
struct Vertex
{
    Vec3 Position;
    Vec4 Color;
    Vec2 TexCoords;
    float TexID;
};

class VertexBuffer
{
private:
    unsigned int m_RendererID;
public:
    VertexBuffer(const void* data, unsigned int size);
    ~VertexBuffer();

    void Bind() const;
    void Unbind() const;
};