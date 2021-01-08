// adafruit
// display dimensions (excluding mounting holes): 61.5mm x 31.4mm x 6.6mm + 5x5mm holes
// led: Outer diameter: 36.8mm, Inner diameter: 23.3mm, Thickness: 3.25mm

led_outer = 36.8;
led_inner = 23.3;
led_height = 3.25;
lower_d = 50;
wall_thickness = 2;
lower_part_height = 95;
light_part_height = 20;
light_part_d = led_outer+0.2+wall_thickness;

ridge_height = 5;

hole_size = 5;
lcd_inner_height = 31.4;
lcd_outer_height = lcd_inner_height+hole_size*2;
lcd_width = 61.5;
lcd_thickness = 6.6;

display_width = 60;
display_height = 30;
display_vertical_shift = 3;

house_width = lcd_width+10+wall_thickness*2;
house_height = lcd_outer_height+ridge_height+1+ridge_height;

house_roof_height = 12;

floor_thickness = 1;

module lighthouseLight(wall=0) {
	translate([0,0,lower_part_height+light_part_height/2]) {
		cylinder(d=light_part_d-wall_thickness/2-0.2-wall, h=light_part_height+ridge_height, $fn=600, center=true);
	}
}

module lighthouseLower(wall=0) {
	translate([0,0,lower_part_height/2]) {
		cylinder(r1=lower_d/2-wall, r2=light_part_d/2-wall, h=lower_part_height, $fn=600, center=true);
	}
}

module lighthouseRoof() {
	difference() {
		translate([0,0,lower_part_height+light_part_height]) {
			sphere(r=(light_part_d+wall_thickness)/2, $fn=200);
		}
		translate([0,0,lower_part_height+light_part_height-(light_part_d+wall_thickness)/2]) {
			cube([led_outer*2, led_outer*2, (light_part_d+wall_thickness)], center=true);
		}
	}
}


module house(wall=0) {
	difference() {
		// house
		translate([0, lower_d/2, house_height/2]) {
			rotate(90, [1,0,0]) {
				cube([house_width-wall*2, house_height, lower_d-wall*2], center=true);
			}
		}
		// window
		translate([0, lower_d, house_height/2-display_vertical_shift]) {
			rotate(90, [1,0,0]) {
				cube([display_width, display_height, wall_thickness*4], center=true);
			}
		}
	}
}

module roof() {
	translate([0, lower_d/2, house_height+house_roof_height/2]) {
		for (x = [-8-wall_thickness*2 : 0.1 : 8+wall_thickness*2]) {
			translate([x, 0, 0]) {
				rotate(45, [0,0,1]) {
					cylinder(r1=lcd_width/2+8, r2=0, h=house_roof_height, $fn=4, center=true);
				}
			}
		}
	}
}


module lighthouseLightCabin(thickness=0.2) {
	difference() {
		lighthouseLight();
		lighthouseLight(thickness);
	}
}

module lighthouseHouse(wall=0) {
	difference() {
		lighthouseLower(wall);
		lighthouseLightCabin(0.4);
	}
	house(wall);
}

support_depth = lcd_thickness+0.4;
hook_width_height = 5;
hook_hole_depth = 2;
hook_height = (house_height-lcd_outer_height-hook_width_height-0.2)/2;

// for size comparison
module display_controller() {
	cube([lcd_width,lcd_thickness,lcd_inner_height],center=true);
	translate([lcd_width/2-hook_width_height/2, lcd_thickness/2-hook_hole_depth/2, lcd_inner_height/2+hook_width_height/2]) {
		cube([hook_width_height,hook_hole_depth,hook_width_height],center=true);
	}
	translate([lcd_width/2-hook_width_height/2, lcd_thickness/2-hook_hole_depth/2, -lcd_inner_height/2-hook_width_height/2]) {
		cube([hook_width_height,hook_hole_depth,hook_width_height],center=true);
	}
	translate([-lcd_width/2+hook_width_height/2, lcd_thickness/2-hook_hole_depth/2, lcd_inner_height/2+hook_width_height/2]) {
		cube([hook_width_height,hook_hole_depth,hook_width_height],center=true);
	}
	translate([-lcd_width/2+hook_width_height/2, lcd_thickness/2-hook_hole_depth/2, -lcd_inner_height/2-hook_width_height/2]) {
		cube([hook_width_height,hook_hole_depth,hook_width_height],center=true);
	}
}

module display_hooks() {
	// upper left hook rest
	translate([lcd_width/2-hook_width_height/2,0,lcd_outer_height/2+hook_height/2]) {
		cube([hook_width_height,support_depth,hook_height], center=true);
	}
	// lower left hook rest
	translate([lcd_width/2-hook_width_height/2,0,-lcd_outer_height/2-hook_height/2]) {
		cube([hook_width_height,support_depth,hook_height], center=true);
	}
	// upper right hook rest
	translate([-lcd_width/2+hook_width_height/2,0,lcd_outer_height/2+hook_height/2]) {
		cube([hook_width_height,support_depth,hook_height], center=true);
	}
	// lower right hook rest
	translate([-lcd_width/2+hook_width_height/2,0,-lcd_outer_height/2-hook_height/2]) {
		cube([hook_width_height,support_depth,hook_height], center=true);
	}

	// upper left hook
	translate([lcd_width/2-hook_width_height/2, -support_depth/2+(support_depth-hook_hole_depth)/2, lcd_inner_height/2+(hook_width_height+hook_height)/2]) {
		cube([hook_width_height,support_depth-hook_hole_depth,hook_width_height+hook_height], center=true);
	}
	// lower left hook
	translate([lcd_width/2-hook_width_height/2, -support_depth/2+(support_depth-hook_hole_depth)/2, -lcd_inner_height/2-(hook_width_height+hook_height)/2]) {
		cube([hook_width_height,support_depth-hook_hole_depth,hook_width_height+hook_height], center=true);
	}
	// upper right hook
	translate([-lcd_width/2+hook_width_height/2, -support_depth/2+(support_depth-hook_hole_depth)/2, lcd_inner_height/2+(hook_width_height+hook_height)/2]) {
		cube([hook_width_height,support_depth-hook_hole_depth,hook_width_height+hook_height], center=true);
	}
	// lower right hook
	translate([-lcd_width/2+hook_width_height/2, -support_depth/2+(support_depth-hook_hole_depth)/2, -lcd_inner_height/2-(hook_width_height+hook_height)/2]) {
		cube([hook_width_height,support_depth-hook_hole_depth,hook_width_height+hook_height], center=true);
	}

	// left pillar
	translate([lcd_width/2,-support_depth/2,-(house_height-0.2-ridge_height)/2]) {
		cube([(house_width-lcd_width)/2,support_depth,house_height-0.2-ridge_height]);
	}

	//lower ledge
	translate([0,0,-lcd_outer_height/2-hook_height/2]) {
		cube([house_width,support_depth,hook_height], center=true);
	}
}

module led_rest() {
	led_holder_height = 15;
	// add holes
	difference() {
		// cast led rest
		difference() {
			// cut lower part to remove the rest of the lighthouse cast
			difference() {
				// cut upper part where led rests
				difference() {
					lighthouseLower();
					translate([0,0,lower_part_height-led_height/2]) {
						cube([lower_d, lower_d, led_height], center=true);
					}
				}
				translate([0,0,(lower_part_height-led_holder_height-led_height)/2]) {
					cube([lower_d, lower_d, lower_part_height-led_holder_height-led_height], center=true);
				}
			}
			// led rest (inverted form)
			translate([0,0,lower_part_height-led_holder_height/2-led_height]) {
				cylinder(r1=light_part_d/2+(light_part_d/2-lower_d/2)/led_holder_height, r2=led_inner/2, h=led_holder_height, $fn=600, center=true);
			}
		}
		// cable holes
		hole_size = 0.4;
		translate([0,0,lower_part_height-led_holder_height/2-led_height]) {
			rotate(20, [0,0,1]) {
				cube([led_inner*hole_size, led_inner*2, led_holder_height+5], center=true);
			}
			cube([led_inner*hole_size, led_inner*2, led_holder_height+5], center=true);
			rotate(-20, [0,0,1]) {
				cube([led_inner*hole_size, led_inner*2, led_holder_height+5], center=true);
			}
		}
	}
}

door_thickness = wall_thickness*5;
door_width = lower_d*0.4;
door_height = house_height/2;

module pointed_door(frame, thickness, width, height, angle, offset_h, offset_wh) {
	rotate(angle, [0,0,1]) {
		translate([0,-lower_d/2+thickness/2,height/2+offset_h]) {
			translate([width/2,0,offset_wh-frame/1.5+width/2]) {
				rotate(90,[1,0,0]) {
					cylinder(d=width, h=thickness, $fn=200, center=true);
				}
			}
			translate([-width/2,0,offset_wh-frame/1.5+width/2]) {
				rotate(90,[1,0,0]) {
					cylinder(d=width, h=thickness, $fn=200, center=true);
				}
			}
		}
	}
}

module opening(frame, thickness, width, height, angle, offset_h, offset_wh) {
	rotate(angle, [0,0,1]) {
		translate([0,-lower_d/2+thickness/2,height/2+offset_h]) {
			// door/window
			cube([width-frame, thickness, height], center=true);
			// arch
			translate([0,0,height/2]) {
				rotate(90,[1,0,0]) {
					cylinder(d=width-frame, h=thickness, $fn=200, center=true);
				}
			}
			// pointed arch
			translate([0,0,offset_wh-frame/1.5]) {
				rotate(45,[0,1,0]) {
					cube([width/2, thickness, width/2],center=true);
				}
			}
			// remove upper point
			/*translate([0,0,offset_wh+width/4]) {
				cube([width/2, thickness, width/2],center=true);
			}*/
		}
	}
}

module door(frame=0, thickness=door_thickness, width=door_width, height=door_height, angle=0, offset_h=0, offset_wh=door_width) {
	/*difference() {
		opening(frame, thickness, width, height, angle, offset_h, offset_wh);
		intersection() {
			pointed_door(frame, thickness, width, height, angle, offset_h, offset_wh);
			opening(frame, thickness, width, height, angle, offset_h, offset_wh);
		}
	}*/
	opening(frame, thickness, width, height, angle, offset_h, offset_wh);
}



window_thickness = wall_thickness*6;
window_width = lower_d*0.3;
window_height = house_height*0.2;

module house_windows(side=1) {
	house_window_height = window_height*1.8;
	translate([house_width/2*side,lower_d/3,window_height*1.5+(house_window_height-window_height)/2]) {
		cube([window_thickness, window_width, house_window_height], center=true);
		/*translate([0,0,house_window_height/2]) {
			rotate(90, [0,1,0]) {
				cylinder(d=window_width, h=window_thickness, $fn=100, center=true);
			}
		}*/
	}
}

module windows() {
	door(0, window_thickness, window_width, window_height, 55, window_height, window_height);
	door(0, window_thickness, window_width, window_height, -55, window_height, window_height);
	door(0, window_thickness, window_width, window_height, 0, lower_part_height*0.6, window_height);
	house_windows();
	house_windows(-1);
}

module usbSlot() {
	height = 12;
	width = 7;
	translate([-house_width/2, lower_d-12-width/2-wall_thickness/2, house_height/2-display_vertical_shift]) {
		cube([wall_thickness*2, width+wall_thickness, height+0.4], center=true);
	}
	// for position comparison
	//translate([-house_width/2, lower_d-12/2, 17/2]) #cube([1,12,17], center=true);
}

module buildingComplex() {
	difference() {
		lighthouseHouse();
		lighthouseHouse(wall_thickness);
	}
	translate([0, lower_d-support_depth/2-wall_thickness, house_height/2+0.4-display_vertical_shift]) {
	//translate([0,0,-40]) {
		display_hooks();
		//#display_controller();
	}
	//ledge below house
	translate([0, lower_d-support_depth-wall_thickness-(20-support_depth)/2, (hook_width_height+hook_height)/2]) {
		cube([house_width,20-support_depth,hook_width_height+hook_height], center=true);
	}
	led_rest();
}

module building() {
	// add USB slot
	difference() {
		// add windows
		difference() {
			// add door
			difference() {
				buildingComplex();
				door();
			}
			windows();
		}
		usbSlot();
	}

	// cut away inner arch
	difference() {
		// cut out door
		difference() {
			door();
			door(2);
		}
		lighthouseHouse(wall_thickness);
	}

	// add floor
	// house floor
	translate([0,lower_d/2,floor_thickness/2]) {
		cube([house_width, lower_d, floor_thickness], center=true);
	}
	// lighthouse floor
	cylinder(d=lower_d-wall_thickness/2, h=floor_thickness, $fn=600);
	// doorway floor
	translate([0, -lower_d/2+door_thickness/2, floor_thickness/2]) {
		cube([door_width, door_thickness, floor_thickness], center=true);
	}
}

module rightWallCast() {
	translate([-(house_width-wall_thickness)/2, (lower_d)/2, house_height/2+floor_thickness/2]) {
		cube([wall_thickness, lower_d-2*wall_thickness, house_height-floor_thickness], center=true);
	}
}

module rightWall(hook_h=0.2, hook_v=0) { // set hook_v to 0.1, hook_h to 0 for diff
	// copy right wall
	intersection() {
		rightWallCast();
		building();
	}
	// bottom ledge
	translate([-(house_width-wall_thickness)/2, (lower_d)/2, floor_thickness/4+floor_thickness/2-hook_v/2]) {
		cube([wall_thickness/2-hook_h, lower_d-2*wall_thickness, floor_thickness/2+hook_v],center=true);
	}
	// left ear
	ear_height = 4;
	translate([-(house_width-wall_thickness)/2, lower_d-wall_thickness+wall_thickness/4, house_height-ear_height/2-hook_v/2]) {
		cube([wall_thickness/2-hook_h, wall_thickness/2, ear_height+hook_v],center=true);
	}
	// right ear
	translate([-(house_width-wall_thickness)/2, wall_thickness-wall_thickness/4, house_height-ear_height/2-hook_v/2]) {
		cube([wall_thickness/2-hook_h, wall_thickness/2, ear_height+hook_v],center=true);
	}
}
// print solo: right wall (to be able to access the USB port comfortably)
// preferably upright print
//rightWall();

module building_open_wall() {
	difference() {
		building();
		rightWall(0, 0.1);
	}
}
// print solo: lighthouse + house
building_open_wall();

module lighthouseRoofTop() {
	difference() {
		lighthouseRoof();
		lighthouseLightCabin(0.4);
	}
}
// print solo: lighthouse roof
//lighthouseRoofTop();

// print solo: lighthouse light cabin (vase mode)
//lighthouseLightCabin();

module wall_support() {
	// support for wall added to roof
	roof_support_height = wall_thickness;
	roof_support_width = 4;
	roof_support_thickness = 2*wall_thickness/3;
	translate([-house_width/2-roof_support_thickness/2-0.2, lower_d/2, house_height-roof_support_height/2]) {
		difference() {
			cube([roof_support_thickness,roof_support_width,roof_support_height],center=true);
			rotate(-atan(roof_support_thickness/roof_support_height), [0,1,0]) {
			translate([-roof_support_thickness/2,0,0])
				cube([2,roof_support_width+0.2,roof_support_height*2],center=true);
			}
		}
	}
}

module roofCap() {
	difference() {
		roof();
		lighthouseLower(-0.2);
	}
	difference() {
		translate([0, lower_d/2, house_height-ridge_height/2]) {
			rotate(90, [1,0,0]) {
				cube([house_width-wall_thickness*2-0.2, ridge_height, lower_d-wall_thickness-0.2], center=true);
			}
		}
		lighthouseLower(-0.2);
	}
	// add additional support for right wall
	wall_support();
	// add additional support for left wall (for the sake of symmetry)
	mirror([1,0,0]) {
		wall_support();
	}
}
// print solo: house roof
//roofCap();
