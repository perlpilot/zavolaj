# zavolaj t/02-resident.t

# Test resident library functions, that is, functions that are callable
# without explicitly specifying external libraries.  The functions
# available this way are the C standard library functions such as
# isalpha() and similar.  See http://www.gnu.org/software/libc/manual/.

# Note: do not try this with function names that match same named
# functions in Perl 6 such as sqrt(), because you will not be able to
# tell which function you have actually called.

# Note: a native sub declaration does not verify that the function name
# can be found.  The search is done when the function is called.

# Consistently failing tests have been commented out and moved to the
# end of the file.

use Test;
use NativeCall;
plan 24;

diag 'No parameters';
sub getpid() returns Int is native() { ... }
ok getpid()!=0, "f() -> Int - getpid()!=0";                    # test 1

diag 'Int parameters';
sub  isalpha(Int $i) returns Int is native() { ...  }
ok ! isalpha(0x40), "f(Int) -> Int - isalpha(0x40) is false";  # test 2
ok   isalpha(0x41), "f(Int) -> Int - isalpha(0x41) is true";   # test 3
ok   isalpha(0x5a), "f(Int) -> Int - isalpha(0x5a) is true";   # test 4
ok ! isalpha(0x5b), "f(Int) -> Int - isalpha(0x5b) is false";  # test 5

diag 'Num parameters (double precision floating point)';
sub cbrt(Num $n) returns Num is native() { ... } # cube root
is cbrt(15.625), 2.5, "f(Num) -> Num - cbrt(15.625) is 2.5";   # test 6
sub ceil(Num $n) returns Num is native() { ... }
is ceil(41.01), 42, "f(Num) -> Num - ceil(41.01) is 42";       # test 7
is ceil(-3.99), -3, "f(Num) -> Num - ceil(-3.99) is -3";       # test 8
# but ceilf(float) and ceill(long double) fail, see end of file
# also Parrot has no NCI thunk for double f(double,double).
sub fabs(Num $n) returns Num is native() { ... }
is fabs(3.3), 3.3, "f(Num) -> Num - fabs(3.3) is 3.3";         # test 9
is fabs(-5.5), 5.5, "f(Num) -> Num - fabs(-5.5) is 5.5";       # test 10
sub ilogb(Num $n) returns Int is native() { ... }
is ilogb(63.9), 5, "f(Num) -> Int - ilogb(63.9) is 5";         # test 11
is ilogb(-8.1), 3, "f(Num) -> Int - ilogb(-8.1) is 3";         # test 12

diag 'Str parameters';
sub strlen(Str $s) returns Int is native() { ... }
is strlen("abcde"), 5, 'f(Str) -> Int - strlen("abcde") is 5'; # test 13
sub strcmp(Str $a, Str $b) returns Int is native() { ... }
ok strcmp("a","z") < 0, 'f(Str,Str) -> Int - strcmp("a","z") is -1'; # test 14
is strcmp("p","p"), 0, 'f(Str,Str) -> Int - strcmp("p","p") is 0'; # test 15
ok strcmp("9","10") > 0, 'f(Str,Str) -> Int - strcmp("9","10") is 1'; # test 16
sub strncmp(Str $a, Str $b, Int $i) returns Int is native() { ... }
is strncmp("xa","xb",1),  0, 'f(Str,Str,Int) -> Int - strncmp("xa","xb",1) is 0'; # test 17
is strncmp("xb","xb",1),  0, 'f(Str,Str,Int) -> Int - strncmp("xb","xb",1) is 0'; # test 18
is strncmp("xc","xb",1),  0, 'f(Str,Str,Int) -> Int - strncmp("xc","xb",1) is 0'; # test 19
ok strncmp("xa","xb",2) < 0, 'f(Str,Str,Int) -> Int - strncmp("xa","xb",2)  < 0'; # test 20
is strncmp("xb","xb",2),  0, 'f(Str,Str,Int) -> Int - strncmp("xb","xb",2) is 0'; # test 21
ok strncmp("xc","xb",2) > 0, 'f(Str,Str,Int) -> Int - strncmp("xc","xb",2)  > 0'; # test 22

#fail: got: '0' expected: '2.5' # maybe because float==single, Num==double
#sub sqrtf(Num $float) returns Num is native() { ... }
#is sqrtf(6.25), 2.5, "f(Num) -> Num - sqrtf(6.25) is 2.5";

#ceilf(float) returns float (single precision) # same as sqrtf()
#sub ceilf(Num $n) returns Num is native() { ... }
#is ceilf(41.01), 42, "f(Num) -> Num - ceilf(41.01) is 42"; #fail: got: '-0' expected: '42'
#is ceilf(-3.99), -3, "f(Num) -> Num - ceilf(-3.99) is -3"; #fail: got:  '1' expected: '-3'

#fail: got: '-76' expected: '2' # probably double->float error in Parrot
#sub ilogbf(Num $n) returns Int is native() { ... }
#is ilogbf(7.9), 2, "f(Num) -> Int - ilogbf(7.9) is 2";

#ceill(long double) returns long double
#sub ceill(Num $n) returns Num is native() { ... }
#is ceill(41.01), 42, "f(Num) -> Num - ceill(41.01) is 42"; #fail: got: 'NaN' expected: '42'
#is ceill(-3.99), -3, "f(Num) -> Num - ceill(-3.99) is -3"; #fail: got: 'Inf' expected: '-3'

#abort: No NCI thunk available for signature `double (double, double)'
#sub pow(Num $x, Num $y) returns Num is native() { ...  }
#ok pow(2.5,2)==6.25, "f(Num,Num) -> Num - pow(2.5,2)==6.25";

#abort: Segmentation fault
#sub time() returns OpaquePointer is native() { ... }
#ok time()!=0, "f() -> OpaquePointer - time()!=0";

#fail: got: '0' expected: '3'
sub strchr(Str $s, Int $c) returns Str is native() { ... }
is strchr("abcde",0x64), "de", 'f(Str,Int) -> Str - strchr("abcde",0x64) is "de"';

#fail: got: '160719491' expected: '3'
sub strstr(Str $a, Str $b) returns Str is native() { ... }
is strstr("abcde","d"), "de", 'f(Str,Str) -> Str - strchr("abcde","d") is "de"';

#fail: got: '' expected: 'de'
#sub strchr(Str $a, Int $c) returns Str is native() { ... }
#is strchr("abcde",0x44), "de", 'f(Str,Int) -> Str - strchr("abcde",0x44) is "de"';

