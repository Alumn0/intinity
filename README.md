# Intinity

**Introduction**  
---------------  
Numbers in smart contracts on the Dero blockchain cannot be negative nor exceed 18,446,744,073,709,551,615 (Uint64). Intinity solves these limitations by implementing signed and unsigned integers of unlimited size for smart contracts. It provides convenient functions to operate on stored values.

**Why Intinity?**  
-----------  
In typical blockchain smart contracts, dealing with very large or negative numbers is challenging due to Uint64 constraints. Intinity extends this functionality by supporting numbers beyond these bounds, both positive and negative, allowing for greater flexibility and more complex operations in smart contracts.

**Features of Intinity:**
- **Support for Signed & Unsigned Integers:** Handle both positive and negative numbers.
- **Infinite Integers:** Support numbers of unlimited size.
- **Mathematical Operations:** Perform increment and decrment operations with intuitive functions.


**How to Use Intinity**  
-----------  
1. **Installation:**
   Deploy the provided smart contract on the Dero simulator.

2. **Function Usage:**
   - `Increment(amount)`: Adds the specified `amount` to the stored value.
   - `Decrement(amount)`: Subtracts the specified `amount` from the stored value.
   - `Display()`: Outputs the current value, represented as a formula in the `Status` store.

Replace `amount` with any valid Uint64 value. Execute `Display()` for Intinity to evaluate the stored number and to store it in the `Status` store. If the value overflows or underflows Uint64, then it will be printed as formular.

**Examples Stored in `Status`:**

```
1. Number: 0
2. Number: 18446744073709551615
3. Number: 10 + 25 x 18446744073709551615
4. Number: 8467440370951615 + 14835 x 18446744073709551615 x 18446744073709551615 + 923567324824 x 18446744073709551615
5. Number: -1
6. Number: -73643
7. Number: -5 + 8 x 18446744073709551615
8. Number: -2594832 + 7334 x 18446744073709551615 x 18446744073709551615 + 5464728492 x 18446744073709551615
```

## Sponsorship Request

To further initiatives and explore new projects, I am seeking sponsorships. Your support will enable me to dedicate more time and resources to developing valuable solutions in the Dero space.

**Interested in supporting my work?** You can sponsor my work by sending Dero to the wallet: `Alumno`. Alternatively, feel free to contact me to discuss other forms of sponsorship.

---

*Your contribution is vital to the continuous innovation and development in the Dero ecosystem.*