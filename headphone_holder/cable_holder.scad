// table

table_height = 25;

module Table() {
	cube([500,gripper_length,table_height], center=true);
}

// gripper to attach the cable holder to the table

gripper_width = table_height;
gripper_length = table_height*2;
gripper_thickness = 4;

module Gripper() {
	//gripper top back angle
	translate([0,-gripper_length/2,table_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	//gripper bottom back angle
	translate([0,-gripper_length/2,-table_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	//gripper top front angle
	translate([0,gripper_length/4-gripper_thickness,table_height/2-gripper_thickness/2-gripper_thickness/5]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	//gripper bottom front angle
	translate([0,gripper_length/2-gripper_thickness,-table_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	//gripper top
	translate([0,-gripper_length/8-gripper_thickness/2,table_height/2+gripper_thickness/6]) {
		rotate(-gripper_thickness-0.7,[1,0,0]) {
			cube([gripper_width, 3*gripper_length/4-gripper_thickness, gripper_thickness], center=true);
		}
	}

	//gripper left
	translate([0,-gripper_length/2-gripper_thickness/2,0]) {
		rotate(90,[1,0,0]) {
			cube([gripper_width, table_height, gripper_thickness], center=true);
		}
	}

	//gripper bottom
	translate([0,-gripper_thickness/2,-table_height/2-gripper_thickness/2]) {
			cube([gripper_width, gripper_length-gripper_thickness/2-0.2, gripper_thickness], center=true);
	}
}

difference() {
	Gripper();
	Table();
}

// cable holder
// inspired by: https://www.thingiverse.com/thing:3022893 (USB Cable Holder byjb20200606, CC-BY-NC)

cable_holder_thickness = 12;
cable_holder_height = table_height/2;
cable_holder_width = gripper_width*4.5;
hole_thickness = 8;

module cableHolderBody() {
	cube([cable_holder_width,cable_holder_thickness,cable_holder_height],center=true,$fn=100);
	// lower wing
	translate([0,0,-cable_holder_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=cable_holder_width,d=cable_holder_thickness,center=true,$fn=100);
		}
	}
	translate([0,cable_holder_thickness/4,-cable_holder_thickness/2]) {
		cube([cable_holder_width,cable_holder_thickness/2,cable_holder_height],center=true,$fn=100);
	}
	// left wing
	translate([-cable_holder_width/2,0,0]) {
		cylinder(h=cable_holder_height,d=cable_holder_thickness,center=true,$fn=100);
	}
	translate([-cable_holder_thickness/2,cable_holder_thickness/4,0]) {
		cube([cable_holder_width,cable_holder_thickness/2,cable_holder_height],center=true,$fn=100);
	}
	// right wing
	translate([cable_holder_width/2,0,0]) {
		cylinder(h=cable_holder_height,d=cable_holder_thickness,center=true,$fn=100);
	}
	translate([cable_holder_thickness/2,cable_holder_thickness/4,0]) {
		cube([cable_holder_width,cable_holder_thickness/2,cable_holder_height],center=true,$fn=100);
	}
	// rounded edges bottom
	translate([cable_holder_width/2,0,-cable_holder_height/2]) {
		sphere(cable_holder_thickness/2,$fn=100);
	}
	translate([cable_holder_width/2,cable_holder_thickness/4,-cable_holder_height/2]) {
		rotate(90,[1,0,0]) {
			cylinder(h=cable_holder_thickness/2,d=cable_holder_thickness,center=true, $fn=100);
		}
	}
	translate([-cable_holder_width/2,0,-cable_holder_height/2]) {
		sphere(cable_holder_thickness/2,$fn=100);
	}
	translate([-cable_holder_width/2,cable_holder_thickness/4,-cable_holder_height/2]) {
		rotate(90,[1,0,0]) {
			cylinder(h=cable_holder_thickness/2,d=cable_holder_thickness,center=true, $fn=100);
		}
	}
	// rounded edges top
	translate([cable_holder_width/2,0,cable_holder_height/2]) {
		sphere(cable_holder_thickness/2,$fn=100);
	}
	translate([cable_holder_width/2,cable_holder_thickness/4,cable_holder_height/2]) {
		rotate(90,[1,0,0]) {
			cylinder(h=cable_holder_thickness/2,d=cable_holder_thickness,center=true, $fn=100);
		}
	}
	translate([-cable_holder_width/2,0,cable_holder_height/2]) {
		sphere(cable_holder_thickness/2,$fn=100);
	}
	translate([-cable_holder_width/2,cable_holder_thickness/4,cable_holder_height/2]) {
		rotate(90,[1,0,0]) {
			cylinder(h=cable_holder_thickness/2,d=cable_holder_thickness,center=true, $fn=100);
		}
	}
	// upper wing
	translate([0,0,cable_holder_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=cable_holder_width,d=cable_holder_thickness,center=true,$fn=100);
		}
	}
	translate([0,cable_holder_thickness/4,cable_holder_thickness/2]) {
		cube([cable_holder_width,cable_holder_thickness/2,cable_holder_height],center=true,$fn=100);
	}
}

module cableHoles() {
	translate([0,-1,0]) {
		cylinder(h=cable_holder_height+cable_holder_thickness+5,d=hole_thickness,center=true, $fn=100);
	}
	translate([0,-cable_holder_thickness/3,0]) {
		cube([hole_thickness/2+1,hole_thickness/2,cable_holder_height+cable_holder_thickness+5],center=true,$fn=100);
	}
}

module smoothie() {
	// smoothes the upper wing
	translate([0,-cable_holder_thickness/4,cable_holder_height/2+cable_holder_thickness/12]) {
		rotate(90,[0,1,0]) {
			cylinder(h=cable_holder_width+cable_holder_thickness+5, d=cable_holder_thickness/2, center=true, $fn=200);
		}
	}
	translate([0,0,-cable_holder_height/3]) {
		cube([cable_holder_width+cable_holder_thickness+5, cable_holder_width, cable_holder_height*2], center=true);
	}
}

module cableHolder() {
	intersection(){
		difference() {
			cableHolderBody();
			translate([0,-0.5,0]) { cableHoles(); }
			distance = ((cable_holder_width-cable_holder_thickness/2)/2);
			translate([-distance/3,0,0]) { cableHoles(); }
			translate([-2*distance/3,0,0]) { cableHoles(); }
			translate([-distance,0,0]) { cableHoles(); }
			translate([distance/3,0,0]) { cableHoles(); }
			translate([2*distance/3,0,0]) { cableHoles(); }
			translate([distance,0,0]) { cableHoles(); }
			// upper cable canyon
			translate([0,cable_holder_thickness*0.2,cable_holder_height/2+cable_holder_thickness*0.35]) {
				rotate(90,[0,1,0]) {
					cylinder(h=cable_holder_width+cable_holder_thickness+5,d=cable_holder_thickness*0.9,center=true, $fn=100);
				}
			}
		}
		smoothie();
	}
}

translate([0,-gripper_length/2-cable_holder_thickness/2,0]) {
	cableHolder();
}

// lower cable holder

module lowerCableHolder() {
	translate([0,0,-table_height/2-cable_holder_thickness/2]) {
		rotate(90, [1,0,0]) {
			difference() {
				cableHolderBody();
				translate([0,1,0]) {
					mirror([0,1,0]) {
						distance = ((cable_holder_width-cable_holder_thickness/2)/2);
						translate([-distance/3,0,0]) { cableHoles(); }
						translate([-2*distance/3,0,0]) { cableHoles(); }
						translate([-distance,0,0]) { cableHoles(); }
						translate([distance/3,0,0]) { cableHoles(); }
						translate([2*distance/3,0,0]) { cableHoles(); }
						translate([distance,0,0]) { cableHoles(); }
					}
				}
			}
		}
	}
}

//lowerCableHolder();