/*
 * Keyboard case for a TADA68 keyboard housing -- inspired by the work of
 * DjDionisos <https://www.thingiverse.com/thing:3011943>
 *
 * Copyright (C) 2020  Matthias Gazzari
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

module pyramid(b_width, t_width, b_depth, t_depth, height) {
    linear_extrude(height=height, scale=[t_width/b_width, t_depth/b_depth]) square([b_width, b_depth], center=true);
}

module cutout(b_width, t_width, b_depth, t_depth, b_height, t_height) {
    union() {
        translate([0,0,b_height]) cube([t_width,t_depth,t_height]);
        translate([t_width/2, t_depth/2, 0]) pyramid(b_width, t_width, b_depth, t_depth, b_height);
    }
}

module pill(h, r, s=0.2) {
    translate([0,0,r*s]) scale([1,1,s]) sphere(r=r);
    translate([0,0,r*s]) cylinder(h=h-2*r*s, r=r);
    translate([0,0,h-r*s]) scale([1,1,s]) sphere(r=r);
}

module outer_box(width=311, depth=101, height=14, r_outer=6, r_inner=3, wall_w = 3.1, wall_d=2.875, wall_h=3.1, stand_h=5) {
    // outer dimensions
    w_outer = width - r_outer;
    d_outer = depth - r_outer;
    // inner dimensions
    w_inner = width - r_inner - 2 * wall_w;
    d_inner = depth - r_inner - 2 * wall_d;
    difference() {
        // outer box
        hull() {
            translate([r_outer, r_outer, 0]) pill(h=height, r=r_outer);
            translate([w_outer, r_outer, 0]) pill(h=height, r=r_outer);
            translate([w_outer, d_outer, 0]) pill(h=height, r=r_outer);
            translate([r_outer, d_outer, 0]) pill(h=height, r=r_outer);
        }
        // inner cutout
        translate([wall_w, wall_d, wall_h]) hull() {
            translate([r_inner, r_inner, 0]) cylinder(h=height, r=r_inner);
            translate([w_inner, r_inner, 0]) cylinder(h=height, r=r_inner);
            translate([w_inner, d_inner, 0]) cylinder(h=height, r=r_inner);
            translate([r_inner, d_inner, 0]) cylinder(h=height, r=r_inner);
        }
        // reset button cutout
        translate([wall_w + 29.9, wall_d + 48.125, 0])
        cutout(20, 15, 20, 15, wall_h, height);
        // USB cutout
        translate([wall_w + 14.05, wall_d + 98.125, wall_h + 0.5])
        rotate([90,0,0]) cutout(9.5, 8, 5.5, 4, wall_d/4, wall_d);
    }

    // threaded stands - TODO use threadlib
    stand_r = 3.5;
    for (rel_stand_pos = [
        [24.85,  9.475,  0], // left-bottom
        [24.85,  66.725, 0], // left-top
        [128.45, 47.775, 0], // mid-left
        [187.7,  9.475,  0], // mid-right
        [260.15, 66.925, 0], // right-top
        [266.55, 9.575,  0], // right-bottom
    ]) {
        translate([wall_w, wall_d, wall_h] + rel_stand_pos) cylinder(h=stand_h, r=stand_r);
    }

    // outer stands
    outer_stand_h = stand_h - 0.5; // TODO why?
    // outer stands horizontal
    for (rel_outer_stand_pos_h = [
        [(width - 2 * wall_w) * 0.25, 0, 0],
        [(width - 2 * wall_w) * 0.25, depth - 2 * wall_d, 0],
        [(width - 2 * wall_w) * 0.75, 0, 0],
        [(width - 2 * wall_w) * 0.75, depth - 2 * wall_d, 0],
    ]) {
        translate([wall_w, wall_d, wall_h] + rel_outer_stand_pos_h)
        cylinder(h=outer_stand_h, r=wall_d);
    }
    // outer stands vertical
    for (rel_outer_stand_pos_v = [
        [0                 , depth/2 - wall_d, 0],
        [width - 2 * wall_w, depth/2 - wall_d, 0],
    ]) {
        translate([wall_w, wall_d, wall_h] + rel_outer_stand_pos_v)
        cylinder(h=outer_stand_h, r=wall_w);
    }
}

module connector(r1=10, r2=5, h=40) {
    translate([h/2, r1, 0]) difference() {
        hull () {
            translate([-h/2, 0, 0]) sphere(r=r2);
            sphere(r=r1);
            translate([ h/2, 0, 0]) sphere(r=r2);
        }
        translate([-h/2 - r2, -r1, -r1]) cube([h + 2 * r2, 2 * r1, r1]);
    }
}

module split_box(left=true, width=311, depth=101, height=14, r_outer=6, r_inner=3, wall_w = 3.1, wall_d=2.875, wall_h=3.1, stand_h=5) {

    // bridge connector settings
    bridge_r = min(wall_d, stand_h - 2); // 2 mm clearance
    bridge_w = 30;

    difference() {
        union() {
            outer_box(width, depth, height, r_outer, r_inner, wall_w, wall_d, wall_h, stand_h);
            for (pos = [depth - 2 * bridge_r, 0, (depth - 2 * bridge_r) / 2]) {
                translate([(width - bridge_w) / 2, pos, wall_h])
                connector(r1=bridge_r, r2=bridge_r / sqrt(2), h=bridge_w);
            }
        }
        translate([left ? width/2 : 0,0,0]) cube([width/2, depth, height]);
    }
}

$fn = 100;
split_box();
