pot_border_thickness=6; //7.2 and 6
pot_diameter=105;

gripper_translation=pot_border_thickness/3;

height=20;
fill_width=14;
wall_thickness = 1;
skewedness = 6;

water_can_size = 12.5;

back_wall_height = height/2;

beak_scale_factor = 1.5;

width_scale_factor = 2;

module beak(t_offset=0) {
	translate([-skewedness,0,0])
		rotate(270, [0,0,1])
			linear_extrude(height = height+back_wall_height, convexity = 10, scale=[1,beak_scale_factor])
				translate([0, skewedness+t_offset, 0])
					circle(r = fill_width/2, $fn=100);
}

module slope() {
	difference() {
		beak();
		// cut the slope on top
		translate([-fill_width,-fill_width,height/2])
			cube([fill_width*2*beak_scale_factor, fill_width*2, height]);
	}
	intersection() {
		translate([-gripper_translation,-fill_width/2,height/2-wall_thickness*2])
			rotate(-11, [0,1,0])
				cube([fill_width*1.5,fill_width,pot_border_thickness/2+wall_thickness]);
		beak();
	}
}

module refiller_shape() {
	difference() {
		beak();
		scale([0.9,0.9,1])
			beak(0.25);
	}
	difference() {
		slope();
		// cut the water funnel from the slope - adapt the cut to pot size
		translate([-pot_diameter/2+gripper_translation+pot_border_thickness/2,0,-1])
			cylinder(d=pot_diameter-pot_border_thickness*2-wall_thickness*2, h=height, $fn=200);
	}
}

module refiller() {
	difference() {
		refiller_shape();
		// cut upper part diagonally so water does not spill over the rim
		// (also cuts nose)
		translate([-(fill_width*beak_scale_factor)*0.75,-fill_width*0.75,height+height/3*1.34])
			rotate(16, [0,1,0])
				cube([2*fill_width*beak_scale_factor,2*fill_width,height]);
		}
}

module pot() {
	translate([-pot_diameter/2+gripper_translation+pot_border_thickness/2,0,-1])
		union() {
		difference() {
			cylinder(d=pot_diameter, h=height/2, $fn=100);
			translate([0,0,-1])
				cylinder(d=pot_diameter-pot_border_thickness*2, h=height/2+2, $fn=200);
		}
		translate([0,0,height/2])
			rotate_extrude($fn = 100)
				translate([pot_diameter/2-pot_border_thickness/2, 0, 0])
					circle(r = pot_border_thickness/2, $fn = 100);
	}
}

module wall_hole() {
	for(i=[0:0.5:height/6])
		translate([0,0,i])
			translate([-pot_border_thickness/2+wall_thickness/2,0,0])
			rotate(90, [0,1,0])
				cylinder(d=fill_width-2*wall_thickness-gripper_translation*0.7, h=gripper_translation*1.5, $fn=100);
}

scale([1,width_scale_factor,1])
	difference() {
		refiller();
		pot();
		// cut out inner backside for better flow
		wall_hole();
	}


