function fourpoint_init() {
	vertex_format_begin();
	vertex_format_add_color();
	vertex_format_add_position_3d();
	vertex_format_add_texcoord();
	global.fourpoint_vf = vertex_format_end();
}

function fourpoint(x1, y1, x2, y2, x3, y3, x4, y4, tex, segments = 5, perspective = true, z = 0) constructor {
	
	self.vb = vertex_create_buffer();
	self.freeze_timer = -1;
	
	self.x1 = x1;
	self.y1 = y1;
	self.x2 = x2;
	self.y2 = y2;
	self.x3 = x3;
	self.y3 = y3;
	self.x4 = x4;
	self.y4 = y4;
	self.tex = tex;
	self.segments = segments;
	self.perspective = perspective;
	self.z = z;
	
	update();
	
	static update = function(x1 = self.x1, y1 = self.y1, x2 = self.x2, y2 = self.y2, x3 = self.x3, y3 = self.y3, x4 = self.x4, y4 = self.y4, 
						     tex = self.tex, segments = self.segments, perspective = self.perspective, z = self.z) {
		
		self.x1 = x1;
		self.y1 = y1;
		self.x2 = x2;
		self.y2 = y2;
		self.x3 = x3;
		self.y3 = y3;
		self.x4 = x4;
		self.y4 = y4;
		self.tex = tex;
		self.segments = segments;
		self.perspective = perspective;
		self.z = z;
		
		if self.freeze_timer == -1 {
			vertex_delete_buffer(vb);
			vb = vertex_create_buffer();
		}
		self.freeze_timer = 1;
		
		var g = ds_grid_create(segments+1, segments+1);
		
		if perspective {
			
			var line_line_intersection_point = function(x1, y1, x2, y2, x3, y3, x4, y4) {
			
				var a1 = y2 - y1;
				var b1 = x1 - x2;
				var c1 = a1 * x1 + b1 * y1;
			
				var a2 = y4 - y3;
				var b2 = x3 - x4;
				var c2 = a2 * x3 + b2 * y3;
			
				var delta = a1 * b2 - a2 * b1;
				return [(b2 * c1 - b1 * c2) / delta, (a1 * c2 - a2 * c1) / delta];
			}
		
			var mid = line_line_intersection_point(x1, y1, x4, y4, x2, y2, x3, y3);
			if is_array(mid) {
				var nearest = 0;
				var ndis = infinity;
				var dis = 0;
				for(var i = 0; i < 4; i++) {
					switch(i) {
						case 0:
							dis = point_distance(mid[0], mid[1], x1, y1);
							if dis < ndis {
								ndis = dis;
								nearest = i;
							}
							break;
						case 1:
							dis = point_distance(mid[0], mid[1], x2, y2);
							if dis < ndis {
								ndis = dis;
								nearest = i;
							}
							break;
						case 2:
							dis = point_distance(mid[0], mid[1], x3, y3);
							if dis < ndis {
								ndis = dis;
								nearest = i;
							}
							break;
						case 3:
							dis = point_distance(mid[0], mid[1], x4, y4);
							if dis < ndis {
								ndis = dis;
								nearest = i;
							}
							break;
					}
				}
				
				var t = point_distance(x1, y1, x2, y2);
				var b = point_distance(x3, y3, x4, y4);
				var r = point_distance(x2, y2, x4, y4);
				var l = point_distance(x1, y1, x3, y3);
				
				var dx = sqrt(sqrt(min(t,b) / max(t,b)));
				var dy = sqrt(sqrt(min(l,r) / max(l,r)));
				var tp = [], bt = [];
			
				// 0 1
				// 2 3
				//
				// 0: <, <, tp 010, bt 232
				// 1: <, >, tp 101, bt 323
				// 2: >, <, bt 010, tp 232
				// 3: >, >, bt 101, tp 323
			
				switch(nearest) {
		
					case 0: // 0: <, <, tp 010, bt 232
						if t < b dx = 1+(1-dx);
						if l < r dy = 1+(1-dy);
					
						for(var gx = 0; gx < segments+1; gx++) {
							var f = power(gx / segments, dy);
							tp = [ x1 + (x2 - x1) * f, y1 + (y2 - y1) * f ];
							bt = [ x3 + (x4 - x3) * f, y3 + (y4 - y3) * f ];
			
							for(var gy = 0; gy < segments+1; gy++) {
								var f = power(gy / segments, dx);
								g[# gx,gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
							}
						}
						break;
				
					case 1: // 1: <, >, tp 101, bt 323
						if t < b dx = 1+(1-dx);
						if l > r dy = 1+(1-dy);
			
						for(var gx = 0; gx < segments+1; gx++) {
							var f = power(gx / segments, dy);
							tp = [ x2 + (x1 - x2) * f, y2 + (y1 - y2) * f ];
							bt = [ x4 + (x3 - x4) * f, y4 + (y3 - y4) * f ];
			
							for(var gy = 0; gy < segments+1; gy++) {
								var f = power(gy / segments, dx);
								g[# segments-gx,gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
							}
						}
						break;
				
					case 2: // 2: >, <, bt 010, tp 232
						if t > b dx = 1+(1-dx);
						if l < r dy = 1+(1-dy);
					
						for(var gx = 0; gx < segments+1; gx++) {
							var f = power(gx / segments, dy);
							bt = [ x1 + (x2 - x1) * f, y1 + (y2 - y1) * f ];
							tp = [ x3 + (x4 - x3) * f, y3 + (y4 - y3) * f ];
			
							for(var gy = 0; gy < segments+1; gy++) {
								var f = power(gy / segments, dx);
								g[# gx,segments-gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
							}
						}
						break;
				
					case 3: // 3: >, >, bt 101, tp 323
						if t > b dx = 1+(1-dx);
						if l > r dy = 1+(1-dy);
		
						for(var gx = 0; gx < segments+1; gx++) {
							var f = power(gx / segments, dy);
							bt = [ x2 + (x1 - x2) * f, y2 + (y1 - y2) * f ];
							tp = [ x4 + (x3 - x4) * f, y4 + (y3 - y4) * f ];
	
							for(var gy = 0; gy < segments+1; gy++) {
								var f = power(gy / segments, dx);
								g[# segments-gx,segments-gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
							}
						}
						break;
				}
			}
		}
		else {
			for(var gx = 0; gx < segments+1; gx++) {
				var f = gx / segments;
				tp = [ x1 + (x2 - x1) * f, y1 + (y2 - y1) * f ];
				bt = [ x3 + (x4 - x3) * f, y3 + (y4 - y3) * f ];
			
				for(var gy = 0; gy < segments+1; gy++) {
					var f = gy / segments;
					g[# gx,gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
				}
			}
		}
		
		vertex_begin(vb, global.fourpoint_vf);

		var uvstep = 1/segments;
	
		for(var gx = 0; gx < segments; gx++) {
			for(var gy = 0; gy < segments; gy++) {
		
				var u = gx/segments;
				var v = gy/segments;
		
				var pos = g[# gx,gy];
			
				vertex_color(vb, c_white, 1);
				vertex_position_3d(vb, pos[0], pos[1], z);
				vertex_texcoord(vb, u, v);
		
				v += uvstep;
				pos = g[# gx,++gy];
			
				vertex_color(vb, c_white, 1);
				vertex_position_3d(vb, pos[0], pos[1], z);
				vertex_texcoord(vb, u, v);
		
				u += uvstep;
				pos = g[# ++gx,gy];
		
				vertex_color(vb, c_white, 1);
				vertex_position_3d(vb, pos[0], pos[1], z);
				vertex_texcoord(vb, u, v);
		
				vertex_color(vb, c_white, 1);
				vertex_position_3d(vb, pos[0], pos[1], z);
				vertex_texcoord(vb, u, v);
		
				v -= uvstep;
				pos = g[# gx,--gy];
		
				vertex_color(vb, c_white, 1);
				vertex_position_3d(vb, pos[0], pos[1], z);
				vertex_texcoord(vb, u, v);
		
				u -= uvstep;
				pos = g[# --gx,gy];
		
				vertex_color(vb, c_white, 1);
				vertex_position_3d(vb, pos[0], pos[1], z);
				vertex_texcoord(vb, u, v);
			}
		}
		
		vertex_end(vb);
		ds_grid_destroy(g);
	}
	
	static draw = function() {
		if self.freeze_timer != -1 and self.freeze_timer-- == 0 vertex_freeze(vb);
		vertex_submit(vb, pr_trianglelist, tex);
	}
	
	static draw_transformed = function(xrot = 0, yrot = 0, zrot = 0, xscale = 1, yscale = 1, zscale = 1) {
		matrix_set(matrix_world, matrix_build(0, 0, 0, xrot, yrot, zrot, xscale, yscale, zscale));
		draw();
		matrix_set(matrix_world, matrix_build_identity());
	}
	
	static destroy = function() {
		vertex_delete_buffer(vb);
	}
}
