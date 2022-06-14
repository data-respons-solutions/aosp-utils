BUILD ?= build
CFLAGS += -Wall -Wextra -Werror -std=gnu++14 -Wno-error=sign-compare -Wno-error=attributes
CFLAGS += $(addprefix -I$(shell pwd)/, core/libsparse/include libbase/include)

ifeq ($(abspath $(BUILD)),$(shell pwd)) 
$(error "ERROR: Build dir can't be equal to source dir")
endif

all: simg2img img2simg append2simg

LIBSPARSE_PATH = core/libsparse
LIBSPARSE_SRCS := $(addprefix $(LIBSPARSE_PATH)/, backed_block.cpp output_file.cpp sparse.cpp sparse_crc32.cpp sparse_err.cpp sparse_read.cpp)
LIBSPARSE_OBJS := $(addprefix $(BUILD)/, $(LIBSPARSE_SRCS:.cpp=.o))

LIBBASE_PATH = libbase
LIBBASE_SRCS := $(addprefix $(LIBBASE_PATH)/, mapped_file.cpp stringprintf.cpp)
LIBBASE_OBJS := $(addprefix $(BUILD)/, $(LIBBASE_SRCS:.cpp=.o))

.PHONY: simg2img
simg2img: $(BUILD)/$(LIBSPARSE_PATH)/simg2img

.PHONY: img2simg
img2simg: $(BUILD)/$(LIBSPARSE_PATH)/img2simg

.PHONY: append2simg
append2simg: $(BUILD)/$(LIBSPARSE_PATH)/append2simg

$(BUILD)/$(LIBSPARSE_PATH)/simg2img: $(BUILD)/$(LIBSPARSE_PATH)/simg2img.o $(LIBBASE_OBJS) $(LIBSPARSE_OBJS)
	$(CXX) -o $@ $^ -lz $(LDFLAGS)

$(BUILD)/$(LIBSPARSE_PATH)/img2simg: $(BUILD)/$(LIBSPARSE_PATH)/img2simg.o $(LIBBASE_OBJS) $(LIBSPARSE_OBJS)
	$(CXX) -o $@ $^ -lz $(LDFLAGS)
	
$(BUILD)/$(LIBSPARSE_PATH)/append2simg: $(BUILD)/$(LIBSPARSE_PATH)/append2simg.o $(LIBBASE_OBJS) $(LIBSPARSE_OBJS)
	$(CXX) -o $@ $^ -lz $(LDFLAGS)
	
$(BUILD)/$(LIBSPARSE_PATH)/%.o: $(LIBSPARSE_PATH)/%.cpp 
	mkdir -p $(dir $@)
	$(CXX) $(CFLAGS) -c $< -o $@

$(BUILD)/$(LIBBASE_PATH)/%.o: $(LIBBASE_PATH)/%.cpp 
	mkdir -p $(dir $@)
	$(CXX) $(CFLAGS) -c $< -o $@