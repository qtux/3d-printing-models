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

// print in vase mode with 3 bottom layers

total_height = 150; // height of the case (in mm)
straight_part_starts_at = 55; // height at which the straight printing starts (tube)

// glass is square with rounded edges
square_size = 35;
size_round_parts = 60;
scale_factor_x = 0.74;
scale_factor_y = 0.74;

// lower part is round
d_lower_bottom = 95; // bottom diameter before first curvage
c1_height = 3; // height of the first circular part

d_c1 = d_lower_bottom + 7; // diameter after first curvage
c2_height = 3; // height of the second circular part

d_c2 = d_c1 + 4; // diameter after second curvage

// scale values to fit glass sizes
glass_scale = [1,1,1]; // 1.5 l glass
small = true;
if (small) {
	glass_scale = [0.75,0.75,0.6]; // 500 ml glass
	d_lower_bottom = d_lower_bottom + d_lower_bottom/26; // for more stability
}

module Protection () {
	// bottom layer
	difference() {
		cylinder(d=d_lower_bottom,h=1);
		cylinder(d=5*((d_lower_bottom)/6),h=1);
	}

	// define bottom circular part angling upwards
	// less complex: create gradually increasing linear extrude scales instead
	module Circular_upwards_angling_part(outer_scale, inner_scale) {
		translate([0, 0, c1_height + c2_height]) {
			linear_extrude(height=straight_part_starts_at - c1_height - c2_height, scale = [outer_scale,outer_scale], slices = 20, twist = 0, $fn=100) {
				scale([inner_scale,inner_scale,1]) {
					circle(d=d_c2);
				}
			}
		}
	}

	// define bottom part below tube
	module Bottom (x=1,y=1,z=1) {
		scale([x,y,z]) {

			// small glass is prone to tear between the two circular parts
			if (small) {
				linear_extrude(height=c1_height + c2_height, scale = [d_c2/(d_lower_bottom),d_c2/(d_lower_bottom)], slices = 20, twist = 0, $fn=100) {
					circle(d=d_lower_bottom);
				}
			} else {
				// lowest circular part c1
				linear_extrude(height=c1_height, scale = [d_c1/d_lower_bottom,d_c1/d_lower_bottom], slices = 20, twist = 0, $fn=100) {
					circle(d=d_lower_bottom);
				}
				// stacked circular part c2
				translate([0,0,c1_height]) {
					linear_extrude(height=c2_height, scale = [d_c2/d_c1,d_c2/d_c1], slices = 20, twist = 0, $fn=100) {
						circle(d=d_c1);
					}
				}
			}

			intersection() {
				//bottom circular parts (angling outwards to create a curved scaling)
				Circular_upwards_angling_part(1.35, 1);
				Circular_upwards_angling_part(1.25, 1.01);
				Circular_upwards_angling_part(1.2, 1.02);
				Circular_upwards_angling_part(1.17, 1.03);
				Circular_upwards_angling_part(1.16, 1.035);
				Circular_upwards_angling_part(1.13, 1.05);
				
				// bottom cornered part
				translate([0, 0, straight_part_starts_at]){
					mirror([0,0,1]){
						linear_extrude(height=straight_part_starts_at - c1_height - c2_height, scale = [0.98,0.98], slices = 20, twist = 0, $fn=100) {
							scale([scale_factor_x,scale_factor_y,1]) {
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
		scale([scale_factor_x,scale_factor_y,1]) {
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
 
 scale(glass_scale) {
	Protection();
 }
 
//cylinder(d=84.5,h=1); // for size comparison (small glass)
//cylinder(d=112.5,h=1); // for size comparison (large glass)
//translate([0,0,100]){cube([110,112.5,1], center = true);} // for size comparison considering non-square glass (large glass)
//translate([-70,0,0]){cube([2,2,straight_part_starts_at]);} // for height comparison
//translate([-75,0,0]){cube([2,2,total_height]);} // for height comparison