table_height = 25;

gripper_width = table_height*1.5;
gripper_length = table_height*2;
gripper_thickness = 4;

holder_height = 30;
holder_width = gripper_length/2;
holder_thickness = 4;

handle_length = 60+holder_thickness;
handle_thickness = 4;

module Table() {
	cube([500,gripper_length,table_height], center=true);
}

module Gripper() {
	// gripper top back angle
	translate([0,-gripper_length/2,table_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	// gripper bottom back angle
	translate([0,-gripper_length/2,-table_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	// gripper top front angle
	translate([0,gripper_length/4-gripper_thickness-0.2,table_height/2-gripper_thickness/2-gripper_thickness/5+0.1]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	// gripper bottom front angle
	translate([0,gripper_length/2-gripper_thickness,-table_height/2]) {
		rotate(90,[0,1,0]) {
			cylinder(h=gripper_width,d=gripper_thickness*2,center=true,$fn=100);
		}
	}

	// gripper top
	translate([0,-gripper_length/8-gripper_thickness/2,table_height/2+gripper_thickness/6]) {
		rotate(-gripper_thickness-0.7,[1,0,0]) {
			cube([gripper_width, 3*gripper_length/4-gripper_thickness, gripper_thickness], center=true);
		}
	}

	// gripper left
	translate([0,-gripper_length/2-gripper_thickness/2,0]) {
		rotate(90,[1,0,0]) {
			cube([gripper_width, table_height, gripper_thickness], center=true);
		}
	}

	// gripper bottom
	translate([0,-gripper_thickness/2,-table_height/2-gripper_thickness/2]) {
			cube([gripper_width, gripper_length-gripper_thickness/2-0.2, gripper_thickness], center=true);
	}
}

difference() {
	Gripper();
	Table();
}


// support
module Support() {
	translate([-holder_height/4+holder_thickness/2,0,-table_height/2-holder_height/4]) {
		rotate(45,[0,1,0]) {
			cube([holder_height/2, holder_width, holder_thickness], center=true);
		}
	}
}
Support();
rotate(180,[0,0,1]) {
	Support();
}

// holder
translate([0,0,-table_height/2-gripper_thickness-holder_height/2]) {
	rotate(90,[0,0,1]) {
		rotate(90,[1,0,0]) {
			cube([holder_width, holder_height, holder_thickness], center=true);
		}
	}
}

// holder handle endpoint
module HandleEndpoint() {
	translate([-handle_length/2,0,-table_height/2-gripper_thickness-holder_height+handle_thickness/4-handle_thickness/2]) {
		rotate(90,[1,0,0]) {
			cylinder(h=holder_width,d=handle_thickness*1.5,center=true,$fn=100);
		}
	}
	translate([-handle_length/2+handle_length/8,0,-table_height/2-gripper_thickness-holder_height+handle_thickness/4-handle_thickness/2]) {
		rotate(7,[0,1,0]) {
			cube([handle_length/4-0.2, holder_width, handle_thickness],center=true,$fn=100);
		}
	}
}
HandleEndpoint();
rotate(180,[0,0,1]) {
	HandleEndpoint();
}

// holder handles
translate([0,0,-table_height/2-gripper_thickness-holder_height-handle_thickness/2]) {
	rotate(90,[0,0,1]) {
		cube([holder_width, handle_length, handle_thickness], center=true);
	}
}

// next: cable holder
// inspired by: https://www.thingiverse.com/thing:3022893 (USB Cable Holder byjb20200606, CC-BY-NC)

cable_holder_thickness = 10;
cable_holder_height = table_height/2;
cable_holder_width = gripper_width-cable_holder_thickness;
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
	cylinder(h=cable_holder_height+cable_holder_thickness+5,d=hole_thickness,center=true, $fn=100);
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
			translate([-cable_holder_width*0.3,0,0]) {
				cableHoles();
			}
			translate([cable_holder_width*0.3,0,0]) {
				cableHoles();
			}
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

translate([0,-gripper_length/2-gripper_thickness-cable_holder_thickness/2,0]) {
	cableHolder();
}