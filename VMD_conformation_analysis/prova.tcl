set x {}
lappend x [measure dihed {0 4 5 8}]; list
lappend x [measure dihed {4 5 8 11}]; list
lappend x [measure dihed {5 8 11 12}]; list
lappend x [measure dihed {8 11 12 15}]; list
lappend x [measure dihed {11 12 15 18}]; list
lappend x [measure dihed {12 15 18 19}]; list

puts $x

set result {}

foreach {a} $x {
  if {[expr $a < 0]} {
   set a [expr $a + 360]
  }
  # tutti tra 0 e 360
  
  if {[expr $a >= 0 && $a <= 30]} {
   lappend result "t00"
  }
  if {[expr $a > 30 && $a <= 75]} {
   lappend result "g0"
  }
  if {[expr $a > 75 && $a <= 135]} {
   lappend result "x0"
  }
  if {[expr $a > 135 && $a <= 225]} {
   lappend result "t"
  }
  if {[expr $a > 225 && $a <= 285]} {
   lappend result "x"
  }
  if {[expr $a > 285 && $a <= 330]} {
   lappend result "g"
  }
  if {[expr $a > 330 && $a <= 360]} {
   lappend result "t00"
  }

}

set outfile [open /tmp/conformerscript.dat w]

puts $outfile [join $result ""]
close $outfile
exit
