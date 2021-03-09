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

// TADA68 dimensions
pcb_width = 304.8;
pcb_depth = 95.25;
pcb_clearance = 2; // required space below PCB (aside from the USB connector)
stand_h = 5;

module pyramid(b_width, t_width, b_depth, t_depth, height) {
    linear_extrude(height=height, scale=[t_width/b_width, t_depth/b_depth]) square([b_width, b_depth], center=true);
}

module cutout(b_width, t_width, b_depth, t_depth, b_height, t_height) {
    union() {
        cube([t_width,t_depth,t_height+b_height]);
        translate([t_width/2, t_depth/2, 0]) pyramid(b_width, t_width, b_depth, t_depth, b_height);
    }
}

module pill(h, r, sb=0.2, st=0.2) {
    translate([0,0,r*sb]) scale([1,1,sb]) sphere(r=r);    // bottom sphere
    translate([0,0,r*sb]) cylinder(h=h-r*st-r*sb, r=r);   // middle part
    translate([0,0,h-r*st]) scale([1,1,st]) sphere(r=r);  // top sphere
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

module outer_box(height=14, wall_w=2, wall_h=3.1, connector_hole_d=6) {
    // outer dimensions
    r_outer=2*wall_w;
    w_outer = pcb_width + 2*wall_w - r_outer;
    d_outer = pcb_depth + 2*wall_w - r_outer;

    // inner dimensions
    r_inner = wall_w;
    w_inner = pcb_width - r_inner;
    d_inner = pcb_depth - r_inner;

    // radius scaling factors
    st = 0.2;  // top corner radius scaling factor
    sb = 0.7;  // bottom corner radius scaling factor

    difference() {
        // outer box
        hull() {
            translate([r_outer, r_outer, 0]) pill(h=height, r=r_outer, st=st, sb=sb);
            translate([w_outer, r_outer, 0]) pill(h=height, r=r_outer, st=st, sb=sb);
            translate([w_outer, d_outer, 0]) pill(h=height, r=r_outer, st=st, sb=sb);
            translate([r_outer, d_outer, 0]) pill(h=height, r=r_outer, st=st, sb=sb);
        }
        // inner cutout
        translate([wall_w, wall_w, wall_h]) hull() {
            translate([r_inner, r_inner, 0]) pill(h=height, r=r_inner, st=0, sb=sb);
            translate([w_inner, r_inner, 0]) pill(h=height, r=r_inner, st=0, sb=sb);
            translate([w_inner, d_inner, 0]) pill(h=height, r=r_inner, st=0, sb=sb);
            translate([r_inner, d_inner, 0]) pill(h=height, r=r_inner, st=0, sb=sb);
        }
        // reset button cutout
        translate([wall_w + 22, wall_w + pcb_depth/2 - 7.5, 0])
        cutout(20, 15, 20, 15, wall_h, 1);
        // USB cutout
        translate([wall_w + 14.05, 2 * wall_w + pcb_depth, wall_h + stand_h - 4])
        rotate([90,0,0]) cutout(9.5, 8, 5.5, 4, wall_w/4, wall_w);
        // stand connector holes cutouts
        for (hole_pos = [
            [wall_w + 12,                (pcb_depth + 2 * wall_w) * 0.2,  -height],
            [wall_w + 12,                (pcb_depth + 2 * wall_w) * 0.8,  -height],
            [wall_w + pcb_width/2 - 7.5, (pcb_depth + 2 * wall_w) * 0.2,  -height],
            [wall_w + pcb_width/2 - 7.5, (pcb_depth + 2 * wall_w) * 0.8,  -height],
            [wall_w + pcb_width/2 + 7.5, (pcb_depth + 2 * wall_w) * 0.2,  -height],
            [wall_w + pcb_width/2 + 7.5, (pcb_depth + 2 * wall_w) * 0.8,  -height],
            [wall_w + pcb_width - 12,    (pcb_depth + 2 * wall_w) * 0.2,  -height],
            [wall_w + pcb_width - 12,    (pcb_depth + 2 * wall_w) * 0.8,  -height],
        ]) {
            translate(hole_pos) cylinder(d=connector_hole_d,h=3*height);
        }
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
        translate([wall_w, wall_w, wall_h] + rel_stand_pos)
        threaded_stand(stand_h + 0.05);
    }

    // outer stands horizontal
    for (rel_outer_stand_pos_h = [
        [pcb_width * 0.25, 0, 0],
        [pcb_width * 0.25, pcb_depth, 0],
        [pcb_width * 0.75, 0, 0],
        [pcb_width * 0.75, pcb_depth, 0],
    ]) {
        translate([wall_w, wall_w, wall_h] + rel_outer_stand_pos_h)
        cylinder(h=stand_h, r=wall_w);
    }
    // outer stands vertical
    for (rel_outer_stand_pos_v = [
        [0        , pcb_depth / 2, 0],
        [pcb_width, pcb_depth / 2, 0],
    ]) {
        translate([wall_w, wall_w, wall_h] + rel_outer_stand_pos_v)
        cylinder(h=stand_h, r=wall_w);
    }
}

module dove_tail(w1, w2, depth, height, lock_hole_d, lock_hole_rim) {
    max_w = max(w1, w2);
    min_w = min(w1, w2);
    diff_w = abs(w1 - w2);
    difference() {
        hull() {
            translate([diff_w/2, depth/2, height+lock_hole_d/2])
            rotate([0, 90, 0])
            cylinder(d=lock_hole_d+lock_hole_rim*2, h=min_w);
            translate([max_w/2, 0, 0])
            linear_extrude(height=height)
            polygon(points=[[w1/2, 0], [w2/2, depth], [-w2/2, depth], [-w1/2, 0]]);
        }
        translate([0, depth/2, height + lock_hole_d/2])
        rotate([0, 90, 0])
        cylinder(d=lock_hole_d, h=max_w);
    }
}

module dove_tail_array(dim, count=4, tol=0, factor=0.6, invert=false, lock_hole_d=0, lock_hole_rim=0) {
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
                dove_tail(w2, w1, dim[1], dim[2], lock_hole_d, lock_hole_rim);
            }
            translate([-dim[0], dim[1] - tol, -dim[2]])
            cube([3*dim[0], 2*tol, 3*dim[2]]);
        }
    } else {
        difference() {
            for (i = [0:count - 1]) {
                translate([i*w + w/2 + tol/2, 0, 0])
                dove_tail(w1, w2, dim[1], dim[2], lock_hole_d, lock_hole_rim);
            }
            translate([-dim[0], -tol, -dim[2]])
            cube([3*dim[0], 2*tol, 3*dim[2]]);
        }
    }
}

module split_box(left=true, height=14, wall_w=2, wall_h=2) {

    tail_depth = 6;
    tail_offset = 20;
    tol = 0.04;
    lock_hole_d = 1.75 + 0.55; // PLA strand thickness + radial tolerance
    lock_hole_rim = 0.7;

    // ensure that the locking mechanism does not interfere with the PCB
    assert(lock_hole_d + lock_hole_rim <= stand_h - pcb_clearance);

    width = pcb_width + 2 * wall_w;
    depth = pcb_depth + 2 * wall_w;

    difference() {
        outer_box(height, wall_w, wall_h);
        translate([left ? width / 2 : -width / 2, 0, 0]) cube([width, depth, height]);
        translate([width/2 - tol/2, 0, -height]) cube([tol, depth, 3*height]);
        translate([width/2 + tail_depth / 2, tail_offset / 2, -wall_h]) rotate([0,0,90])
        dove_tail_array([depth - tail_offset, tail_depth, 3*wall_h], count=5, invert=left, tol=-tol);
        translate([width/2, -depth, wall_h + lock_hole_d/2])
        rotate([-90,0,0])
        cylinder(d=lock_hole_d, h=depth*3);
    }
    translate([width/2 + tail_depth/2, 10,0]) rotate([0,0,90])
    dove_tail_array([depth - tail_offset, tail_depth, wall_h], count=5, invert=!left, tol=tol, lock_hole_d=lock_hole_d, lock_hole_rim=lock_hole_rim);
}

module rounded_cube(dim, r_outer=2) {
    w_outer = dim[0] - r_outer;
    d_outer = dim[1] - r_outer;
    assert(w_outer >= r_outer);
    assert(d_outer >= r_outer);
    height = dim[2];
    hull() {
        translate([r_outer, r_outer, 0]) pill(h=height, r=r_outer);
        translate([w_outer, r_outer, 0]) pill(h=height, r=r_outer);
        translate([w_outer, d_outer, 0]) pill(h=height, r=r_outer);
        translate([r_outer, d_outer, 0]) pill(h=height, r=r_outer);
    }
}

module stand(width, wall_w, wall_h, angle, pairwise=false, connector_hole_d=6-0.1) {
    depth = pcb_depth + 2 * wall_w;

    difference() {
        translate([0, depth*0.1, 0])
        rounded_cube([width, depth*0.8, 20]);
        rotate([angle, 0, 0])
        translate([-width, 0, 0])
        cube([width*3, depth, 20]);
    }

    // pins
    positions = pairwise ? [
        [width/4, depth * 0.2, 0],
        [width/4, depth * 0.8, 0],
        [width/4 * 3, depth * 0.2, 0],
        [width/4 * 3, depth * 0.8, 0],
    ] :
    [
        [width/2, depth * 0.2, 0],
        [width/2, depth * 0.8, 0],
    ];

    rotate([angle, 0, 0])
    for (rel_outer_stand_pos_v = positions) {
        translate(rel_outer_stand_pos_v)
        cylinder(h = wall_h, d = connector_hole_d);
    }
}

module test_dove_tail(wall_w=2, height=14) {
    tail_depth = 6;
    width = pcb_width + 2 * wall_w;
    depth = pcb_depth + 2 * wall_w;
    intersection() {
        split_box(left=true, wall_w=wall_w, height=height);
        translate([width/2 - tail_depth, 0, 0]) cube([2*tail_depth, depth, height]);
    }
    translate([-2*tail_depth - 1, 0, 0]) intersection() {
        split_box(left=false, wall_w=wall_w, height=height);
        translate([width/2 - tail_depth, 0, 0]) cube([2*tail_depth, depth, height]);
    }
}

module show_case(height=14, wall_w=2, wall_h=2, angle=5) {
    rotate([angle, 0, 0]) {
        split_box(true, height, wall_w, wall_h);
        split_box(false, height, wall_w, wall_h);
    }

    single_stand_w = 20;
    dual_stand_w = 30;
    width = pcb_width + 2 * wall_w;

    translate([2*wall_w, 0, 0])
    stand(single_stand_w, wall_w, wall_h, angle);
    translate([(width - dual_stand_w)/2, 0, 0])
    stand(dual_stand_w, wall_w, wall_h, angle, pairwise=true);
    translate([width - single_stand_w - 2*wall_w, 0, 0])
    stand(single_stand_w, wall_w, wall_h, angle);
}


$fn = 40;
//split_box(left=true);
//test_dove_tail();
show_case();
