/*
 * Greenhouse frame compatible with Romberg seedling dishes
 * 
 * Copyright (C) 2018  Matthias Gazzari
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

// frame dimensions in mm
height = 200;
width = 240;
depth = 6;
foot_width = 12;
thickness = 1.6;
hole_radius = 2.4;

// slope of the frame in degrees
angle = 85;

// pin dimensions in mm
pin_radius = thickness * 0.5 * ((sqrt(2) - 1) / 2 + 1);
pin_height = 3;

// connector and rod dimensions in mm
nib_radius = hole_radius - 0.1;
rod_length = 325 / 2;
rod_radius = hole_radius + 1.2;
hole_length = 2 * depth + 0.4;
nib_length = 2 * depth;

// 0: frame with pins, 1: frame, 2: rod two nibs, 3:rod, 4:holder
choice = 0;

if (choice == 0)
	frame(width, height, depth, angle, thickness, foot_width, hole_radius, pin_radius, pin_height, true);
else if (choice == 1)
	frame(width, height, depth, angle, thickness, foot_width, hole_radius, pin_radius, pin_height, false);
else if (choice == 2)
	rod(rod_length, rod_radius, nib_radius, nib_length, hole_radius, hole_length, true);
else if (choice == 3)
	rod(rod_length, rod_radius, nib_radius, nib_length, hole_radius, hole_length, false);
else if (choice == 4)
	holder(4, foot_width, angle, pin_radius + 0.1, 1);

function cot(x) = tan(90 - x);

module strut(width, depth, thickness) {
	rotate(90) cube([width, thickness, depth]);
	rotate(45) cube([width * sqrt(2), thickness, depth]);
}

module pin(radius, height) {
	cylinder(r=radius, h=height - radius, $fn=40);
	translate([0, 0, height - radius])
	sphere(r= radius, $fn=40);
}

module connector(r, d, thickness) {
	difference() {
		hull() {
			cylinder(r=r + thickness, h=d, $fn=200);
			translate([r + thickness, 0, 0])
			cylinder(r=r + thickness, h=d, $fn=200);
		}
		cylinder(r=r, h=d, $fn=6);
	}
}

module holder(num, foot_w, angle, radius, h) {
	arm_w = foot_w * sin(angle);
	difference() {
		cube([2 * arm_w * (num - 1) + 4 * radius, radius * 4, h]);
		translate([radius * 2, radius * 2, 0])
		for(i = [0:arm_w * 2:arm_w * 2 * (num - 1)]) {
			translate([i, 0, 0])
			cylinder(r=radius, h=h, $fn=40);
		}
	}
}

module frame_part(w, h, d, angle, thickness, foot_w, hole_r, pin_r, pin_h, with_nobs) {
	// definitions
	arm_w = foot_w * sin(angle);
	points = [
		[0,0],
		[foot_w, 0],
		[cot(angle) * h + foot_w - cot(angle) * arm_w, h - arm_w],
		[w / 2, h - arm_w],
		[w / 2, h],
		[cot(angle) * h, h],
	];
	vertical = [[0, 1, 2, 5]];
	horizontal = [[2, 3, 4, 5]];

	// hollow part
	linear_extrude(d) difference() {
		polygon(points=points);
		offset(r = -thickness) polygon(points=points, paths=vertical);
		offset(r = -thickness) polygon(points=points, paths=horizontal);
	}
	
	// horizontal struts
	intersection() {
		linear_extrude(d) polygon(points=points, paths=horizontal);
		translate([0, h - arm_w, 0])
		for(i = [points[5][0]:arm_w:points[3][0]]) {
			translate([i, 0, 0])
			strut(arm_w, d, thickness);
		}
	}
	
	// vertical struts
	intersection() {
		linear_extrude(d) polygon(points=points, paths=vertical);
		translate([foot_w, 0, 0]) rotate(angle)
		for(i = [points[0][1]:arm_w:points[5][1]]) {
			translate([i, 0, 0])
			strut(arm_w, d, thickness);
		}
	}
	
	// foot
	tolerance = 0.4;
	translate([-tolerance - thickness, 0, 0])
	cube([foot_w + 2 * thickness + 2 * tolerance, thickness, depth]);
	translate([-thickness - tolerance, -2 * thickness, 0])
	cube([thickness, 3 * thickness, depth]);
	translate([foot_w + tolerance, -2 * thickness, 0])
	cube([thickness, 3 * thickness, depth]);
	
	// connectors
	shift = - hole_r - thickness;
	translate(points[5] + [shift, shift])
	connector(hole_r, d, thickness);
	translate(points[5] / 2 + [shift, shift])
	connector(hole_r, d, thickness);
	
	// nobs
	if (with_nobs) {
		// vertical
		translate([foot_w, 0, 0]) rotate(angle)
		translate([- thickness / 2, arm_w - pin_r, 0])
		for(i = [points[0][1] + arm_w:arm_w * 2:points[5][1]]) {
			translate([i, 0, d])
			pin(pin_r, pin_h);
		}
		// horizontal
		translate([- thickness / 2, h - pin_r, 0])
		for(i = [points[5][0] + arm_w:arm_w * 2:points[3][0]]) {
			translate([i, 0, d])
			pin(pin_r, pin_h);
		}
	}
}

module frame(w, h, d, angle, thickness, foot_w, hole_r, pin_r, pin_h, with_nobs) {
	frame_part(width, height, depth, angle, thickness, foot_width, hole_r, pin_r, pin_h, with_nobs);
	translate([width, 0, 0]) mirror()
	frame_part(width, height, depth, angle, thickness, foot_width, hole_r, pin_r, pin_h, with_nobs);
}


module rod(l, r, nib_r, nib_l, hole_r, hole_l, two_nibs) {
	rotate([30, 0, 0]) rotate([0, 90, 0]) {
		if (two_nibs) {
			cylinder(r=r, h=l, $fn=6);
			translate([0, 0, -nib_l])
			cylinder(r=nib_r, h=nib_l, $fn=6);
		}
		else {
			difference() {
				cylinder(r=r, h=l, $fn=6);
				cylinder(r=hole_r, h=hole_l, $fn=6);
			}
		}
		translate([0, 0, l])
		cylinder(r=nib_r, h=nib_l, $fn=6);
	}
}
