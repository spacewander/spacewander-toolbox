CC	= gcc 
CFLAGS = -Wall 
CXX	= g++
CXXFLAGS = -std=c++11 -Wall
DEBUG = -g 
RELEASE = -O2 
INCLUDEFLAGS = 
LDFLAGS = 
OBJS	= main.o xml_parser.o tinyXML/tinyxml.o tinyXML/tinyxmlerror.o tinyXML/tinystr.o tinyXML/tinyxmlparser.o 
TARGETS = xmlParser

.PHONY:all
all : CXXFLAGS += $(CDEBUG)
all : CFLAGS += $(DEBUG)
all : $(TARGETS)

.PHONY:release
release : CXXFLAGS += $(RELEASE)
release : CFLAGS += $(RELEASE)
release : $(TARGETS)

$(TARGETS) : $(OBJS)
	$(CXX) -o $@ $^  $(LDFLAGS)

%.o: %.cpp
	$(CXX) -o $@ -c $< $(CXXFLAGS) $(INCLUDEFLAGS)

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CXX) -MM $< $(INCLUDEFLAGS) > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS) $(INCLUDEFLAGS)

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $< $(INCLUDEFLAGS) > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

-include $(OBJS:.o=.d)

.PHONY:clean
clean:
	rm -f $(TARGETS) *.o *.d *.d.* 
	rm -f tinyXML/*.o tinyXML/*.d tinyXML/*.d.* 
