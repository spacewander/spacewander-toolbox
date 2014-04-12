#!/usr/bin/env ruby
# encoding: UTF-8

script = $0
filename = ARGV.first
if filename == nil
  puts "Usage: #{script} schema \n 输入.schema文件来生成对应的Makefile" 
  show_schema
  exit(1)
end

def show_schema 
  puts "
  .schema文件格式：
  文件名 xxx.schema
  PATH = 生成的Makefile所在的文件夹（如果空缺，默认当前目录）
  CC    = (如果空缺默认gcc)
  CXX   = (如果空缺默认g++)
  CFLAGS =  (如果空缺默认-Wall)
  CXXFLAGS =  (如果空缺默认 -std=c++11 -Wall)
  TARGETS = 目标文件名
  # 以下为可选项
  INCLUDEFLAGS = xxx
  LDFLAGS   = xxx
  "
end

# 读取schema
begin
  schema = {}
  if filename =~ /.schema$/ && File.file?(filename)
    IO.foreach(filename) do |line|
      option = line.split("=", 2)
      option.each {|i| i.strip! }
      option[0].upcase! # 变量名转换成大写
      schema[option[0]] = option[1]
    end
  else
    # 把输入当作要生成的目标，然后其他设置按照默认的来
    schema["TARGETS"] = filename
  end
rescue Errno::ENOENT
  puts "#{filename} not found!"
end

def exit_if_variable_not_exist var
  puts "需要有生成Makefile所需的变量 #{var}"
  show_schema
  exit(1)
end

# 检查是否有必须的项，并构造Makefile字符串
input = ""
if schema.has_key?("PATH") && schema["PATH"] != ""
  path = schema["PATH"]
else
  path = Dir.pwd # 如果没有给出PATH变量，那么就以当前文件夹为工作目录
  puts "由于schema中没有给出路径变量，将以当前目录 #{path} 作为生成Makefile的目录"
  puts "如果不想继续，使用Ctrl+c或q退出，否则按任意其他键继续"
  user_choice = $stdin.gets.chomp
  exit(1) if user_choice == 'q'
end

if schema.has_key?("CC") && schema["CC"] != ""
  input += "CC\t= #{schema["CC"]}\n"
else
  input += "CC\t= gcc \n"
end

if schema.has_key?("CFLAGS")
  input += "CFLAGS = #{schema["CFLAGS"]}\n"
else
  input += "CFLAGS = -Wall \n"
end

if schema.has_key?("CXX") && schema["CXX"] != ""
  input += "CXX\t= #{schema["CXX"]}\n"
else
  input += "CXX\t= g++ \n"
end

if schema.has_key?("CXXFLAGS")
  input += "CXXFLAGS = #{schema["CXXFLAGS"]}\n"
else
  input += "CXXFLAGS = -std=c++11 -Wall \n"
end

input += "DEBUG = -g \n"
input += "RELEASE = -O2 \n"
#TODO
if schema.has_key?("INCLUDEFLAGS")
  input += "INCLUDEFLAGS = #{schema["INCLUDEFLAGS"]}\n"
else
end

if schema.has_key?("LDFLAGS")
  input += "LDFLAGS = #{schema["LDFLAGS"]}\n"
else
end

# 遍历项目文件夹，并生成对应的.o文件队列
begin
  Dir.chdir(path)
rescue Errno::ENOENT => e
  puts e.message
  exit(1)
end

def traverse_dir_for_file dirname, filetype, prefix
  files = ""
  Dir.glob("**/*.#{filetype}").each do |f|
    filename = f.partition(/\.#{filetype}$/)[0]
    filename = "#{prefix + filename}.o"
    files += filename
    files += " "
  end
  files
end

def traverse_dir_for_dir dirname, prefix
  dirs = []
  Dir.glob("**/*").each do |dir|
    if File.directory?(dir)
      dirs.push(dir)
    end
  end
  dirs
end

files = traverse_dir_for_file '.', 'cpp', ''
files += traverse_dir_for_file '.', 'c', ''
dirs = traverse_dir_for_dir '.', ''

# 遍历结束
if files == ""
  puts "找不到所需的cpp或c文件。生成结束。生成失败" 
  exit(1)
end
input += "OBJS\t= #{files}\n"

if schema.has_key?("TARGETS") && schema["TARGETS"] != ""
  input += "TARGETS = #{schema["TARGETS"]}\n"
else
  exit_if_variable_not_exist "TARGETS"
end

# 生成需要清除的依赖文件和链接文件的字符串
rm_list = ""
dirs.each do |dir|
  rm_list += "\trm -f #{dir}/*.o #{dir}/*.d #{dir}/*.d.* \n"
end

# Makefile 需要 tab 而不是 空格
# 另外这里在编译最终目标文件的时候使用的是C++编译器，因为C++编译器可以链接C文件编译出来的.o文件
# 而反过来就不行
input += "
.PHONY:all
all : CXXFLAGS += $(CDEBUG)
all : CFLAGS += $(DEBUG)
all : $(TARGETS)

.PHONY:release
release : CXXFLAGS += $(RELEASE)
release : CFLAGS += $(RELEASE)
release : $(TARGETS)

$(TARGETS) : $(OBJS)
\t$(CXX) -o $@ $^  $(LDFLAGS)

%.o: %.cpp
\t$(CXX) -o $@ -c $< $(CXXFLAGS) $(INCLUDEFLAGS)

%.d: %.cpp
\t@set -e; rm -f $@; \\
\t$(CXX) -MM $< $(INCLUDEFLAGS) > $@.$$$$; \\
\tsed 's,\\($*\\)\\.o[ :]*,\\1.o $@ : ,g' < $@.$$$$ > $@; \\
\trm -f $@.$$$$

%.o: %.c
\t$(CC) -o $@ -c $< $(CFLAGS) $(INCLUDEFLAGS)

%.d: %.c
\t@set -e; rm -f $@; \\
\t$(CC) -MM $< $(INCLUDEFLAGS) > $@.$$$$; \\
\tsed 's,\\($*\\)\\.o[ :]*,\\1.o $@ : ,g' < $@.$$$$ > $@; \\
\trm -f $@.$$$$

-include $(OBJS:.o=.d)

.PHONY:clean
clean:
\trm -f $(TARGETS) *.o *.d *.d.* 
#{rm_list}"

# 现在进行写入，注意原文件会被覆盖哟 >_<
File.open(File.join(path, "Makefile"), 'w') {|f| f.write(input)}

# 顺便make
# 确保万一，先cd到目标文件夹
Dir.chdir path
begin
  system("make")
  status = $?.success?
rescue SystemCallError => e
  puts e.message
end

# 顺便执行文件（现在暂不开启）
# 如果执行失败，返回false， 否则返回true
def run_target target
  # 先检查是否有多个target，如果是，不要运行
  if target.split(' ').length > 1
    puts "不能执行多个target， 执行顺序无法预定"
    # 不需要debug
    return true
  end

  begin
    system("./#{target}")
    $?.success?
  rescue SystemCallError => e
    puts e.message
    return true
  end
end

def debug target
  begin
    system("gdb #{target}")
  rescue SystemCallError => e
    puts e.message
  end
end

#if status && !run_target(schema["TARGETS"])
  #debug schema["TARGETS"]
#end

