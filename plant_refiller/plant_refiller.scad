pot_border_thickness=6; //7.2 and 6
pot_diameter=105;

gripper_translation=pot_border_thickness/3;

height=20;
fill_width=15;
wall_thickness = 1;

beak_scale_factor = 1.5;

width_scale_factor = 2;

module pot() {
	translate([-pot_diameter/2+gripper_translation+pot_border_thickness/2,0,-1])
		union() {
		difference() {
			cylinder(d=pot_diameter, h=height/2, $fn=200);
			translate([0,0,-1])
				cylinder(d=pot_diameter-pot_border_thickness*2, h=height/2+2, $fn=200);
		}
		translate([0,0,height/2])
			rotate_extrude($fn = 200)
				translate([pot_diameter/2-pot_border_thickness/2, 0, 0])
					circle(r = pot_border_thickness/2, $fn = 200);
	}
}

module outer_beak_shape() {
	skewedness = 6;
	translate([-skewedness,0,0])
		rotate(270, [0,0,1])
			linear_extrude(height = height, convexity = 10, scale=[1,beak_scale_factor])
				translate([0, skewedness, 0])
					circle(r = fill_width/2, $fn=400);
}

module inner_slope() {
	difference() {
		intersection() {
			translate([-gripper_translation,-fill_width/2,height/2-wall_thickness])
				rotate(-11, [0,1,0])
					cube([fill_width,fill_width,pot_border_thickness/2]);
			outer_beak_shape();
		}
		difference() {
				cylinder(h=height/2+pot_border_thickness/2, d=fill_width-wall_thickness*2, $fn=100);
			translate([-gripper_translation,-(fill_width+2)/2,0])
				cube([pot_border_thickness*2+wall_thickness, fill_width+2, height/2+pot_border_thickness/2]);
		}
	}
}

module outer_beak_shape_with_inner_slope() {
	outer_beak_shape();
	inner_slope();
}

module inner_beak() {
	skewedness = 6;
	translate([-skewedness,0,height/2+pot_border_thickness/2])
		rotate(270, [0,0,1])
	linear_extrude(height = height/2-pot_border_thickness/2+0.1, convexity = 10, scale=[1,beak_scale_factor])
	translate([0, skewedness, 0])
		circle(r = fill_width/2-wall_thickness, $fn=200);
}

module carve_out() {
	// cylinder
	difference() {
		difference() {
			difference() {
				translate([0,0,-1])
					cylinder(h=height/2+pot_border_thickness/2+1, d=fill_width-wall_thickness*2, $fn=100);
				translate([-wall_thickness,0,0])
					pot();
			}
			translate([0,-(fill_width+2)/2,-1])
				cube([pot_border_thickness*2+wall_thickness, fill_width+2, height/2+pot_border_thickness/2]);
		}
		inner_slope();
	}
	// beak
	difference() {
		inner_beak();
		inner_slope();
	}
}

// higher back wall that keeps water from spilling over the rim

module upper_wall(wall=0, extra_height=0) { // extra height only for visual purposes
	translate([(fill_width*beak_scale_factor-fill_width)/2-3*wall_thickness/4,0,height-extra_height])
	linear_extrude(height = height/3+2*extra_height, convexity = 10, scale=[1,1])
		scale([beak_scale_factor,1,1])
			circle(r = fill_width/2-wall/2, $fn=200);
}

module back_wall() {
	difference() {
		difference() {
			upper_wall();
			upper_wall(wall_thickness*2, 1);
		}
		// cut it diagonally
		translate([-(fill_width*beak_scale_factor)*0.75,-fill_width*0.75,height+height/3*1.34])
			rotate(16, [0,1,0])
				cube([2*fill_width*beak_scale_factor,2*fill_width,height/2]);
	}
}

// put the whole thing together

module refiller() {
	difference() {
		outer_beak_shape_with_inner_slope();//refiller_shape();
		carve_out();
	}
	back_wall();
}

module refiller_with_hole() {
	difference() {
		refiller();
		pot();
	}
}

scale([1,width_scale_factor,1])
	difference() {
		refiller_with_hole();
		// cut out inner backside for better flow
		for(i=[0:0.5:height/6])
			translate([0,0,i])
				translate([-pot_border_thickness/2,0,0])
				rotate(90, [0,1,0])
					cylinder(d=fill_width-2*wall_thickness-gripper_translation*0.7, h=gripper_translation*1.5, $fn=200);
	}