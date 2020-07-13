$input a_position, a_color0
$output v_color0

/*
 * Copyright 2011-2020 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */

#include "include/common.sh"

void main()
{
	
	
	gl_Position = vec4(a_position.xyz, 1.0);
	v_color0 = a_color0;
}
  