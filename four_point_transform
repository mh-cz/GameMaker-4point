function four_point_transform(x1, y1, x2, y2, x3, y3, x4, y4, tex, segments = 5, perspective = true, z = depth) {
	
	var p = [[x1,y1], [x2,y2], [x3,y3], [x4, y4]];
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
			for(var i = 0; i < 4; i++) {
				var dis = point_distance(mid[0], mid[1], p[i][0], p[i][1]);
				if dis < ndis {
					ndis = dis;
					nearest = i;
				}
			}
			 
			var t = point_distance(p[0][0], p[0][1], p[1][0], p[1][1]);
			var b = point_distance(p[2][0], p[2][1], p[3][0], p[3][1]);
			var r = point_distance(p[1][0], p[1][1], p[3][0], p[3][1]);
			var l = point_distance(p[0][0], p[0][1], p[2][0], p[2][1]);
			
			var dx = min(t,b) / max(t,b);
			var dy = min(l,r) / max(l,r);
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
						tp = [ p[0][0] + (p[1][0] - p[0][0]) * f, p[0][1] + (p[1][1] - p[0][1]) * f ];
						bt = [ p[2][0] + (p[3][0] - p[2][0]) * f, p[2][1] + (p[3][1] - p[2][1]) * f ];
			
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
						tp = [ p[1][0] + (p[0][0] - p[1][0]) * f, p[1][1] + (p[0][1] - p[1][1]) * f ];
						bt = [ p[3][0] + (p[2][0] - p[3][0]) * f, p[3][1] + (p[2][1] - p[3][1]) * f ];
			
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
						bt = [ p[0][0] + (p[1][0] - p[0][0]) * f, p[0][1] + (p[1][1] - p[0][1]) * f ];
						tp = [ p[2][0] + (p[3][0] - p[2][0]) * f, p[2][1] + (p[3][1] - p[2][1]) * f ];
			
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
						bt = [ p[1][0] + (p[0][0] - p[1][0]) * f, p[1][1] + (p[0][1] - p[1][1]) * f ];
						tp = [ p[3][0] + (p[2][0] - p[3][0]) * f, p[3][1] + (p[2][1] - p[3][1]) * f ];
	
						for(var gy = 0; gy < segments+1; gy++) {
							var f = power(gy / segments, dx);
							g[# segments-gx,segments-gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
						}
					}
					break;
			}
		}
		else {
			ds_grid_destroy(g);
			return false;
		}
	}
	else {
		for(var gx = 0; gx < segments+1; gx++) {
			var f = gx / segments;
			tp = [ p[0][0] + (p[1][0] - p[0][0]) * f, p[0][1] + (p[1][1] - p[0][1]) * f ];
			bt = [ p[2][0] + (p[3][0] - p[2][0]) * f, p[2][1] + (p[3][1] - p[2][1]) * f ];
			
			for(var gy = 0; gy < segments+1; gy++) {
				var f = gy / segments;
				g[# gx,gy] = [ tp[0] + (bt[0] - tp[0]) * f, tp[1] + (bt[1] - tp[1]) * f ];
			}
		}
	}
	
	vertex_format_begin();
	vertex_format_add_color();
	vertex_format_add_position_3d();
	vertex_format_add_texcoord();
	var vf = vertex_format_end();
	var vb = vertex_create_buffer()

	var uvstep = 1/segments;
	
	vertex_begin(vb, vf);
	
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
	vertex_submit(vb, pr_trianglelist, tex);
		
	vertex_format_delete(vf);
	vertex_delete_buffer(vb);
	ds_grid_destroy(g);
	
	return true;
}
