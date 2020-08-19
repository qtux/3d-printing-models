/*
 * Protection case fitting a Quattro Stagioni glass by Bormioli Rocco
 *
 * Copyright (C) 2020  Annemarie Mattmann
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

// print in vase mode

total_height = 150; // height of the case (in mm)
straight_part_starts_at = 25; // height at which the straight printing starts (tube)

// glass is square with rounded edges
square_size = 35;
size_round_parts = 60;

// bottom diameter after first curvage
d_bottom = 102;

// scale values to fit glass sizes
small_glass = [0.75,0.75,0.6]; // 500 ml glass
large_glass = [1,1,1]; // 1.5 l glass

module Protection () {
	// bottom layer
	cylinder(d=d_bottom,h=1);

	// define bottom part below tube
	module Bottom (x=1,y=1,z=1) {
		scale([x,y,z]) {
			intersection() {
				// bottom round part
				linear_extrude(height=straight_part_starts_at, scale = [1.4,1.4], slices = 20, twist = 0, $fn=100) {
					circle(d=d_bottom);
				}
				// bottom cornered part
				translate([0, 0, straight_part_starts_at]){
					mirror([0,0,1]){
						linear_extrude(height=straight_part_starts_at, scale = [0.92,0.92], slices = 20, twist = 0, $fn=100) {
							scale([0.72,0.72,1]) {
								offset(r = size_round_parts) {
									square(square_size, center = true);
								}
							}
						}
					}
				}
			}
		}
	}
	// use hollowed out bottom
	difference() {
		Bottom();
		Bottom(0.99,0.99,1);
	}

	// tube
	translate([0, 0, straight_part_starts_at]) {
		scale([0.72,0.72,1]) {
			linear_extrude(height = total_height - straight_part_starts_at, twist = 0, slices = 60, $fn=100) {
				difference() {
					offset(r = size_round_parts) {
						square(square_size, center = true);
					}
					offset(r = size_round_parts) {
						square(square_size-1, center = true);
					}
				}
			}
		}
	 }
 }
 
 scale(large_glass) {
	Protection();
 }
 
//cylinder(d=84.5,h=1); // for size comparison (small glass)
//cylinder(d=112.5,h=1); // for size comparison (large glass)