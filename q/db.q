///
// Writes a splayed table to a directory
// @param d File handle - Directory
// @param p Date        - Partition
// @param n Sym         - Name of table
// @param t Table       - Table to save
.db.writeTable:{[d;p;n;t]
    .Q.dd[d;(p;n;`)] set .Q.en[d;t]
 }