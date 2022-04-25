/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2022 by Jadejia
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * Project : SpiderDB;
 */

grammar SpiderSql;

SELECT_: ('S' | 's') ('E' | 'e') ('L' | 'l') ('E' | 'e') (
		'C'
		| 'c'
	) ('T' | 't');

FROM_: ('F' | 'f') ('R' | 'r') ('O' | 'o') ('M' | 'm');

select_stmt: SELECT_ Expr_ FROM_ Table_;

Digit:
	'0'
	| '1'
	| '2'
	| '3'
	| '4'
	| '5'
	| '6'
	| '7'
	| '8'
	| '9';

ASC_: [a-zA-Z]+;

Table_: ASC_;

Expr_: ASC_ ('.') ASC_ | ASC_;