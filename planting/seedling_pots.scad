/*
 * Reusable seedling pots with a grid to hold them together, inspired by
 * https://www.thingiverse.com/thing:820829 and designed to fit inside a Romberg seedling dish
 * 
 * Copyright (C) 2017  Matthias Gazzari
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

$fn=200;

// pot dimensions in mm
pot_d = 40;
pot_h = 60;
pot_thickness = 1.6;	// 4 shells with a 0.4 mm nozzle

// grid dimensions in mm
grid_d = 48;			// per grid module
grid_h = 12;
grid_thickness = 1.6;	// 4 shells with a 0.4 mm nozzle
socket_d = 7;
socket_tolerance = 0.45;

// the final grid size (number of modules per dimension)
grid_size = [2, 4];

// 0: pot, 1: pot_cap, 2: tamper, 3: grid
choice = 3;

if (choice == 0)      pot(pot_h, pot_d, pot_thickness);
else if (choice == 1) pot_cap(pot_thickness, pot_d);
else if (choice == 2) tamper(pot_h, pot_d, pot_thickness*2);
else if (choice == 3) grid(grid_h, grid_d, grid_thickness, grid_size, pot_d, pot_thickness, socket_d, socket_tolerance);

// single pot
module pot(h, d, thickness, r=2) {
	width = d - 2 * r;
	linear_extrude(h) {
		difference() {
			offset(r=r + thickness) square(width, center=true);
			offset(r=r) square(width, center=true);
		}
	}
}

// cap to close the bottom part of a pot
module pot_cap(h, d, r=2) {
	width = d - 2 * r;
	linear_extrude(h) {
		difference() {
			offset(r=r) square(width, center=true);
			circle(5, center=true);
		}
	}
}

// tamper to push out the content of a pot
module tamper(h, d, thickness, tolerance=1, r=2) {
	width = d - 2 * r - tolerance;
	linear_extrude(thickness) {
		offset(r=r) square(width, center=true);
	}
	translate([0, 0, h * 0.6])
	cylinder(h=h * 0.8, r1=6, r2=4, center=true);
	translate([0, 0, h * 0.1])
	cylinder(h=h * 0.2, r1=16, r2=6, center=true);
}

// single grid module
module grid_module(h, d, thickness, pot_d, pot_thickness, socket_d, socket_tolerance, margin=2, full_holes=true) {
	difference() {
		cube([d, d, h], center=true);
		
		// remove the space required for a pot
		translate([0, 0, h * -0.25]) hull()
		pot(h, pot_d + socket_tolerance, pot_thickness);
		
		// add slits for air circulatioin
		cube([d - 2 * thickness, d - 2 * socket_d, h], center=true);
		cube([d - 2 * socket_d, d - 2 * thickness, h], center=true);
		
		// remove part of the edges to save material
		cavity_d = sqrt(2) * 0.75 * socket_d;
		for (dx = [-1, 1] * d / 2, dy = [-1, 1] * d / 2) {
			translate([dx, dy, 0]) rotate([0, 0, 45])
			cube([cavity_d, cavity_d, h], center=true);
			for(dz = [-1, 1] * 0.375 * h) {
				translate([dx, dy, dz])
				cube([cavity_d, cavity_d, 0.25 * h], center=true);
			}
		}
		
		// put holes into the sides to save material and for air circulation
        if (full_holes) {
            cube([d, d - 2 * socket_d, h - 2 * thickness], center=true);
            cube([d - 2 * socket_d, d, h - 2 * thickness], center=true);
        } else {
            ratio = ceil((d - 2 * socket_d) / (h - margin));
            w = (d - 2 * socket_d - (ratio - 1) * margin) / ratio;
            for (phi = [0, 90], i = [0:ratio - 1]) {
                delta = i * (w + margin) - d/2 + w/2 + socket_d;
                rotate([90, 0, phi]) translate([delta, 0, 0])
                linear_extrude(1.1 * d, center=true) {
                    translate([-w/2, -w/2]) polygon([
                        [0, 0],
                        [w - margin/sqrt(2), 0],
                        [0, w - margin/sqrt(2)]
                    ]);
                    translate([w/2, w/2]) polygon([
                        [0, 0],
                        [-w + margin/sqrt(2), 0],
                        [0, -w + margin/sqrt(2)]
                    ]);
                }
            }
        }
	}
}

// the grid holding assembled pots
module grid(h, d, thickness, size, pot_d, pot_thickness, socket_d, socket_tolerance) {
	// calculate new diameter based on the idea to overlap half of the grid module walls
	for (i = [0:size[0] - 1]) {
		for (j = [0:size[1] - 1]) {
			translate([i * d, j * d, 0])
			grid_module(h, d + thickness, thickness, pot_d, pot_thickness, socket_d, socket_tolerance);
		}
	}
}
