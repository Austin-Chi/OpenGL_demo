# APP_NAME = myApp
# BUILD_DIR = ./bin
# C_FILES = ./src/*.cpp ./src/glad.c ./src/vendor/stb_image/stb_image.cpp
# IMGUI_DIR = ./src/vendor/imgui
# C_FILES += $(IMGUI_DIR)/imgui.cpp $(IMGUI_DIR)/imgui_demo.cpp $(IMGUI_DIR)/imgui_draw.cpp $(IMGUI_DIR)/imgui_tables.cpp $(IMGUI_DIR)/imgui_widgets.cpp
# C_FILES += $(IMGUI_DIR)/backends/imgui_impl_glfw.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp

# APP_DEFINES:=
# APP_INCLUDES:= -I./dependencies/include -I./src/vendor -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo
# # APP_INCLUDES:=-I/usr/local/include -I/opt/local/include -I/opt/homebrew/include
# # APP_LINKERS:= -L./dependencies/include/GLFW/lib -lglfw3 
# APP_LINKERS:= -L/usr/local/lib -L/opt/local/lib -L/opt/homebrew/lib -lglfw

# build:
# 	g++ $(C_FILES) -o $(BUILD_DIR)/$(APP_NAME) $(APP_INCLUDES) $(APP_LINKERS)

EXE = myApp
IMGUI_DIR = ./src/vendor/imgui
SOURCES = ./src/Application.cpp ./src/Debugger.cpp ./src/IndexBuffer.cpp ./src/IndexBuffer.cpp ./src/Renderer.cpp ./src/Shader.cpp ./src/Texture.cpp ./src/VertexArray.cpp ./src/VertexBuffer.cpp ./src/tests/TestClearColor.cpp ./src/tests/TestTexture2D.cpp ./src/tests/Test.cpp ./src/glad.c ./src/vendor/stb_image/stb_image.cpp
SOURCES += $(IMGUI_DIR)/imgui.cpp $(IMGUI_DIR)/imgui_demo.cpp $(IMGUI_DIR)/imgui_draw.cpp $(IMGUI_DIR)/imgui_tables.cpp $(IMGUI_DIR)/imgui_widgets.cpp
SOURCES += $(IMGUI_DIR)/backends/imgui_impl_glfw.cpp $(IMGUI_DIR)/backends/imgui_impl_opengl3.cpp
# OBJS = $(addsuffix .o, $(basename $(notdir $(SOURCES))))
OBJS = $(addprefix $(OUTS), $(addsuffix .o, $(basename $(notdir $(SOURCES)))))
OUTS = src/output/

UNAME_S := $(shell uname -s)
LINUX_GL_LIBS = -lGL

CXXFLAGS = -std=c++14 -I$(IMGUI_DIR) -I$(IMGUI_DIR)/backends
CXXFLAGS += -g -Wall -Wformat
LIBS =

ifeq ($(UNAME_S), Linux)
    LIBS += $(LINUX_GL_LIBS) `pkg-config --static --libs glfw3`
    CXXFLAGS += `pkg-config --cflags glfw3`
endif

ifeq ($(UNAME_S), Darwin)
    LIBS += -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo
    LIBS += -L/usr/local/lib -L/opt/local/lib -L/opt/homebrew/lib
    LIBS += -lglfw
    CXXFLAGS += -I/usr/local/include -I/opt/local/include -I/opt/homebrew/include -I./dependencies/include -I./src/vendor -I./src -I./src/tests
endif

$(OUTS)%.o:%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTS)%.o:src/tests/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTS)%.o:$(IMGUI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTS)%.o:$(IMGUI_DIR)/backends/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTS)%.o: src/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTS)%.o: src/vendor/stb_image/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OUTS)%.o: src/%.c
	$(CXX) $(CXXFLAGS) -c -o $@ $<

all: $(EXE)
	@echo Build complete for $(ECHO_MESSAGE)

$(EXE): $(OBJS)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LIBS) -v


clean:
	rm -f $(EXE) $(OBJS)
