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

use <threads.scad>

module pyramid(b_width, t_width, b_depth, t_depth, height) {
    linear_extrude(height=height, scale=[t_width/b_width, t_depth/b_depth]) square([b_width, b_depth], center=true);
}

module cutout(b_width, t_width, b_depth, t_depth, b_height, t_height) {
    union() {
        cube([t_width,t_depth,t_height+b_height]);
        translate([t_width/2, t_depth/2, 0]) pyramid(b_width, t_width, b_depth, t_depth, b_height);
    }
}

module pill(h, r, s=0.2) {
    translate([0,0,r*s]) scale([1,1,s]) sphere(r=r);
    translate([0,0,r*s]) cylinder(h=h-2*r*s, r=r);
    translate([0,0,h-r*s]) scale([1,1,s]) sphere(r=r);
}

module threaded_stand(stand_h, stand_r=2.5, screw_h=3.5, screw_d=2) {
    // ensure that screw fits into stand
    assert(screw_h <= stand_h);
    assert(screw_d + 1 <= stand_r * 2);
    difference() {
        cylinder(h=stand_h, r=stand_r);
        translate([0, 0, stand_h - screw_h])
        metric_thread(
            diameter=screw_d,
            pitch=0.5,             // 3.5 mm travel per 7 turns
            length=screw_h + 0.5,  // real screw height + 0.5 mm offset
            internal=true,
            test=$preview          // don't show threads in preview
        );
    }
}

module outer_box(width=311, depth=101, height=14,  wall_w = 3.1, wall_d=2.875, wall_h=3.1, stand_h=5) {
    // TODO determine r_outer and r_inner depending on width, depth and wall thickness
    r_outer=6;
    r_inner=3;

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

    // threaded stands
    for (rel_stand_pos = [
        [24.85,  9.475,  0], // left-bottom
        [24.85,  66.725, 0], // left-top
        [128.45, 47.775, 0], // mid-left
        [187.7,  9.475,  0], // mid-right
        [260.15, 66.925, 0], // right-top
        [266.55, 9.575,  0], // right-bottom
    ]) {
        translate([wall_w, wall_d, wall_h] + rel_stand_pos)
        threaded_stand(stand_h);
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

module dove_tail(w1, w2, depth, height) {
    translate([max(w1/2, w2/2), 0, 0])
    linear_extrude(height=height)
    polygon(points=[[w1/2, 0], [w2/2, depth], [-w2/2, depth], [-w1/2, 0]]);
}

module dove_tail_array(dim, count=4, tol=0, factor=0.6, invert=false) {
    // check input values
    assert (factor > 0 && factor < 1);
    assert (count > 0);
    // determine width of dove tails
    w = dim[0] / (count + abs(0.5 - factor));
    w1 = w * factor - tol;
    w2 = w * (1-factor) - tol;
    // place dove tails in an array
    if (invert) {
        difference() {
            for (i = [0:count - 1]) {
                translate([i*w + tol/2, 0, 0])
                dove_tail(w2, w1, dim[1], dim[2]);
            }
            translate([-dim[0], dim[1] - tol, -dim[2]])
            cube([3*dim[0], 2*tol, 3*dim[2]]);
        }
    } else {
        difference() {
            for (i = [0:count - 1]) {
                translate([i*w + w/2 + tol/2, 0, 0])
                dove_tail(w1, w2, dim[1], dim[2]);
            }
            translate([-dim[0], -tol, -dim[2]])
            cube([3*dim[0], 2*tol, 3*dim[2]]);
        }
    }
}

module split_box(left=true, width=311, depth=101, height=14, wall_w = 3.1, wall_d=2.875, wall_h=3.1, stand_h=5) {

    tail_depth = 6;
    tail_offset = 20;
    tol = 0.4;

    difference() {
        outer_box(width, depth, height, wall_w, wall_d, wall_h, stand_h);
        translate([left ? width / 2 : -width / 2, 0, 0]) cube([width, depth, height]);
        translate([width/2 - tol/2, 0, -height]) cube([tol, depth, 3*height]);
        translate([width/2 + tail_depth / 2, tail_offset / 2, -wall_h]) rotate([0,0,90])
        dove_tail_array([depth - tail_offset, tail_depth, 3*wall_h], count=5, invert=left, tol=-tol);
    }
    translate([width/2 + tail_depth/2, 10,0]) rotate([0,0,90])
    dove_tail_array([depth - tail_offset, tail_depth, wall_h], count=5, invert=!left, tol=tol);
}

$fn = 100;
split_box();
