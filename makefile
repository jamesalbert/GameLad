#
# makefile
# Declan Hopkins
# 10/19/2015
#

CC = g++
FRAMEWORK_PATH = /Library/Frameworks

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	FRAMEWORKS = -lSDL2
else
	FRAMEWORKS = -framework SDL2
endif

BIN_NAME = gb-emu
C_FLAGS = -Wall -std=c++14 -g -O2

SRC_PATH = gb-emu
BIN_PATH = gb-emu_bin
SRC_FILES := $(wildcard $(SRC_PATH)/*.cpp)
OBJ_FILES := $(SRC_FILES:$(SRC_PATH)%.cpp=$(BIN_PATH)%.o)

TEST_SRC_PATH = gb-emu-tests
TEST_SRC_FILES := $(wildcard $(TEST_SRC_PATH)/*.cpp)
TEST_OBJ_FILES := $(TEST_SRC_FILES:$(TEST_SRC_PATH)%.cpp=$(BIN_PATH)%.o)

LIB_SRC_PATH = gb-emu-lib
LIB_BIN_PATH = gb-emu-lib_bin
LIB_SRC_FILES := $(wildcard $(LIB_SRC_PATH)/*.cpp)
LIB_OBJ_FILES := $(LIB_SRC_FILES:$(LIB_SRC_PATH)%.cpp=$(LIB_BIN_PATH)%.o)

all: build

# Build the emulator and run it
run: build
	@./$(BIN_PATH)/$(BIN_NAME)

# Build the emulator and run the tests
run_tests: build
	@./$(BIN_PATH)/$(BIN_NAME)-tests

# Build the emulator
build: clean lib emu tests
	@echo "*** Build complete ***"

# Build the emulator library. This is required for the base emulator.
lib: build_lib
	@echo "*** gb-emu-lib Built ***"

build_lib: $(LIB_OBJ_FILES)
	@echo "*** Building gb-emu-lib ***"
	@ar -r $(LIB_BIN_PATH)/libgb-emu.a $(LIB_OBJ_FILES)

$(LIB_BIN_PATH)/%.o: $(LIB_SRC_PATH)/%.cpp
	@echo "*** Compiling" $< "***"
	@$(CC) -F $(FRAMEWORK_PATH) -c $< -o $@ $(C_FLAGS)

# Build the emulator, using gb-emu-lib
emu: build_emu
	@echo "*** gb-emu built ***"

build_emu: $(OBJ_FILES)
	@echo "*** Building gb-emu ***"
	@$(CC) $(OBJ_FILES) -o $(BIN_PATH)/$(BIN_NAME) -F $(FRAMEWORK_PATH) $(FRAMEWORKS) -L$(LIB_BIN_PATH) -I$(LIB_BIN_PATH) -lgb-emu

$(BIN_PATH)/%.o: $(SRC_PATH)/%.cpp
	@echo "*** Compiling" $< "***"
	@$(CC) -I$(LIB_SRC_PATH) -F $(FRAMEWORK_PATH) -c $< -o $@ $(C_FLAGS)

tests: build_tests
	@echo "*** gb-emu-test Built ***"

build_tests: $(OBJ_FILES) $(TEST_OBJ_FILES)
	@echo "*** Building gb-emu-tests ***"
	@$(CC) $(LIB_OBJ_FILES) $(TEST_OBJ_FILES) -o $(BIN_PATH)/$(BIN_NAME)-tests -F $(FRAMEWORK_PATH) $(FRAMEWORKS) -L$(LIB_BIN_PATH) -I$(LIB_BIN_PATH) -lgb-emu

$(BIN_PATH)/%.o: $(TEST_SRC_PATH)/%.cpp
	@echo "*** Compiling" $< " ***"
	@$(CC) -I$(LIB_SRC_PATH) -F $(FRAMEWORK_PATH) -c $< -o $@ $(C_FLAGS)

# Clean up all the raw binaries
clean:
	@echo "*** Cleaning Binaries ***"
	@rm -f -r $(LIB_BIN_PATH)
	@rm -f -r $(BIN_PATH)
	@mkdir $(BIN_PATH);
	@mkdir $(LIB_BIN_PATH);
