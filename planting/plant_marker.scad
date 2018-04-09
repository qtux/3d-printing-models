/*
 * Plant marker with single characters (dual extrusion possible)
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

// show specific part
// 0: character and base together
// 1: only characters (for dual extrusion)
// 2: only base (for dual extrusion)
show_part = 0;

$fn = 200;

// name tags from A to E
for (i = [0:4]) {
    translate([25 * i, 0, 0]) name_tag(chr(65 + i), show_part);
}
// name tags from F to J
for (i = [5:9]) {
    translate([25 * (i - 5), 80, 0]) name_tag(chr(65 + i), show_part);
}

module name_tag(name, show_part=0, height=1.6) {
    if (show_part == 0 || show_part == 1) {
        linear_extrude(height)
        text(name, size=12, font="Hack", halign="center", valign="center");
    }
    if (show_part == 0 || show_part == 2) {
        translate([0, 0, -height]) linear_extrude(height) {
            offset(r=5) square([10, 10], center=true);
            offset(r=2) polygon([[2.5, -10], [0, -60], [-2.5, -10]]);
        }
    }
}
