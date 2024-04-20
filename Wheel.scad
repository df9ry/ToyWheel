// Resolution for 3D printing:
$fa      =  1;
$fs      =  0.4;

// Allgemeines:
delta    =  0.01;  // Standard Durchdringung

rim_d1   = 33.00;
rim_d2   = 25.00;
rim_th   =  2.00;
rim_h    = 12.30;

module rim() {
    difference() {
        cylinder(h = rim_h, d = rim_d1);
        translate([0, 0, -delta])
            union () {
                cylinder(h = rim_h + 2 * delta, d = rim_d2);
                cylinder(h = rim_h - rim_th + delta,
                         d = rim_d1 - 2 * rim_th);
            }
    }
}

cross_h  =  8.00;

module cross_bar() {
    translate([-rim_d1 / 2.0 -delta, -rim_th / 2.0, 
               rim_h - cross_h - rim_th])
        cube([rim_d1 + 2 * delta,
              rim_th, cross_h + delta]);
}

module cross() {
    cross_bar();
    rotate([0, 0, 45])
        cross_bar();
    rotate([0, 0, 90])
        cross_bar();
    rotate([0, 0, 135])
        cross_bar();
}

axis_h   =  3.00;
axis_d   =  7.00;

module axis() {
    h1 = rim_h - rim_th + axis_h;
    translate([0, 0, -axis_h])
        cylinder(h = h1, d = axis_d);
}

spindle_d=  2.30;

module spindle() {
    translate([0, 0, - axis_h - delta])
        cylinder(h = rim_h + axis_h + 2 * delta,
                 d = spindle_d);
}

module part1() {
    color("grey") {
        difference() { 
            union() {
                rim();
                cross();
                axis();
            }
            spindle();
        }
    }
}

mold_h1  =  1.00;
mold_th1 =  1.50;
mold_th2 =  3.50;

spec_d   =  1.00;

module specle(a) {
    rotate([0, 0, a])
        translate([rim_d2 / 2.0 - mold_th2 + 1.0, 0,
                   rim_th])
            sphere(d = spec_d);
}

n_spec   = 32;

module specles() {
    step = 360.0 / n_spec;
    for (i = [0:step:360 - step]) {
        specle(i);
    } 
}

module hexagon_plot() {
    polygon(points = [
        [1,        0       ],
        [cos( 60), sin( 60)],
        [cos(120), sin(120)],
        [cos(180), sin(180)],
        [cos(240), sin(240)],
        [cos(300), sin(300)]
    ]);
}

hexagon_d = 7.00;

module hexagon() {
    sc = hexagon_d / 2.00;
    translate([0, 0, rim_th / 2.00 + 1])
        linear_extrude(height = rim_th-1, center = true)
            scale([sc, sc])
                hexagon_plot();
}

module octagon_plot() {
    polygon(points = [
        [1,        0       ],
        [cos( 45), sin( 45)],
        [cos( 90), sin( 90)],
        [cos(135), sin(135)],
        [cos(180), sin(180)],
        [cos(225), sin(225)],
        [cos(270), sin(270)],
        [cos(315), sin(315)]
    ]);
}

octagon_d = 10.00;

module octagon() {
    sc = octagon_d / 2.00;
    translate([0, 0, rim_th / 2.00])
        linear_extrude(height = rim_th-0.9, center = true)
            scale([sc, sc])
                octagon_plot();
}

stay_l = 5.50;
stay_w = 4.50;
stay_v = 0.60;
stay_h = 1.45;

module stay_plot() {
    w1 = stay_w /2;
    w2 = w1 * stay_v;
    polygon(points = [
        [0.0,     w2],
        [stay_l,  w1],
        [stay_l, -w1],
        [0.0,    -w2]
    ]);
}

module stay_base() {
    translate([0, 0, stay_h / 2])
        linear_extrude(height = stay_h, center = true)
            stay_plot();
}

module stay1() {
    m = [ [1,   0, 0, 3.7],
          [0,   1, 0, 0],
          [0.1, 0, 1, 0] ];
    multmatrix(m)
        difference() {
            stay_base();
            translate([1.0, 0, 0.5])
                scale([0.7, 0.4, 3])
                    stay_base();
        }
}

module stay() {
    step = 360 / 8; 
    for (a = [step / 2 : step : 360])
        rotate([0, 0, a])
            stay1();
}

module molding() {
    difference() {
        cylinder(h = rim_th + mold_h1, d = rim_d2);
        translate([0, 0, -delta])
            cylinder(h = rim_th + mold_h1 + 2 * delta,
                     d = rim_d2 - 0.25 - 2 * mold_th1);
    }
    difference() {
        cylinder(h = rim_th, d = rim_d2);
        translate([0, 0, 0.5])
            cylinder(h = rim_th + mold_h1 + 2 * delta,
                     d = rim_d2 - 2 * mold_th2);
    }
    
    specles();
}

module part2() {
    difference() {
        color("silver") {
            molding();
            hexagon();
            octagon();
            stay();
        }
        spindle();
    }
}

tire_th =  0.40;
tire_d1 = 24.00;
tire_d2 = 28.00;

lug_w  = rim_h / 2.0 + tire_th;
lug_l  = 8.00;
lug_h  = 2.00;
n_lugs = 16;

module lug_plot() {
    polygon([
        [0.0, 0.00],
        [0.0, 0.70],
        [0.1, 0.70],
        [0.2, 0.68],
        [0.3, 0.65],
        [0.4, 0.58],
        [0.5, 0.50],
        [0.6, 0.44],
        [0.7, 0.39],
        [0.8, 0.35],
        [0.9, 0.33],
        [1.0, 0.30],    
        [1.0, 0.00]]);    
}

module lug1() {
    m = [ [1, 0,  0,   0],
          [0, 1, 0.6, 0],
          [0, 0,  1,   0] ];
    multmatrix(m)
        linear_extrude(height = lug_h, center = false,
                       scale = 0.7)
            scale([lug_w, lug_l])
                lug_plot();
}

module lug() {
    translate([rim_d1 / 2.0, 0, lug_w])
        rotate([0, 90, 0]) {
            lug1();
            translate([0, -4, 0])
                mirror([1, 0, 0])
                    lug1();
        }
}

module lugs() {
    step = 360.0 / n_lugs;
    for (a = [0 : step : 360.0 - step])
        rotate([0, 0, a])
            lug();
}

module tire() {
    union() {
        difference() {
            cylinder(h = rim_h + 2 * tire_th,
                     d = rim_d1 + 2 * tire_th);
            translate([0, 0, -delta])
                cylinder(h = rim_h + 2 * tire_th 
                         + 2 * delta, d = rim_d1);
        }
        difference() {
            cylinder(h = tire_th,
                     d = rim_d1 + 2 * tire_th);
            translate([0, 0, -delta])
                cylinder(h = tire_th + 2 * delta,
                         d = tire_d1);
        }
        translate([0, 0, rim_h + tire_th])
            difference() {
                cylinder(h = tire_th,
                         d = rim_d1 + 2 * tire_th);
                translate([0, 0, -delta])
                    cylinder(h = tire_th + 2 * delta,
                             d = tire_d2);
            }
    }
}

module combined() {
    translate([0, 0, -rim_h + rim_th])
        part1();
    part2();
    translate([0, 0, -rim_h + rim_th - tire_th / 2]) {
        tire();
        lugs();
    }
}

module print_rim() {
    translate([0, 0, rim_h])
        mirror([0, 0, 1])
            part1();
}

module print_cap() {
    part2();
}

module print_tire_r() {
    tire();
    lugs();
}

module print_tire_l() {
    tire();
    translate([0, 0, rim_h + rim_th / 2.0 - tire_th / 2.0])
        mirror([0, 0, 1])
            lugs();
}

//combined();

//print_rim();
//print_cap();
//print_tire_r();
print_tire_l();
