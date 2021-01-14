// adafruit
// display dimensions (excluding mounting holes): 61.5mm x 31.4mm x 6.6mm + 5x5mm holes
// led: Outer diameter: 36.8mm, Inner diameter: 23.3mm, Thickness: 3.25mm

led_outer = 36.8;
led_inner = 23.3;
led_height = 3.25;
lower_d = 50;
wall_thickness = 2;
lower_part_height = 120;
light_part_height = 20;
light_part_d = led_outer+4+wall_thickness*2; // increased by 4 mm to fit

ridge_height = 4;
tolerance = 0.8; // for sliding things into one another (0.4 is very tight, 0.6 is tight)

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
house_depth = lower_d*1.5;

house_roof_height = 17;

floor_thickness = 1;

module lighthouseLight(wall=0) {
	translate([0,0,lower_part_height+light_part_height/2]) {
		cylinder(d=light_part_d-wall_thickness/2-0.2-wall, h=light_part_height+ridge_height*2, $fn=600, center=true);
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
		translate([0, house_depth/2, house_height/2]) {
			rotate(90, [1,0,0]) {
				cube([house_width-wall*2, house_height, house_depth-wall*2], center=true);
			}
		}
		// display window
		translate([tolerance, house_depth, house_height/2-display_vertical_shift]) {
			rotate(90, [1,0,0]) {
				cube([display_width+tolerance, display_height, wall_thickness*4], center=true);
			}
		}
	}
}

module roof() {
	translate([0, house_depth/2, house_height+house_roof_height/2]) {
		//for (x = [-8-wall_thickness*2 : 0.1 : 8+wall_thickness*2]) {
		//	translate([x, 0, 0]) {
				rotate(90+45, [0,0,1]) {
					cylinder(r1=house_depth*0.75, r2=0, h=house_roof_height, $fn=4, center=true);
				}
			//}
		//}
	}
}


module lighthouseLightCabin(thickness=0.4) {
	difference() {
		lighthouseLight();
		lighthouseLight(thickness);
	}
}

module lighthouseHouse(wall=0) {
	difference() {
		lighthouseLower(wall);
		lighthouseLightCabin(0.4+tolerance);
	}
	house(wall);
}


display_depth = 3;
hook_hole_depth = display_depth+2*tolerance;

module display_controller(lcd_height, support_height) {
	lcd_thickness = lcd_thickness+tolerance;
	// add tolerance above and below display, as well as behind ears
	// display
	cube([lcd_width+tolerance,lcd_thickness,lcd_height],center=true);
	// ears
	// upper right
	translate([lcd_width/2-hole_size/2, lcd_thickness/2-hook_hole_depth/2, lcd_height/2+hole_size/2]) {
		cube([hole_size+tolerance,hook_hole_depth,hole_size],center=true);
	}
	// lower right
	translate([lcd_width/2-hole_size/2, lcd_thickness/2-hook_hole_depth/2, -lcd_height/2-hole_size/2]) {
		cube([hole_size+tolerance,hook_hole_depth,hole_size],center=true);
	}
	// upper left
	translate([-lcd_width/2+hole_size/2, lcd_thickness/2-hook_hole_depth/2, lcd_height/2+hole_size/2]) {
		cube([hole_size,hook_hole_depth,hole_size],center=true);
	}
	// lower left
	translate([-lcd_width/2+hole_size/2, lcd_thickness/2-hook_hole_depth/2, -lcd_height/2-hole_size/2]) {
		cube([hole_size,hook_hole_depth,hole_size],center=true);
	}
	// slide channels for inserting the display
	// upper
	translate([0, 0, lcd_height/2+(support_height*0.75)/2]) {
		cube([lcd_width-2*hole_size,lcd_thickness,support_height*0.75],center=true);
	}
	// lower
	translate([0, 0, -lcd_height/2-hole_size/2]) {
		cube([lcd_width-2*hole_size,lcd_thickness,hole_size],center=true);
	}
}

module display_controller_mount() {
	lcd_height = lcd_inner_height+tolerance/2;
	support_depth = lcd_thickness+tolerance;
	support_height = house_height-ridge_height-tolerance-lcd_height;
	translate([0,-support_depth/2+tolerance,0]) {
		difference() {
			// cube cast
			translate([(house_width-lcd_width)/4,-tolerance/2,ridge_height/2]) {
				cube([house_width-(house_width-lcd_width)/2,support_depth-tolerance,support_height+lcd_height], center=true);
			}
			display_controller(lcd_height, support_height);
		}
		// ledge below controller
		ledge_depth = 20-support_depth;
		translate([wall_thickness+tolerance/4, -support_depth/2-ledge_depth/2,-lcd_height/2-hole_size/2]) {
			cube([house_width-wall_thickness*2-tolerance/2,ledge_depth,hole_size], center=true);
		}
		// ledge below display and controller
		total_ledge_depth = ledge_depth+support_depth;
		translate([wall_thickness+tolerance/4, -total_ledge_depth/2+support_depth/2,-lcd_height/2-support_height/4-hole_size/2+tolerance/4]) {
			cube([house_width-wall_thickness*2-tolerance/2,total_ledge_depth,support_height/2-hole_size], center=true);
		}
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

module door(frame=0, thickness=door_thickness, width=door_width, height=door_height, angle=0, offset_h=0, offset_wh=door_width-tolerance/2) {
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
	translate([house_width/2*side,house_depth/3,window_height*1.5+(house_window_height-window_height)/2]) {
		cube([window_thickness, window_width*1.2, house_window_height], center=true);
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
	door(0, window_thickness, window_width, window_height, 0, lower_part_height*0.5, window_height);
	door(0, window_thickness, window_width, window_height, 180, lower_part_height*0.77, window_height);
	/*door(0, window_thickness, window_width, window_height, 0, lower_part_height*0.4, window_height);
	door(0, window_thickness, window_width, window_height, 90, lower_part_height*0.5, window_height);
	door(0, window_thickness, window_width, window_height, 180, lower_part_height*0.6, window_height);
	door(0, window_thickness, window_width, window_height, -90, lower_part_height*0.75, window_height);*/
	house_windows();
	house_windows(-1);
}

module usbSlot() {
	height = 12;
	width = 7;
	translate([-house_width/2, house_depth-12-width/2-wall_thickness/2, house_height/2-display_vertical_shift]) {
		cube([wall_thickness*2, width+wall_thickness, height+0.4], center=true);
	}
	// for position comparison
	//translate([-house_width/2, house_depth-12/2, 17/2]) #cube([1,12,17], center=true);
}

module buildingComplex() {
	difference() {
		lighthouseHouse();
		lighthouseHouse(wall_thickness);
	}
	translate([0, house_depth-wall_thickness, house_height/2+tolerance/2-display_vertical_shift]) {
		display_controller_mount();
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
	translate([0,house_depth/2,floor_thickness/2]) {
		cube([house_width, house_depth, floor_thickness], center=true);
	}
	// lighthouse floor
	cylinder(d=lower_d-wall_thickness/2, h=floor_thickness, $fn=600);
	// doorway floor
	translate([0, -lower_d/2+door_thickness/2, floor_thickness/2]) {
		cube([door_width, door_thickness, floor_thickness], center=true);
	}
}

module rightWallCast() {
	translate([-(house_width-wall_thickness)/2, (house_depth)/2, house_height/2+floor_thickness/2]) {
		cube([wall_thickness, house_depth-2*wall_thickness, house_height-floor_thickness], center=true);
	}
}

module rightWall(outer_tolerance=0) {
	// copy right wall
	difference() {
		difference() {
			rightWallCast();
			windows();
		}
		usbSlot();
	}
	// bottom ledge
	translate([-(house_width)/2+wall_thickness-tolerance/4*2, (house_depth)/2, floor_thickness/4+floor_thickness/2]) {
		cube([wall_thickness/2-tolerance/4+outer_tolerance, house_depth-2*wall_thickness, floor_thickness/2+outer_tolerance],center=true);
	}
	// left ear
	ear_height = house_height-floor_thickness/2;
	translate([-(house_width)/2+wall_thickness-tolerance/4*2, house_depth-wall_thickness+wall_thickness/4, house_height-ear_height/2]) {
		cube([wall_thickness/2-tolerance/4+outer_tolerance, wall_thickness/2, ear_height+outer_tolerance],center=true);
	}
	// right ear
	translate([-(house_width)/2+wall_thickness-tolerance/4*2, wall_thickness-wall_thickness/4, house_height-ear_height/2]) {
		cube([wall_thickness/2-tolerance/4+outer_tolerance, wall_thickness/2, ear_height+outer_tolerance],center=true);
	}
}
// print solo: right wall (to be able to access the USB port comfortably)
// preferably upright print
//rightWall();

module building_open_wall() {
	difference() {
		building();
		rightWall(tolerance/2);
	}
}
// print solo: lighthouse + house
//building_open_wall();

/*translate([0,0,lower_part_height])
#sphere(r=led_outer/2, $fn=200);*/

module lighthouseRoofTop() {
	difference() {
		lighthouseRoof();
		lighthouseLightCabin(0.4+tolerance);
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
	translate([-house_width/2-roof_support_thickness/2-tolerance/2, house_depth/2, house_height-roof_support_height/2]) {
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
		lighthouseLower(-tolerance);
	}
	difference() {
		translate([0, house_depth/2, house_height-ridge_height/2]) {
			rotate(90, [1,0,0]) {
				cube([house_width-wall_thickness*2-tolerance, ridge_height, house_depth-wall_thickness*2-tolerance], center=true);
			}
		}
		lighthouseLower(-tolerance);
	}
	// add additional support for right wall
	wall_support();
	// add additional support for left wall (for the sake of symmetry)
	mirror([1,0,0]) {
		wall_support();
	}
}
// print solo: house roof
roofCap();

inner_hole_size = 2;
pin_thickness = 1.5;
frame_thickness = hook_hole_depth - display_depth - 0.2;
frame_arms = 5;
cover_height = lcd_inner_height-3*2;
cover_width = 50;
cover_offset_right = 3;
cover_thickness = 0.4; // print 0.2 mm

new_lcd_outer_height = lcd_outer_height-0.4;

module pin() {
	translate([lcd_width/2-frame_arms/2, frame_thickness/2+pin_thickness/2, new_lcd_outer_height/2-frame_arms/2])
		rotate(90, [1,0,0])
			cylinder(d=inner_hole_size,h=pin_thickness,$fn=200,center=true);
}

module display_frame() {
	translate([0,frame_thickness/2,0]) {
		difference() {
			cube([lcd_width, frame_thickness, new_lcd_outer_height], center=true);
			cube([lcd_width, frame_thickness+0.1, new_lcd_outer_height-2*frame_arms], center=true);
		}
		#pin();
		mirror([1,0,0]) pin();
		mirror([0,0,1]) pin();
		mirror([1,0,0]) mirror([0,0,1]) pin();
	}

	// support pillar
	pillar_width = (house_width-wall_thickness*2-lcd_width)/2-tolerance;
	translate([lcd_width/2+pillar_width/2,hole_size/2, 0])
		cube([pillar_width, hole_size, new_lcd_outer_height], center=true);

	difference() {
		translate([-lcd_width/2,0,-lcd_inner_height/2])
			cube([lcd_width, cover_thickness, lcd_inner_height]);
		translate([lcd_width/2-cover_width-cover_offset_right,0,-cover_height/2])
			cube([cover_width, cover_thickness, cover_height]);
	}
}
// print solo: display frame
//display_frame();