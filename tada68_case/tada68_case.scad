/*
 * Case for a TADA68 keyboard
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

// TADA68 properties in mm
tada_frame = [106.6, 15, 316] + [0.2, 0.2, 0.4];
key_cap_height = 15;
tada_bottom_height = 20;
tada_edge = 5;
tada_usb_clearance = 18;

// case properties in mm
wall = 2;
nib_height = 40;



// one half of the full case
tada_case_half(tada_frame, key_cap_height, tada_bottom_height, tada_edge, wall, tada_usb_clearance, nib_height);



module tada_case_half(tada_frame, key_cap_height, tada_bottom_height, tada_edge, wall, tada_usb_clearance, nib_height) {
	bbox = [tada_frame.x, tada_frame.y + key_cap_height + tada_bottom_height, tada_frame.z / 2];
	outer = bbox + [wall, wall, wall] * 2;
	nib_size = [tada_edge, nib_height, key_cap_height];
	// case
	difference() {
		translate(-1 * [wall, wall, wall]) cube(outer);
		translate([0, 0, wall + tada_usb_clearance]) cube(bbox);
		tada(tada_frame, key_cap_height, tada_bottom_height, tada_edge);
	}
	// nibs
	translate([0, 0, tada_frame.z / 2 + wall - nib_size.y / 2]) nib([tada_edge, nib_height, tada_bottom_height]);
	translate([0, tada_frame.y + tada_bottom_height, tada_frame.z / 2 + wall - nib_size.y / 2]) nib([tada_edge, nib_height, key_cap_height]);
}

module tada(frame, key_cap_height, bottom_height, edge) {
	inner = [frame.x - 2 * edge,  frame.y + key_cap_height + bottom_height, frame.z - 2 * edge];

	translate([edge, 0, edge]) cube(inner);
	translate([0, bottom_height, 0]) cube(frame);
}

module nib(size) {
	translate([0, size.z, 0])
	rotate([90, 0, 0])
	linear_extrude(size.z) polygon([
		[0,0],
		[0, size.y],
		[size.x, size.y],
		[size.x, size.y / 4]
	]);
}
