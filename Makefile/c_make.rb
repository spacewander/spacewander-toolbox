#!/usr/bin/env ruby
# encoding: UTF-8

script = $0
filename = ARGV.first
if filename == nil
  puts "Usage: #{script} schema \n 输入schema文件来生成对应的Makefile" 
  exit(1)
end

# 读取schema
begin
  schema = {}
  IO.foreach(filename) do |line|
    option = line.split("=", 2)
    option.each {|i| i.strip! }
    option[0].upcase! # 变量名转换成大写
    schema[option[0]] = option[1]
  end
rescue Errno::ENOENT
  puts "#{filename} not found!"
end

# 检查是否有必须的项，并构造Makefile字符串
input = ""
if schema.has_key?("PATH") && schema["PATH"] != ""
  path = schema["PATH"]
else
  puts "需要有生成Makefile所在的路径变量PATH"
  exit(1)
end

if schema.has_key?("CC") && schema["CC"] != ""
  input += "CC\t= #{schema["CC"]}\n"
else
  puts "需要有Makefile所需的编译C文件的编译器名字变量CC"
  exit(1)
end

if schema.has_key?("CFLAGS")
  input += "CFLAGS = #{schema["CFLAGS"]}\n"
else
  puts "需要有Makefile所需的编译C文件的编译参数变量CFLAGS"
  exit(1)
end

input += "CDEBUG = -g \n"
input += "CRELEASE = -O2 \n"

if schema.has_key?("INCLUDEFLAGS")
  input += "INCLUDEFLAGS = #{schema["INCLUDEFLAGS"]}\n"
else
  puts "需要有Makefile所需的编译C文件的包含参数变量INCLUDEFLAGS"
  exit(1)
end

if schema.has_key?("LDFLAGS")
  input += "LDFLAGS = #{schema["LDFLAGS"]}\n"
else
  puts "需要有Makefile所需链接参数变量LDFLAGS"
  exit(1)
end

# 遍历项目文件夹，并生成对应的.o文件队列
begin
  Dir.chdir(path)
rescue Errno::ENOENT => e
  puts e.message
  exit(1)
end

c_files = ""
c_dirs = []

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

c_files = traverse_dir_for_file '.', 'c', ''
c_dirs = traverse_dir_for_dir '.', ''

# 遍历结束
input += "OBJS\t= #{c_files}\n"

if schema.has_key?("TARGETS") && schema["TARGETS"] != ""
  input += "TARGETS = #{schema["TARGETS"]}\n"
else
  puts "需要有Makefile所需TARGETS"
  exit(1)
end

# 生成需要清除的依赖文件和链接文件的字符串
rm_list = ""
c_dirs.each do |dir|
  rm_list += "\trm -f #{dir}/*.o #{dir}/*.d #{dir}/*.d.* \n"
end

# Makefile 需要 tab 而不是 空格
input += "
.PHONY:all
all : CFLAGS += $(CDEBUG)
all : $(TARGETS)

.PHONY:release
release : CFLAGS += $(CRELEASE)
release : $(TARGETS)

$(TARGETS) : $(OBJS)
\t$(CC) -o $@ $^  $(LDFLAGS)

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
# 如果执行失败，返回shell错误标记
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

