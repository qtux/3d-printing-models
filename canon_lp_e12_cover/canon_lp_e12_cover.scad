/*
 * Canon LP-E12 battery cover
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

// battery dimensions and tolerances in mm
battery_slit_h = 8;
tolerance = [0.8, 1, 0];
battery_size = [48.4, 32.3, 12.7] + tolerance;

// battery cover dimensions in mm
delta = 1;
h = 10;
hole_w = 25;
prism_w = 5;
prism_delta = 1.2;

cover(battery_size, battery_slit_h, h, delta, hole_w, prism_w, prism_delta);

module prism(l, s) {
	points = [[s/3, 0], [s, 0], [s, s]];
	translate([0, 0, s]) rotate([0, 90, 0])
	linear_extrude(l) polygon(points=points);
}

module hole(w, l, h) {
	points = [[-w/2, 1], [w/2, 1], [w/2, 0], [w/2 - h, -h], [-w/2 + h, -h], [-w/2, 0]];
	rotate([-90, 180, 0]) linear_extrude(l) polygon(points=points);
}

module cap(s, delta) {
	cube([delta + s, delta + s, delta]);
}

module cover(battery_size, battery_slit_h, h, delta, hole_w, prism_w, prism_delta) {
	// size of the basic battery cover
	cover_size = [battery_size.x + 2 * delta, battery_size.y + 2 * delta, h + delta];
	
	// translation values for the prisms
	x = [delta + 6, delta + battery_size.x - 6 - prism_w];
	y = [delta, delta + battery_size.y];
	z = battery_slit_h + delta;
	
	union() {
		// basic battery cover with a hole for pulling the battery out
		difference() {
			cube(cover_size);
			translate([1, 1, 1] * delta) cube(battery_size);
			translate([cover_size.x / 2, 0, cover_size.z]) hole(hole_w, cover_size.y, h * 0.6);
		}
		// prisms for holding the battery in place by snatching into the battery slits
		translate([x[0], y[0], z]) prism(prism_w, prism_delta);
		translate([x[1], y[0], z]) prism(prism_w, prism_delta);
		translate([x[0], y[1], z]) mirror([0, 1, 0]) prism(prism_w, prism_delta);
		translate([x[1], y[1], z]) mirror([0, 1, 0]) prism(prism_w, prism_delta);
		// caps for preventing the battery to fall out
		translate([0, 0, delta + h]) cap(2, delta);
		translate([0, battery_size.y - delta, delta + h]) cap(2, delta);
	}
}
