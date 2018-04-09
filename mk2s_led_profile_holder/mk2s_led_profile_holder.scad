/*
 * LED profile holder for Prusa i3 MK2S with an attachment designed like the Prusa i3 MK2S spool holder
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

// general holder dimension in mm
thickness = 8;
base_w = 20;
overlap_w = 6;

// Prusa i3 MK2S frame dimensions in mm
frame_tolerance = 0.4;
frame_w = 6 + frame_tolerance;
frame_h = 40 + frame_tolerance;

// cable tie dimensions in mm
tie_tolerance_w = 0.7;
tie_tolerance_h = 1;
tie_w = 2.5 + tie_tolerance_w;
tie_h = 1 + tie_tolerance_h;

// base part of the holder
$fn=50;
base(frame_w, frame_h, thickness, base_w, overlap_w, tie_w, tie_h);

// arm dimensions in mm
arm_w = 160;
arm_h = 40;
arm_angle = 60;
arm_border = 3;

// aluminium profile dimensions in mm
profile_tolerance = 0.1;
profile_w = 12.2 + profile_tolerance;
profile_h = 7 + profile_tolerance;
profile_num = 4;
profile_spacing = 1;
profile_angle = -29;

// arm part of the holder
arm(
	arm_w, arm_h, arm_angle, arm_border,
	thickness, base_w, overlap_w,
	profile_w, profile_h, profile_num, profile_spacing, profile_angle
);

function cot(x) = tan(90 - x);

module triangle_strut(size, width) {
	points=[[0, 0], [size, 0], [0, size]];
	difference() {
		offset(delta = width) polygon(points);
		polygon(points);
	}
}

module profile_holder(num, w, h, spacing, border) {
	difference() {
		square([num * w + (num - 1) * spacing + 2 * border, h + 2 * border]);
		for (i = [0:num - 1]) {
			x = border + i * (w + spacing);
			translate([x, border]) square([w, h]);
		}
	}
}

module base(frame_w, frame_h, thickness, base_w, overlap_w, tie_w, tie_h,
			size=6, height=10, bottom_overlap_w=2, bracket_len=4)
{
	// outer shape of the base
	outer_points = [
		[0, 0],
		[0 , -bracket_len],
		[overlap_w, -bracket_len],
		[overlap_w, height],
		[0, height],
		[-base_w, height],
		[-1.1 * base_w, 0],
		[-frame_w - 1.5 * size, -frame_h],
		[-frame_w - size, -(frame_h + size)],
		[bottom_overlap_w, -(frame_h + size)],
		[bottom_overlap_w, -frame_h],
		[-frame_w, -frame_h],
		[-frame_w, 0],
	];
	// shape of the cable tie hole
	inner_points = [
		[0, 2],
		[-1.1 * base_w + 1, 2],
		[-frame_w - 1.5 * size + 1, -frame_h],
		[-frame_w, -frame_h - 2],
		[-1, -frame_h - 1],
	];
	translate([0, -height, 0]) difference() {
		linear_extrude(thickness) polygon(points=outer_points);
		translate ([0, 0, (thickness - tie_w) / 2]) linear_extrude(tie_w) difference() {
			offset(r = tie_h) polygon(points = inner_points);
			polygon(points = inner_points);
		}
		translate ([-1.1 * base_w, 1, (8 - tie_w - 2) / 2])
			cube(size = [1, tie_h + 2, tie_w + 2]);
	}
}

module arm(arm_width, arm_height, arm_angle, arm_border, thickness, base_w, overlap_w,
		profile_w, profile_h, profile_num, profile_spacing, profile_angle)
{
	// polygon definition
	holder_height = (profile_h + 2 * arm_border);
	arm_thickness = cos(profile_angle) * holder_height;
	arm_offset = abs(sin(profile_angle) * holder_height);
	attachment_offset = cot(arm_angle) * arm_height + cot(arm_angle) * arm_thickness;
	arm_points = [
		[-base_w, 0],
		[0, 0],
		[overlap_w, 0],
		[overlap_w, tan(arm_angle) * overlap_w],
		[cot(arm_angle) * arm_height, arm_height],
		[arm_width, arm_height],
		[arm_width + arm_offset, arm_height + arm_thickness],
		[-base_w + attachment_offset, arm_height + arm_thickness],
	];
	attachment_part = [[0, 1, 4, 7]];
	middle_part = [[4, 7, 6, 5]];
	
	linear_extrude(thickness) {
		// hollow arm
		difference() {
			polygon(points = arm_points);
			offset(r = -arm_border) polygon(points = arm_points, paths = attachment_part);
			offset(r = -arm_border) polygon(points = arm_points, paths = middle_part);
		}
		// attachment part
		intersection() {
			polygon(points = arm_points, paths = attachment_part);
			size = sin(arm_angle) * base_w - 2 * arm_border;
			width = arm_border;
			steps = size + 2 * width;
			for (i = [0:steps:arm_height + arm_border]) {
				rotate(arm_angle) translate([i, arm_border]) triangle_strut(size, width);
			}
		}
		// middle part
		intersection() {
			polygon(points = arm_points, paths = middle_part);
			size = arm_thickness - 2 * arm_border;
			width = arm_border / 2;
			steps = size + 2 * width;
			for (i = [cot(arm_angle) * arm_height:steps:arm_width]) {
				translate([i, arm_height + arm_border]) triangle_strut(size, width);
			}
		}
		// profile holder part
		translate([arm_width, arm_height]) rotate(profile_angle)
			profile_holder(profile_num, profile_w, profile_h, profile_spacing, arm_border);
	}
}
