/*
 * Washer with flower shape for better grip
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

height = 1.8;
outer = 10;
inner = 3.3;

union() {
	difference() {
		cylinder(h=height, r=outer, center=true, $fn=100);
		cylinder(h=height, r1=inner, r2=inner, center=true, $fn=100);
	}
	for (i=[1:9]) {
		translate([cos(i * 40) * outer * 0.9, sin(i * 40) * outer * 0.9, 0])
			cylinder(h=height, r=2.5, center=true, $fn=100);
	}
}
