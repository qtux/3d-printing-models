/*
 * Lid for a typical hard cheese container from the supermarket
 *
 * Copyright (C) 2022  Matthias Gazzari
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

module simple_trapezoid(w1, w2, h, center=true) {
    translate(center ? [-h/2, -w1/2] : [0, 0])
    polygon([
        [0, 0],
        [h, (w1-w2) / 2],
        [h, w2 + (w1-w2) / 2],
        [0, w1],
    ]);
}

module trapezoid_round_edges(w1, w2, h, r=5, center=true) {
    // ensure that the circles can fit inside the trapezoid
    assert (r <= h/2);
    
    // standard trapezoid edge positions
    trapezoid_positions = [
        [0, 0],
        [h - 0, (w1-w2) / 2],
        [h - 0, w2 + (w1-w2) / 2],
        [0, w1],
    ];

    // determine both inner angles alpha and beta of a trapezoid
    w = abs(w1-w2) / 2;
    alpha = (w1 > w2) ? atan(h / w) : 180 - atan(h / w);
    beta = (w1 > w2) ? 180 - atan(h / w) : atan(h / w);

    // offset applied to the standard trapezoid positions to account
    // for the circles radii
    rounded_corner_offset = [
        [r,   r / tan(alpha/2)],
        [-r,  r / tan(beta/2)],
        [-r, -r / tan(beta/2)],
        [r,  -r / tan(alpha/2)],
    ];

    // create the actual trapezoid
    translate(center ? [-h/2, -w1/2] : [0, 0])
    hull() {
        for (pos=trapezoid_positions + rounded_corner_offset) {
            translate(pos) circle(r = r);
        }
    }
}

// measure the container and derive the main trapezoid parameters (w1, w2, h) for the lid
lid_w1 = 90;
lid_w2 = 60;
lid_h = 120;

// manually determine the following parameters to create the final shape of the lid
$fn = 100;
groove_h = 0.8;
rim_w = 14;
thick = 1.6;
overhang = thick + 6.4;

// create the lid
difference() {
    linear_extrude(2 * thick + groove_h)
    trapezoid_round_edges(lid_w1, lid_w2, lid_h);
    // remove from upper part
    translate([0, 0, thick]) {
        // remove the main part of the lid
        linear_extrude(2*thick + groove_h)
        simple_trapezoid(lid_w1 - overhang, lid_w2 - overhang, lid_h);
        // remove space for the groove
        linear_extrude(groove_h)
        simple_trapezoid(lid_w1-2*thick, lid_w2-2*thick, lid_h);
    }
    // create three evenly distanced holes to save material
    for (i = [0:2]){
        let (
            slope = (lid_w1 - lid_w2) / lid_h,
            quarter_lid_h = lid_h / 4,
            width = lid_w2 + slope * (i * quarter_lid_h + (i + 1) * quarter_lid_h/4) - rim_w,
            x_offset = (1 - i) * (quarter_lid_h + quarter_lid_h/4)
        ) {
            translate([x_offset, 0, -thick])
            linear_extrude(4 * thick + groove_h)
            trapezoid_round_edges(slope * quarter_lid_h + width, width, quarter_lid_h);
        }
    }
}