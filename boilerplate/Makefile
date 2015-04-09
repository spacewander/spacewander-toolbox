# 通用Makefile
CC := g++
TARGETS := a.out
LDLIBS := 
CCFLAGS := -MP -MMD -std=c++11

SRC := $(wildcard *.cpp)
OBJS := $(SRC:.cpp=.o)
DEPS := $(SRC:.cpp=.d)

run: $(TARGETS)
	@./$(TARGETS)

$(TARGETS): $(OBJS)
	$(CC) $(OBJS) $(LDLIBS) -o $(TARGETS)

%.o : %.cpp
	$(CC) -c $(CCFLAGS) $< -o $@

-include $(DEPS)

clean:
	rm -rf $(OBJS) $(DEPS) $(TARGETS)

.PHONY: clean
