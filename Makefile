shaderc = shaderc
os := $(shell uname)
os_flag := Unsupported
output = shader/$(os)


vertex_flag = --type vertex -p 120 -O 3
fragment_flag = --type fragment -p 120 -O 3
def_flag = --varyingdef source-shader/define.def

d_glob := $(wildcard source/*.d)


.PHONY : all
all : platform $(output) shaders $(d_glob)
	dub build --compiler=dmd -a=x86_64 -b=debug -c=application

.PHONY : platform 
platform: 
ifeq ($(os),Linux)
os_flag := --platform linux 	
else ifeq($(os),Windows)
os_flag := --platform windows
else 
	$(error Your OS is not supported)
endif 


$(output) : 
	mkdir $(output)

.PHONY : shaders
shaders: $(output)/basic_vs.bin $(output)/basic_fs.bin


$(output)/basic_vs.bin : source-shader/basic.vert
	$(shaderc) $(vertex_flag) $(def_flag) $(os_flag) -o $@ -f source-shader/basic.vert

$(output)/basic_fs.bin : source-shader/basic.frag
	$(shaderc) $(fragment_flag) $(def_flag) $(os_flag) -o $@ -f source-shader/basic.frag


clean : 
	rm $(output)/*.bin
