shaderc = shaderc
os_flag := Unset 

output := shader/%


vertex_flag = --type vertex -p 120 -O 3
fragment_flag = --type fragment -p 120 -O 3
def_flag = --varyingdef source-shader/define.def

d_glob := $(wildcard source/*.d)


.PHONY : all
all : platform output shaders $(d_glob)
	dub build --compiler=dmd -a=x86_64 -b=debug -c=application

.PHONY : platform 
platform: 
ifeq ($(OS),Windows_NT)
os_flag := --platform windows
output = shader/Windows
else 
unix_os := $(shell uname)
ifeq($(unix_os),Linux)
os_flag := --platform linux
output = shader/Linux
endif 
	



.PHONY : output
output :
	[ -d $(output) ] || mkdir $(output)

.PHONY : shaders
shaders: $(output)/basic_vs.bin $(output)/basic_fs.bin


$(output)/basic_vs.bin : source-shader/basic.vert
	$(shaderc) $(vertex_flag) $(def_flag) $(os_flag) -o $@ -f source-shader/basic.vert

$(output)/basic_fs.bin : source-shader/basic.frag
	$(shaderc) $(fragment_flag) $(def_flag) $(os_flag) -o $@ -f source-shader/basic.frag


clean : 
	rm $(output)/*.bin
