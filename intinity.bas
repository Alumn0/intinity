Function Initialize() Uint64
//1 IF EXISTS("Counter") THEN GOTO 8
//2 STORE("Counter", 18446744073709551615)
//3 STORE("Counter+", 18446744073709551615)
//4 STORE("Counter++", 18446744073709551615)
//5 STORE("Counter+++", 18446744073709551615)
//6 STORE("Counter++++", 18446744073709551615)

//2 STORE("Counter", 1)
//3 STORE("Counter-", 18446744073709551615)
//4 STORE("Counter--", 18446744073709551615)
//5 STORE("Counter---", 18446744073709551615)
//6 STORE("Counter----", 18446744073709551615)
8 RETURN Display()
End Function


/*
    Public functions
*/

Function Increment(amount Uint64) Uint64
1 RETURN incrementStore("Counter", amount)
End Function

Function Decrement(amount Uint64) Uint64
1 RETURN decrementStore("Counter", amount)
End Function

Function Display() Uint64
1 RETURN displayStatus("Counter")
End Function


/*
   Private functions
*/


Function displayStatus(key String) Uint64
1 IF EXISTS(key) != 1 THEN GOTO 100
2 DIM underflowCounterCount, overflowCounterCount as Uint64
3 IF hasOverflow(key) THEN GOTO 6
4 IF hasUnderflow(key) THEN GOTO 10
5 RETURN STORE("Status", "Number: " + getNumber(key)) == 0 // handle no overflow / underflow
// handle overflow
6 LET overflowCounterCount = getOverflowCounterCount(key, 0)
7 IF overflowCounterCount > 1 THEN GOTO 9
8 RETURN STORE("Status", "Number: " + getNumber(key) + " + " + LOAD(getOverflowKey(key)) + " x 18446744073709551615")  == 0
9 RETURN STORE("Status", "Number: " + getNumber(key) + " + " + (overflowCounterCount - 1) + " x 18446744073709551615 x 18446744073709551615 + " + LOAD(getOverflowKey(key)) + " x 18446744073709551615")  == 0
// handle underflow
10 IF LOAD(key + "-") > 1 THEN GOTO 12 // if value underflowed more than once
11 RETURN STORE("Status", "Number: -" + getNumber(key)) == 0
12 LET underflowCounterCount = getUnderflowCounterCount(key, 0)
14 IF underflowCounterCount > 2 THEN GOTO 16
15 RETURN STORE("Status", "Number: -" + getNumber(key) + " - " + (LOAD(getUnderflowKey(key)) - 1) + " x 18446744073709551615") == 0
16 IF LOAD(getUnderflowKey(key)) > 1 THEN GOTO 18 
17 RETURN STORE("Status", "Number: -" + getNumber(key) + " - " + underflowCounterCount + " x 18446744073709551615 x 18446744073709551615") == 0
18 RETURN STORE("Status", "Number: -" + getNumber(key) + " - " + underflowCounterCount + " x 18446744073709551615 x 18446744073709551615 - " + (LOAD(getUnderflowKey(key)) - 1) + " x 18446744073709551615") == 0
100 RETURN STORE("Status", "Key '" + key + "' doesn't exist") == 0
End Function

Function incrementStore(key String, number Uint64) Uint64
1 IF EXISTS(key) != 1 THEN GOTO 99
2 IF 18446744073709551615 - number < LOAD(key) && hasUnderflow(key) THEN GOTO 30 // if it overflows an underflowed value
4 IF 18446744073709551615 - number < LOAD(key) && hasOverflow(key) THEN GOTO 40 // if it overflows an overflowed value
6 IF 18446744073709551615 - number < LOAD(key) THEN GOTO 8 // if it overflows the first time
7 RETURN STORE(key, LOAD(key) + number) == 0 // no overflow handling needed
8 STORE(key + "+", 1) // create first overflow counter
9 RETURN STORE(key, number - (18446744073709551615 - LOAD(key))) == 0 // calculate new value
// handle overflow of underflowed value
30 STORE(getUnderflowKey(key), LOAD(getUnderflowKey(key)) - 1) // decrement underflow counter
31 IF LOAD(getUnderflowKey(key)) > 0 THEN GOTO 36 // if there is more underflow left
32 IF getUnderflowKey(key) != key + "-" THEN GOTO 35 // if it's not the first underflow counter
33 DELETE(key + "-") // delete first underflow counter; remove underflow status
34 RETURN STORE(key, (number - 1) - (18446744073709551615 - LOAD(key))) == 0 // calculate new value 
35 DELETE(getUnderflowKey(key)) // delete empty consecutive underflow counter
36 RETURN STORE(key, number - (18446744073709551615 - LOAD(key))) == 0 // calculate new value
// handle overflow of overflowed value
40 IF LOAD(getOverflowKey(key)) < 18446744073709551615 THEN GOTO 45 // if the counter is not overflowing (<= max Uint64)
41 STORE(getOverflowKey(key) + "+", 1) // create new/consecutive overflow counter
42 GOTO 46
45 STORE(getOverflowKey(key), LOAD(getOverflowKey(key)) + 1) // increment overflow counter
46 RETURN STORE(key, number - (18446744073709551615 - LOAD(key))) == 0 // calculate new value
99 RETURN STORE(key, number) == 0 // store new key / value
End Function

Function decrementStore(key String, number Uint64) Uint64
1 IF EXISTS(key) != 1 THEN GOTO 90
2 IF LOAD(key) <= number && hasOverflow(key) THEN GOTO 20 //  underflow of overflowed
4 IF LOAD(key) <= number && hasUnderflow(key) THEN GOTO 40 // underflow of underflowed value
6 IF LOAD(key) < number THEN GOTO 8 // first underflow, handle 0 value
7 RETURN STORE(key, LOAD(key) - number) == 0 // no underflow, decrement value
8 STORE(key, 18446744073709551615 - ((number - 1) - LOAD(key))) // calculate new value, number-1 to account for 0 value
12 GOTO 93
// handle underflow of overflowed value
20 STORE(getOverflowKey(key), LOAD(getOverflowKey(key)) - 1) // decrement overflow counter
21 IF LOAD(getOverflowKey(key)) > 0 THEN GOTO 23 // if there is more overflow left
22 DELETE(getOverflowKey(key)) // delete empty overflow counter key
23 RETURN STORE(key, 18446744073709551615 - (number - LOAD(key))) == 0
// handle underflow of underflowed value
40 IF LOAD(getUnderflowKey(key)) < 18446744073709551615 THEN GOTO 44 // if the counter is not overflowing (<= max Uint64)
42 STORE(getUnderflowKey(key) + "-", 1) // create new underflow counter
43 GOTO 46
44 STORE(getUnderflowKey(key), LOAD(getUnderflowKey(key)) + 1) // increment underflow counter
45 IF LOAD(key) == number THEN GOTO 47
46 RETURN STORE(key, 18446744073709551615 - (number - LOAD(key))) == 0 // calculate new value
47 RETURN STORE(key, 18446744073709551615) == 0 // handle special case 0; store max Uint64 instead
// handle non existing key
90 IF number > 0 THEN GOTO 92
91 RETURN STORE(key, 0) == 0 // store 0 if key doesn't exist and 0 is subtracted 
92 STORE(key, 18446744073709551615 - (number - 1)) // value is 0, calculate new value, number-1 to account for 0 value
93 RETURN STORE(key + "-", 1) == 0 // create first underflow counter
End Function


// evaluates current value at key and returns its Uint64 representation
// use hasUnderflow() to determine signed / unsigned status
Function getNumber(key String) Uint64
1 IF EXISTS(key) != 1 THEN GOTO 7
2 IF hasUnderflow(key) THEN GOTO 4
3 RETURN LOAD(key) // return value, no overflow handling required
4 IF 18446744073709551615 - LOAD(key) == 0 && LOAD(getUnderflowKey(key)) > 1 THEN GOTO 6 // 0 case needs special handling; can not return 0 when overflowed more than once
5 RETURN 18446744073709551615 - LOAD(key) + 1 // return any number including 0, +1 to account for 0 from first underflow
6 RETURN 1 // return 1 instead of 0  (overflow max Uint64 by 1)
7 RETURN 0 // return 0 if key doesn't exist
End Function

// returns the amount of overflow counters in use
Function getOverflowCounterCount(key String, count Uint64) Uint64
1 IF EXISTS(key + "+") THEN GOTO 3
2 RETURN count
3 RETURN getOverflowCounterCount(key + "+", count + 1)
End Function

// returns the amount of underflow counters in use
Function getUnderflowCounterCount(key String, count Uint64) Uint64
1 IF EXISTS(key + "-") THEN GOTO 3
2 RETURN count
3 RETURN getUnderflowCounterCount(key + "-", count + 1)
End Function

// return 1 if the stored value is negative
Function hasUnderflow(key String) Uint64
1 RETURN EXISTS(key + "-")
End Function

// returns 1 if the stored value overflowed Uint64
Function hasOverflow(key String) Uint64
1 RETURN EXISTS(key + "+")
End Function

// returns the key for the newest overflow counter
// returns the original key if no overflowKey exists
Function getOverflowKey(key String) String
1 IF EXISTS(key + "+") THEN GOTO 3
2 RETURN key
3 RETURN getOverflowKey(key + "+")
End Function

// returns the key for the newest underflow counter
// returns original key if no underflowKey exists
Function getUnderflowKey(key String) String
1 IF EXISTS(key + "-") THEN GOTO 3
2 RETURN key
3 RETURN getUnderflowKey(key + "-")
End Function
