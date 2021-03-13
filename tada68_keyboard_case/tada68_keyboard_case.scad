/*
 * Keyboard case for a TADA68 keyboard housing -- inspired by the work of
 * DjDionisos <https://www.thingiverse.com/thing:3011943>
 *
 * Copyright (C) 2020-2021  Matthias Gazzari
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

// -----------------------------------------------------------------------------
// project independent helper modules
// -----------------------------------------------------------------------------

module pyramid(b_width, t_width, b_depth, t_depth, height) {
    linear_extrude(height=height, scale=[t_width/b_width, t_depth/b_depth])
    square([b_width, b_depth], center=true);
}

module cutout(b_width, t_width, b_depth, t_depth, b_height, t_height) {
    union() {
        cube([t_width,t_depth,t_height+b_height]);
        translate([t_width/2, t_depth/2, 0])
        pyramid(b_width, t_width, b_depth, t_depth, b_height);
    }
}

module pill(h, r, sb=0, st=0) {
    translate([0,0,r*sb]) scale([1,1,sb]) sphere(r=r);    // bottom sphere
    translate([0,0,r*sb]) cylinder(h=h-r*st-r*sb, r=r);   // middle part
    translate([0,0,h-r*st]) scale([1,1,st]) sphere(r=r);  // top sphere
}

module rounded_cube(dim, r_outer=2, sb=0.2, st=0.2) {
    w_outer = dim[0] - r_outer;
    d_outer = dim[1] - r_outer;
    assert(w_outer >= r_outer);
    assert(d_outer >= r_outer);
    height = dim[2];
    hull() {
        translate([r_outer, r_outer, 0]) pill(h=height, r=r_outer, sb=sb, st=st);
        translate([w_outer, r_outer, 0]) pill(h=height, r=r_outer, sb=sb, st=st);
        translate([w_outer, d_outer, 0]) pill(h=height, r=r_outer, sb=sb, st=st);
        translate([r_outer, d_outer, 0]) pill(h=height, r=r_outer, sb=sb, st=st);
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

module dove_tail_array(dim, count, tol=0, factor=0.6, invert=false, lock_hole_d=0, lock_hole_rim=0) {
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

module threaded_stand(h, r, s_h, s_d, rim) {
    // ensure that screw fits into stand
    assert(s_h <= h);
    assert(s_d + rim <= r * 2);
    difference() {
        cylinder(h=h, r=r);
        translate([0, 0, h - s_h])
        metric_thread(
            diameter=s_d,
            pitch=screw_pitch,
            length=s_h,
            internal=true,
            test=$preview
        );
    }
}

// -----------------------------------------------------------------------------
// TADA68 related dimensions and helper modules
// -----------------------------------------------------------------------------

// TADA68 dimensions
pcb_width = 304.8;
pcb_depth = 95.25;
pcb_clearance = 2.3; // required space below PCB (aside from the USB connector)

// case dimensions
stand_h = 5;
assert(stand_h >= pcb_clearance);
wall_w = 2;
wall_h = 2;
case_r_outer = 2 * wall_w;
case_r_inner = wall_w;
case_height = 14; // TODO derive from wall_h + stand_h + pcb_height + some offset
case_width = pcb_width + 2 * wall_w;
case_depth = pcb_depth + 2 * wall_w;
case_con_hole_d = 6;

// screw dimensions
screw_h = 3.5 + 0.5;  // real screw height + 0.5 mm offset
screw_d = 2;
screw_pitch = 0.5;    // 3.5 mm travel per 7 turns

// foot & connector dimensions
foot_con_hole_d = case_con_hole_d - 0.1;
foot_angle = 5;

module case() {
    // outer dimensions
    box_width = case_width - case_r_outer;
    box_depth = case_depth - case_r_outer;

    // inner dimensions
    cutout_width = pcb_width - case_r_inner;
    cutout_depth = pcb_depth - case_r_inner;

    // radius scaling factors
    st = 0.2;  // top corner radius scaling factor
    sb = 0.7;  // bottom corner radius scaling factor

    difference() {
        // outer box
        hull() {
            translate([case_r_outer, case_r_outer, 0]) pill(h=case_height, r=case_r_outer, st=st, sb=sb);
            translate([box_width,    case_r_outer, 0]) pill(h=case_height, r=case_r_outer, st=st, sb=sb);
            translate([box_width,    box_depth,    0]) pill(h=case_height, r=case_r_outer, st=st, sb=sb);
            translate([case_r_outer, box_depth,    0]) pill(h=case_height, r=case_r_outer, st=st, sb=sb);
        }
        // inner cutout without stands
        difference() {
            translate([wall_w, wall_w, wall_h]) hull() {
                translate([case_r_inner, case_r_inner, 0]) pill(h=case_height, r=case_r_inner, st=0, sb=sb);
                translate([cutout_width, case_r_inner, 0]) pill(h=case_height, r=case_r_inner, st=0, sb=sb);
                translate([cutout_width, cutout_depth, 0]) pill(h=case_height, r=case_r_inner, st=0, sb=sb);
                translate([case_r_inner, cutout_depth, 0]) pill(h=case_height, r=case_r_inner, st=0, sb=sb);
            }
            // outer stands horizontal
            for (rel_outer_stand_pos_h = [
                [pcb_width * 0.25, 0, 0],
                [pcb_width * 0.25, pcb_depth, 0],
                [pcb_width * 0.5, 0, 0],
                [pcb_width * 0.5, pcb_depth, 0],
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
        // reset button cutout
        translate([wall_w + 24, wall_w + pcb_depth/2 - 7.5, 0])
        cutout(14, 11, 18, 15, wall_h, 1);
        // USB cutout
        translate([wall_w + 14.05, 2 * wall_w + pcb_depth, wall_h + stand_h - 4])
        rotate([90,0,0]) cutout(9.5, 8, 5.5, 4, wall_w/4, wall_w);
        // stand connector holes cutouts
        for (hole_pos = [
            [wall_w + 12,              case_depth * 0.2, -case_height],
            [wall_w + 12,              case_depth * 0.8, -case_height],
            [case_width/2 - 7.5,       case_depth * 0.2, -case_height],
            [case_width/2 - 7.5,       case_depth * 0.8, -case_height],
            [case_width/2 + 7.5,       case_depth * 0.2, -case_height],
            [case_width/2 + 7.5,       case_depth * 0.8, -case_height],
            [case_width - wall_w - 12, case_depth * 0.2, -case_height],
            [case_width - wall_w - 12, case_depth * 0.8, -case_height],
        ]) {
            translate(hole_pos) cylinder(d=case_con_hole_d, h=3*case_height);
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
        threaded_stand(stand_h, 2.5, screw_h, screw_d, 1);
    }
}

module split_case(left=true) {
    tail_depth = 6;
    tail_offset = 20;
    tol = 0.04;
    lock_hole_d = 1.75 + 0.35; // PLA strand thickness + radial tolerance
    // ensure that the locking mechanism does not interfere with the PCB
    lock_hole_rim = stand_h - pcb_clearance - lock_hole_d;

    difference() {
        case();
        translate([left ? case_width / 2 : -case_width / 2, 0, 0]) cube([case_width, case_depth, case_height]);
        translate([case_width/2 - tol/2, 0, -case_height]) cube([tol, case_depth, 3*case_height]);
        translate([case_width/2 + tail_depth / 2, tail_offset / 2, -wall_h]) rotate([0,0,90])
        dove_tail_array([case_depth - tail_offset, tail_depth, 3*wall_h], count=5, invert=left, tol=-tol);
        translate([case_width/2, -case_depth, wall_h + lock_hole_d/2])
        rotate([-90,0,0])
        cylinder(d=lock_hole_d, h=case_depth*3);
    }
    translate([case_width/2 + tail_depth/2, 10,0]) rotate([0,0,90])
    dove_tail_array([case_depth - tail_offset, tail_depth, wall_h], count=5, invert=!left, tol=tol, lock_hole_d=lock_hole_d, lock_hole_rim=lock_hole_rim);
}

module foot(width, pairwise=false) {
    difference() {
        translate([0, case_depth*0.1, 0])
        rounded_cube([width, case_depth*0.8, 20]);
        rotate([foot_angle, 0, 0])
        translate([-width, 0, -sin(foot_angle) * case_r_outer])
        cube([width*3, case_depth, 20]);
    }

    // pins
    positions = pairwise ? [
        [width/4, case_depth * 0.2, 0],
        [width/4, case_depth * 0.8, 0],
        [width/4 * 3, case_depth * 0.2, 0],
        [width/4 * 3, case_depth * 0.8, 0],
    ] :
    [
        [width/2, case_depth * 0.2, 0],
        [width/2, case_depth * 0.8, 0],
    ];

    rotate([foot_angle, 0, 0])
    for (rel_outer_foot_pos_v = positions) {
        translate(rel_outer_foot_pos_v + [0, 0, -sin(foot_angle) * case_r_outer])
        pill(h=wall_h + stand_h - pcb_clearance, r=foot_con_hole_d/2, st=0.5);
    }
}

module test_dove_tail() {
    tail_depth = 6;
    intersection() {
        split_case(left=true);
        translate([case_width/2 - tail_depth, 0, 0]) cube([2*tail_depth, case_depth, case_height]);
    }
    translate([-2*tail_depth - 1, 0, 0]) intersection() {
        split_case(left=false);
        translate([case_width/2 - tail_depth, 0, 0]) cube([2*tail_depth, case_depth, case_height]);
    }
}

module show_case() {
    rotate([foot_angle, 0, 0])
    translate([0, 0, -sin(foot_angle) * case_r_outer]) {
        split_case(left=true);
        split_case(left=false);
    }

    single_foot_w = 20;
    dual_foot_w = 30;

    translate([2*wall_w, 0, 0])
    foot(single_foot_w);
    translate([(case_width - dual_foot_w)/2, 0, 0])
    foot(dual_foot_w, pairwise=true);
    translate([case_width - single_foot_w - 2*wall_w, 0, 0])
    foot(single_foot_w);
    #translate([0,0,-10]) cube([case_width, case_depth, 10]);
}


$fn = 40;
//split_case(left=true);
//test_dove_tail();
show_case();
