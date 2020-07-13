shaderc = shaderc
output = shader


vertex_flag = --type vertex --platform windows -p 120 -O 3
fragment_flag = --type fragment --platform windows -p 120 -O 3
def_flag = --varyingdef source-shader/define.def

d_glob := $(wildcard source/*.d)


.PHONY : all
all : shaders $(d_glob)
	dub build --compiler=dmd -a=x86_64 -b=debug -c=application



.PHONY : shaders
shaders: $(output)/basic_vs.bin $(output)/basic_fs.bin


$(output)/basic_vs.bin : source-shader/basic.vert
	echo $(d_glob)
	$(shaderc) $(vertex_flag) $(def_flag) -o $@ -f source-shader/basic.vert

$(output)/basic_fs.bin : source-shader/basic.frag
	$(shaderc) $(fragment_flag) $(def_flag) -o $@ -f source-shader/basic.frag


clean : 
	rm $(output)/*.bin